#!/usr/bin/env bash

# Get the directory where the script is located
script=$(test -L "${0}" && readlink -n "${0}" || echo "${0}")
path=$(dirname "${script}")
# shellcheck source=./source.sh
. "${path}/source.sh"

# minunit source file
minunit_header_raw="https://raw.githubusercontent.com/siu/minunit/master/minunit.h"
minunit_header="${path}/templates/test-unit/minunit.h"

layout_files="${path}/templates/base-layout"
module_files="${path}/templates/module"
test_files="${path}/templates/test-unit"

command="$1"

case "${command}" in
  "init")
    # Try to update minunit header
    if command -v curl &> /dev/null; then
      update_minunit
    fi

    # Set-up
    read -rp "Main program name: " name
    if [ -z "${name}" ]; then
      if ! get_input "No main entry point given, write a standalone module? "; then
          exit 1
      fi
      set_up_standalone_modules
    else
      set_up_main_entry_point
    fi
    ;;

  "addmodule")
    read -rp "Module name (no extension): " name
    if [ -z "${name}" ]; then
      echo "Name needed"
      exit 2
    else
      set_up_dotc_doth_pair
    fi
    ;;

  "testunit")
    echo -n "Source file (with extension, should already exist): "
    read -r name
    if [ -z "${name}" ]; then
        echo "Name needed"
        exit 3
    fi
    fname="${name%.*}"

    case "${name}" in

      *.c)
        white_box_testing
        ;;

      *.h)
        black_box_testing
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
