#!/usr/bin/env bash

function get_input() {

  read -p "$1" answer

  case "${answer}" in
    [Yy][Ee][Ss] | [Yy])
      echo 1
      ;;
    *)
      echo 0
      ;;
  esac
}


function update_minunit() {

  curl --max-time 2 -s "${minunit_header_raw}" > "${path}/minunit-temp.h"

  if [ ! $? -eq 0 ]; then
    echo "Fail update: minunit.h. Check connection/validity of the download link."
  else
    cat "${path}/minunit-temp.h" > "${minunit_header}"
    rm "${path}/minunit-temp.h"
  fi
}


function set_up_standalone_modules() {

  cp -r "$layout_files"/* .; rm ./src/main.c

  # Set-up makefile:
  # Get rid of some variables, rules and recipes.
  sed -i 's/^all: .*/all: \$(OBJS)/' ./Makefile
  sed -i '/TARGET_EXEC/{N;d;}' ./Makefile
  sed -i '/$(BUILD_DIR)/{N;d;}' ./Makefile        
  sed -i '/BUILD_DIR/d' ./Makefile

  # Fix TEST_OBJS variable
  sed -i '/^TEST_SRCS := /i\TEST_OBJS := $(patsubst $(SRC_DIR)/%.c, $(TEST_BIN)/%.o, $(SRCS))' ./Makefile

  # Re-write directory creation rule
  sed -i '/^\.PHONY: .*/i \ $(OBJ_DIR) $(TEST_BIN):\n\t@mkdir -p $@\n' ./Makefile

  # Fix clean target
  sed -i '/clean:/a\\t@rm -rf $(OBJ_DIR) $(TEST_BIN)' ./Makefile
  sed -i '/^$/N;/\n$/D' ./Makefile
  ${0} addmodule
}


function set_up_main_entry_point() {

  cp -r "$layout_files"/* .
  if [ ! "${name}" = "main" ]; then 
    mv ./src/main.c ./src/"$name".c
  fi

  # Set target executable in Makefile
  sed -i 's/TARGET_EXEC := /TARGET_EXEC := '"${name}"'/' ./Makefile
}


function set_up_dotc_doth_pair() {

  # Copy and rename module files
  if [ ! -d "./include" ]; then
    mkdir ./include
  fi
  
  cp "${module_files}/newmodule.h" ./include
  cp "${module_files}/newmodule.c" ./src
  mv ./include/newmodule.h ./include/"${name}".h
  mv ./src/newmodule.c ./src/"${name}".c

  # Add preprocessor include guards to header
  uppercase="${name^^}"
  sed -i "s/MODULE_FILENAME/${uppercase}_H/g" ./include/"${name}".h
  sed -i "s/MODULE_FILENAME/${name}.h/g" ./src/"${name}".c
}


function white_box_testing() {

  if [ ! -f "./src/${name}" ]; then
    echo "No source file $name"
    exit 4
  fi 

  if [ ! -d "./tests" ]; then
    mkdir ./tests
    cp ${minunit_header} ./tests
  fi

  cp "${test_files}/test_.c" ./tests
  mv ./tests/test_.c ./tests/test_"${fname}"_priv.c
  sed -i "s/FILE_TO_TEST/..\/src\/${fname}.c/g" ./tests/test_"${fname}"_priv.c

  # Add guards if this source file defines main() 
  if [[ $(grep "main(" src/${fname}.c) ]]; then
    sed -i '/int main(/i \#ifndef MINUNIT_MINUNIT_H' src/"${fname}".c
      sed -i '/^int main/,/^}/s/^}/}\n#endif/' src/"${fname}".c
  fi
}


function black_box_testing() {

  if [ ! -f "./include/${name}" ]; then 
    echo "No source file ${name}"
    exit 5
  fi 

  if [ ! -d "./tests" ]; then 
    mkdir ./tests
    cp ${minunit_header }./tests
  fi

  cp "${test_files}/test_.c" ./tests
  mv ./tests/test_.c ./tests/test_"${fname}"_publ.c
  sed -i "s/FILE_TO_TEST/..\/include\/${fname}.h/g" ./tests/test_"${fname}"_publ.c
}
