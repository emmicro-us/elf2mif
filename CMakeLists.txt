################################################################################
###
### @file       CMakeLists.txt
###
### @project    elf2mif
###
### @brief      Top level cmake configuration.
###
################################################################################
###
################################################################################
###
### @copyright Copyright (C) 2020 EM Microelectronic
### @cond
###
### All rights reserved.
###
### Redistribution and use in source and binary forms, with or without
### modification, are permitted provided that the following conditions are met:
### 1. Redistributions of source code must retain the above copyright notice,
### this list of conditions and the following disclaimer.
### 2. Redistributions in binary form must reproduce the above copyright notice,
### this list of conditions and the following disclaimer in the documentation
### and/or other materials provided with the distribution.
###
################################################################################
###
### THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
### AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
### IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
### ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
### LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
### CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
### SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
### INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
### CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
### ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
### POSSIBILITY OF SUCH DAMAGE.
### @endcond
################################################################################

CMAKE_MINIMUM_REQUIRED(VERSION 3.5.0)

PROJECT(Project)

enable_testing()

SET(CMAKE_CXX_STANDARD 11)

SET(ELFIO_TOP "${CMAKE_CURRENT_SOURCE_DIR}/elfio")

INCLUDE(cmake/version.cmake)

ADD_DEFINITIONS(
    -DELF2MIF_MAJOR=${ELF2MIF_MAJOR}
    -DELF2MIF_MINOR=${ELF2MIF_MINOR}
    -DELF2MIF_REVISION=${ELF2MIF_REVISION}
)

IF(WIN32)
    SET(ELF2MIF_INSTALL_DIR "/")
ELSE()
    SET(ELF2MIF_INSTALL_DIR "bin")
ENDIF()

SET(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)

INCLUDE(InstallRequiredSystemLibraries)

INSTALL(
    PROGRAMS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}
    DESTINATION /
)

IF(NOT WIN32)
    INCLUDE(GNUInstallDirs)
ENDIF()

# Enable the CPack module for building installers.
INCLUDE(cmake/cpack.cmake)

ADD_SUBDIRECTORY(cpp-optparse)
ADD_SUBDIRECTORY(elf2mif)
ADD_SUBDIRECTORY(tests)
