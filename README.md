# elf2mif #

[![Build Status](https://travis-ci.com/emmicro-us/elf2mif.svg?branch=master)](https://travis-ci.com/emmicro-us/elf2mif)

elf2mif is a utility to convert an ELF file into a Memory Initialization File (MIF) for loading into an RTL simulator memory model.

### Building ###

This project requires a copy of [CMake](https://cmake.org/) to build. Here are some basic build commands:
```
git submodule update --init --recursive
mkdir build
cd build
cmake ..
cmake --build .
cmake --build . --target package
```
