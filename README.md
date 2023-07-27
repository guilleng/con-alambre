# Con Alambre

An overly simplified build system. 

> __TL;DR__  
> Scaffolding tool for generating C source files, headers, and test files, along
> with integration of the [minunit](https://github.com/siu/minunit) unit test 
> framework. 
> I'm using this to avoid the overhead of learning a complex, feature-rich 
> toolchain because, right now, a minimalist setup like this meet my needs.

## Table of Contents

+ [Overview](#overview)
+ [File Generation](#file-generation)
    + [Single File Project](#single-file-project)
    + [Multiple File Projects](#multiple-file-projects)
+ [Unit Testing](#unit-testing)
    + [Testing a Source File](#testing-a-source-file)
    + [Testing an Interface](#testing-an-interface)
+ [make Recipes](#make-recipes)
    + [Building](#build)
    + [Running Tests](#running-tests)
+ [Installation](#installation)
+ [Contributing](#contributing)

## Overview

`alambre` provides a rudimentary level of automation and organization suitable 
for users who fall into the "in-between" category.  It is designed for those who
are not writing large codebases requiring the complexity of a full-fledged 
toolchain, but still will benefit from some level of automation for testing, 
compilation, and file management.

The system integrates the minunit test framework and consists of a set of simple 
template files, a bash script, and a Makefile.  It provides functionality to add
templates to interfaces, implementations, and test files.  To achieve this, the
project folder structure has to follow a specific outline. 

---

## File Generation

> The `/example` folder contains the dummy projects described below. 

### Single File Project

To create a new project, navigate to the desired directory and then run `init`:

```shell
mkdir -p examples/01-single-file
cd examples/01-single-file/
alambre init
Main program name: program
.
├── Makefile
└── src
    └── program.c
```

### Multiple File Projects

The script can manage multiple file projects that may or may not contain a main 
entry point.

#### Application

In this example, `main()` is defined in `program.c`.  The extra modules complete
the application. 

> Beware of dependencies.  Only include headers into other headers.  The only 
> exception is obviously the source file containing the program's main entry
> point. 

To start, follow the same steps as the 
[Single File Project](#single-file-project).

##### Adding Modules

To add a module, use the command `alambre addmodule`.  Enter the module name
(without the extension) when prompted.

```shell
alambre addmodule
Module name (no extension): my_module
alambre addmodule
Module name (no extension): my_other_module
.
├── include
│   ├── my_module.h
│   ├── my_other_module.h
│   └── shared_utils.h
├── Makefile
├── my_module
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

> The user must manually include the appropriate directives to resolve interface
> dependencies.  Inclusion of a module's header is not automated.


#### Standalone Modules

If no "Main program name" is supplied to `init`, the script prompts the user to
add a module.  If the answer is yes, the project is setup as a sort of library
or some standalone component.  The Makefile will only generate object files from
our sources.

```shell
alambre init
Main program name: 
No main entry point given, add a code module? y
Module name (no extension): a_standalone_module
alambre addmodule
Module name (no extension): another_standalone_module
.
├── include
│   ├── another_standalone_module.h
│   └── a_standalone_module.h
├── Makefile
└── src
    ├── another_standalone_module.c
    └── a_standalone_module.c
```

---

## Unit Testing

First and foremost, read the [minunit](https://github.com/siu/minunit)
documentation to familiarize yourself with the testing process.    
Before continuing, we should agree on the difference between testing `.c` 
(source) and `.h` (header) files. The former are expected to be 
__implementations__ while the latter, __interfaces__. The rules of the Makefile
rely on this fact.

### Source Files

To generate testing units for implementations (withe-box testing): 

```shell
alambre testunit
Source file name (with extension, should already exist): program.c
.
├── Makefile
├── src
│   └── program.c
└── tests
├── minunit.h
└── test_program_priv.c     <--generated file
```

If the file to test defines `main()`, preprocessor guards are added to avoid 
having multiple definitions of it during compilation of the test runner:  

```c
/* program.c */

#ifndef MINUNIT_MINUNIT_H
int main(int argc, char *argv[])
{
}
#endif
```

### Interfaces

Similarly, to generate testing units for interfaces (black-box testing):

```shell
alambre testunit
Source file name (with extension, should already exist): my_module.h
 .
 ├── include
 │   └── my_module.h
 ├── Makefile
 ├── src
 │   ├── my_module.c
 │   └── program.c
 └── tests
 ├── minunit.h
 ├── test_my_module_priv.c
 └── test_my_module_publ.c  <--generated file
 ```

---

## `make` Recipes

### Building

Shipped only with the basic spells: `make` and `make clean`.  

### Running Tests

#### Run a Single Test Unit

To build and run a particular unit, use the rule `make test_%_priv` or 
`make test_%_publ` accordingly. 

This will display the test results on the terminal.

```shell
make test_program_priv
././tests/bin/test_program_priv 
..

2 tests, 2 assertions, 0 failures

Finished in 0.00006183 seconds (real) 0.00006003 seconds (proc)
```

#### Run Tests Silently

To build and run the tests silently, use the `make tests` command. This compiles
and runs all tests in the `tests/` folder, sending output to the null device.
The testing process aborts if any of the tests fails, revealing the name of the
faulty test runner.

```shell
make tests

Fail: tests/bin/test_program_priv
Exit code: 1

make: *** [Makefile:55: tests] Error 1
```

## Installation 

__Prerequisites:__  

`bash` must be installed.  If available, the script will use `curl` to fetch the
minunit header from its source.

[Download](https://github.com/guilleng/con-alambre/zipball/master) the zipped
repository or clone it to a folder of your preference:  

Give the script execute permissions.  If needed, create the folder
`~/.local/bin` add it to your `$PATH` then make a symlink to the bash script:  

```shell
cd con-alambre
chmod +x alambre.sh
mkdir -p ~/.local/bin/alambre 
ln -s "$(pwd)/alambre.sh" ~/.local/bin/alambre
```

__Final notes:__  

The template test file has a _cheat sheet_ section with minunit's assertions.  
When spelling the name of the script without any arguments, it displays the list
of commands.

---

## Contributing

Feedback and contributions are appreciated and welcome. Feel free to report 
bugs, suggest enhancements, or submit a pull request.  
