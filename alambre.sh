#!/usr/bin/env bash

# Get the directory where the script is located
script_dir="$(dirname "$(readlink -f "$0")")"

# minunit source file
minunit_header_raw="https://raw.githubusercontent.com/siu/minunit/master/minunit.h"
minunit_header="$script_dir/templates/test-unit/minunit.h"

layout_files="$script_dir/templates/base-layout"
module_files="$script_dir/templates/module"
test_files="$script_dir/templates/test-unit"

command="$1"

get_input() {
    read -p "$1" answer
    case "$answer" in
        [Yy][Ee][Ss] | [Yy])
            echo 1
            ;;
        *)
            echo 0
            ;;
    esac
}

case "$command" in
    "init")
        # If curl is installed, update minunit header
        if command -v curl &> /dev/null; then
            curl --max-time 3 -s "$minunit_header_raw" > "$script_dir/minunit-temp.h"
            if [ ! $? -eq 0 ]; then
                echo "Fail update: minunit.h. Check connection/validity of the download link."
            else
                cat "$script_dir/minunit-temp.h" > "$minunit_header"
                rm "$script_dir/minunit-temp.h"
            fi
        fi
        # Set-up
        read -p "Main program name: " name
        if [[ -z "$name" ]]; then
            answer=$(get_input "No main entry point given, add a code module? ")
            if [[ "$answer" -eq 0 ]]; then
                exit 1
            fi
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
            $0 addmodule
        else
            cp -r "$layout_files"/* .
            mv ./src/main.c ./src/"$name".c
        fi
        # Set target executable in makefile
        sed -i 's/TARGET_EXEC := /TARGET_EXEC := '"$name"'/' ./Makefile
        ;;

    "addmodule")
        echo -n "Module name (no extension): "
        read name
        if [[ -z "$name" ]]; then
            echo "Name needed"
            exit 2
        else
            # Copy and rename module files
            if [ ! -d "./include" ]; then
                mkdir ./include
            fi
            cp "$module_files/newmodule.h" ./include
            cp "$module_files/newmodule.c" ./src
            mv ./include/newmodule.h ./include/"$name".h
            mv ./src/newmodule.c ./src/"$name".c
        fi
        # Add preprocessor include guards in header
        uppercase="${name^^}"
        sed -i "s/MODULE_FILENAME/${uppercase}_H/g" ./include/"$name".h
        sed -i "s/MODULE_FILENAME/${name}.h/g" ./src/"$name".c
        ;;

    "testunit")
        echo -n "Source file name (with extension, should already exist): "
        read name
        if [[ -z "$name" ]]; then
            echo "Name needed"
            exit 3
        fi
        fname="${name%.*}"
		case "$name" in
			*.c)
                if [ ! -f "./src/$name" ]; then
                    echo "No source file $name"
                    exit 4
                fi 
                if [ ! -d "./tests" ]; then # Add testing testing folder if needed
                    mkdir ./tests
                    cp $minunit_header ./tests
                fi
                cp "$test_files/test_.c" ./tests
                mv ./tests/test_.c ./tests/test_"$fname"_priv.c
                sed -i "s/FILE_TO_TEST/..\/src\/${fname}.c/g" ./tests/test_"$fname"_priv.c
                # Manage the case of a source file that defines main()
                if [[ $(grep "main(" src/${fname}.c) ]]; then
                    sed -i '/int main(/i \#ifndef MINUNIT_MINUNIT_H' src/"$fname".c
                    sed -i '/^int main/,/^}/s/^}/}\n#endif/' src/"$fname".c
                fi
				;;
			*.h)
                if [ ! -f "./include/$name" ]; then 
                    echo "No source file $name"
                    exit 5
                fi 
                if [ ! -d "./tests" ]; then # Add testing testing folder if needed
                    mkdir ./tests
                    cp $minunit_header ./tests
                fi
                cp "$test_files/test_.c" ./tests
                mv ./tests/test_.c ./tests/test_"$fname"_publ.c
                sed -i "s/FILE_TO_TEST/..\/include\/${fname}.h/g" ./tests/test_"$fname"_publ.c
				;;
            *)
                echo "Invalid input"
                exit 6
                ;;
        esac
        ;;
    *)
        echo "commands: [init] [addmodule] [testunit]"
        exit 0
        ;;
esac
