update_minunit() {

  curl --max-time 1 -s "${minunit_header_raw}" > "${path}/minunit-temp.h"

  if [ ! $? -eq 0 ]; then
    echo "Failed to update minunit.h"
  else
    cat "${path}/minunit-temp.h" > "${minunit_header}"
    rm "${path}/minunit-temp.h"
  fi
}


set_up_standalone_modules() {

  cp "${makefile}" .

  # Set-up makefile:
  # First get rid of some variables, rules and recipes.
  sed -i 's/^all: .*/all: \$(OBJS)/
  /TARGET_EXEC/{N;d;}
  /$(BUILD_DIR)/{N;d;}
  /BUILD_DIR/d
  # Fix TEST_OBJS variable
  /^TEST_SRCS := /i\TEST_OBJS := $(patsubst $(SRC_DIR)/%.c, $(TEST_BIN)/%.o, $(SRCS))
  # Re-write directory creation rule
  /^\.PHONY: .*/i \ $(OBJ_DIR) $(TEST_BIN):\n\t@mkdir -p $@\n
  # Fix clean target
  /clean:/a\\t@rm -rf $(OBJ_DIR) $(TEST_BIN)' ./Makefile

  # Merges consecutive empty lines
  sed -i '/^$/N;/\n$/D' ./Makefile

  "${0}" addmodule
}


set_up_main_entry_point() {

  read -rp "Main program name: " name

  if [ ! -d "./src" ]; then
    mkdir ./src
  fi

  cp "${makefile}" .
  cat << EOF > ./src/"${name}".c
int main(int argc, char *argv[])
{

}
EOF

  # Set given `name` as target executable in Makefile
  sed -i 's/TARGET_EXEC := /TARGET_EXEC := '"${name}"'/' ./Makefile
}


set_up_dotc_doth_pair() {

  if [ ! -d "./include" ]; then
    mkdir ./include
  fi
  if [ ! -d "./src" ]; then
    mkdir ./src
  fi

  # Place an include directive in source file.
  cat << EOF > ./src/"${name}".c
#include "${name}.h"
EOF

  # Set preprocessor guards in header 
  cat << EOF > ./include/"${name}".h
#ifndef ${name^^}_H
#define ${name^^}_H 

#endif
EOF
}


white_box_testing() {

  if [ ! -f "./src/${name}" ]; then
    echo "No source file $name"
    exit
  fi 

  if [ ! -d ./tests ]; then
    mkdir ./tests
    cp "${minunit_header}" ./tests
  fi

  cat "${test_base}" > ./tests/test_"${fname}"_priv.c
  sed -i "s/FILE_TO_TEST/..\/src\/${fname}.c/g" ./tests/test_"${fname}"_priv.c

  # Add guards if this source file defines main() 
  if grep -q 'main(' src/"${fname}".c; then
    sed -i '/int main(/i \#ifndef MINUNIT_MINUNIT_H' src/"${fname}".c
    sed -i '/^int main/,/^}/s/^}/}\n#endif/' src/"${fname}".c
  fi
}


black_box_testing() {

  if [ ! -f "./include/${name}" ]; then 
    echo "No source file ${name}"
    exit
  fi 

  if [ ! -d "./tests" ]; then 
    mkdir ./tests
    cp "${minunit_header}" ./tests
  fi

  cat "${test_base}" > ./tests/test_"${fname}"_publ.c
  sed -i "s/FILE_TO_TEST/..\/include\/${fname}.h/g" ./tests/test_"${fname}"_publ.c
}
