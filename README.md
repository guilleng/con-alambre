Con Alambre
===========


Minimalistic scaffolding tool for generating C source files, headers, and test
files, along with integration of the [minunit](https://github.com/siu/minunit)
unit test framework. 


Table of Contents
-----------------

+ [Overview](#overview)
+ [Getting started](#getting-started)
+ [Building and Testing](#building-and-testing)


### Overview

The system integrates the minunit test framework and consists of a set of
template files, a bash script, and a Makefile.  The script provides a
rudimentary level of automation and organization for scaffolding code.  The
makefile streamlines the testing and building, relying on the following:

+ Testing a `*.c` file means testing an implementation (private or white box
  test).

+ Testing a `*.h` file means testing an interface (public or black box test).

+ The code follows a specific folder structure.


###### You can scaffold three types of projects:

1. Single file projects where all code resides in one source file:

```shell
.
├── Makefile
├── src
│   └── program.c
├── tests
├── minunit.h
└── test_program_priv.c
```


2. Application-like projects with a `main()` entry point plus modules:

```shell
.
├── include
│   ├── my_module.h
│   ├── my_other_module.h
│   └── shared_utils.h
├── Makefile
├── src
│   ├── my_module.c
│   ├── my_other_module.c
│   ├── program.c
│   └── shared_utils.c
└── tests
    ├── minunit.h
    ├── test_my_module_priv.c
    ├── test_my_module_publ.c
    ├── test_my_other_module_publ.c
    └── test_program_priv.c
```


3. Standalone modules without a main entry point:

```shell
.
├── include
│   ├── another_standalone_module.h
│   └── a_standalone_module.h
├── Makefile
└── src
│  ├── another_standalone_module.c
│  └── a_standalone_module.c
└── tests
    ├── minunit.h
    ├── ....
```


---

### Getting Started

First read the [minunit](https://github.com/siu/minunit).  (Its very short)

[Download](https://github.com/guilleng/con-alambre/zipball/master) the zipped
repository or clone it and link it:

```shell
git clone https://github.com/guilleng/con-alambre 
chmod +x con-alambre/script.sh
ln -s "$(pwd)/con-alambre/alambre.sh" ~/.local/bin/alambre
```


#### Single File Project

Create a new directory for your project, navigate into it and run `init`:

```shell
$ alambre init
[1] Single-file (or application-like)
[2] Standalone modules
Choose one: 1
Main program name: program
```

With this type of structure you can unit test all functions other than `main()`.
The script will automatically guard `main()` to ensure compilation of the test
runner.


```shell
alambre testunit
Source file name (with extension): program.c
```


#### Application-Like

Just use the command `alambre addmodule` in a single file project.

```shell
alambre addmodule
Module name (without extension): my_module
alambre addmodule
Module name (without extension): my_other_module
```

> You must manually add include directives to resolve interface dependencies.

Use `alambre testunit` to selectively scaffold testing of `.c` or `.h` files
from your modules.


#### Standalone Modules

This option sets the project as a sort of library or standalone components.  The
build will only generate an object files for each interface-implementation
pair.  Use `alambre testunit` to test interfaces and/or implementation of the
modules.


---

### Building and Testing

> Set up your compiler and its flags in `templates/base-layout/Makefile`.

To build/rebuild use the common spells: `make` and `make clean`.


#### Testing a Single Unit Test

Use the rule `make test_%_priv` or `make test_%_publ` accordingly. 

You will see the test results on the terminal.

```shell
make test_program_priv
././tests/bin/test_program_priv 
..

2 tests, 2 assertions, 0 failures

Finished in 0.00006183 seconds (real) 0.00006003 seconds (proc)
```


#### Building and Running All Tests

Use `make tests` to compile and run all tests in the `tests/` folder silently.
The testing process aborts if any of the tests fails, revealing the name of the
faulty runner.

```shell
make tests

Fail: tests/bin/test_program_priv
Exit code: 1

make: *** [Makefile:55: tests] Error 1
```
