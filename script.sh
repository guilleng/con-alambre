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
    if command -v curl &> /dev/null; then
      update_minunit
    fi

    # Set-up
    echo "[1] Single-file (or application-like)"
    echo "[2] Standalone modules"
		read -rp "Choose one: " answer

    case "${answer}" in
      1)
        set_up_main_entry_point
        ;;
      2)
        set_up_standalone_modules
        ;;
      *)
        exit
        ;;
    esac
    ;;

  "addmodule")
    read -rp "Module name (without extension): " name
    if [ -z "${name}" ]; then
      echo "Name needed"
      exit
    else
      set_up_dotc_doth_pair
    fi
    ;;

  "testunit")
    echo -n "File name (with extension): "
    read -r name
    if [ -z "${name}" ]; then
        echo "Name needed"
        exit
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
        echo "Enter an existing source file with its extension."
        exit
        ;;
    esac
    ;;
  *)
    echo "commands: [init] [addmodule] [testunit]"
    exit
    ;;
esac
