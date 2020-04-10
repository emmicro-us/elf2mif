################################################################################
###
### @file       cmake/version.cmake
###
### @brief      Version configuration script.
###
### @project    elf2mif
###
### @classification  Confidential
###
################################################################################
###
################################################################################
###
### @copyright Copyright (c) 2020, EM Microelectronic-US
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

# Top level configuration
SET(ELF2MIF_MAJOR 0)
SET(ELF2MIF_MINOR 1)
SET(ELF2MIF_REVISION )

#### Determine the version information ####
EXECUTE_PROCESS(COMMAND git rev-list HEAD
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE ELF2MIF_REVISION
                RESULT_VARIABLE GIT_STATUS
                ERROR_QUIET)
IF(NOT GIT_STATUS)
    string(REPLACE "\n" ";" ELF2MIF_REVISION ${ELF2MIF_REVISION})
    list(GET ELF2MIF_REVISION 0 ELF2MIF_HASH)
    list(LENGTH ELF2MIF_REVISION ELF2MIF_REVISION)
ELSE()
    MESSAGE(FATAL_ERROR "Unable to determine elf2mif version - not in git.")
ENDIF()
FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/version ${ELF2MIF_REVISION})
FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/hash ${ELF2MIF_HASH})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/version DESTINATION .)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/hash DESTINATION .)

IF(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    SET(RELEASE_MAJOR       ${ELF2MIF_MAJOR})
    SET(RELEASE_MINOR       ${ELF2MIF_MINOR})
    SET(RELEASE_REVISION    ${ELF2MIF_REVISION})
ENDIF()
