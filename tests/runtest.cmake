################################################################################
###
### @file       tests/runtest.cmake
###
### @project    elf2mif
###
### @brief      CMake script to run a test and compare the output file.
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

EXECUTE_PROCESS(COMMAND "${ELF2MIF}" "${IN}" out.mif "${ARG1}" "${ARG2}"
    RESULT_VARIABLE CMD_RESULT OUTPUT_VARIABLE CMD_OUTPUT)

IF(CMD_RESULT)
    MESSAGE(FATAL_ERROR "Error running elf2mif: ${CMD_RESULT}")
ENDIF()

IF(WIN32)
    EXECUTE_PROCESS(COMMAND "${CMAKE_COMMAND}" -E compare_files --ignore-eol
        "${OUT}" out.mif RESULT_VARIABLE COMPARE_RESULT)
ELSE()
    EXECUTE_PROCESS(COMMAND "${CMAKE_COMMAND}" -E compare_files
        "${OUT}" out.mif RESULT_VARIABLE COMPARE_RESULT)
ENDIF()

IF(NOT(COMPARE_RESULT EQUAL 0))
    MESSAGE(FATAL_ERROR "Output does not match.")
ENDIF()
