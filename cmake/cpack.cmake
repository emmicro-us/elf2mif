################################################################################
###
### @file       cmake/cpack.cmake
###
### @project    elf2mif
###
### @brief      cpack cmake configuration
###
### @classification  Confidential
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
##### CPack Configuration #####

IF(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    # We're in a subdir - don't configure cpack
    RETURN()
ENDIF()

IF(WIN32)
    SET(CPACK_GENERATOR "ZIP")
ELSE()
   SET(CPACK_GENERATOR "TGZ;TBZ2")
ENDIF(WIN32)

SET(CPACK_PACKAGE_VERSION "${RELEASE_MAJOR}.${RELEASE_MINOR}.${RELEASE_REVISION}")
SET(CPACK_PACKAGE_VERSION_MAJOR "${RELEASE_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${RELEASE_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH "${RELEASE_REVISION}")

SET(CPACK_PACKAGE_VENDOR "EM Microelectronic-US Inc")

SET(CPACK_PACKAGE_NAME "elf2mif")
SET(CPACK_PACKAGING_INSTALL_PREFIX "/${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")

SET(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_COMPONENTS_ALL ${INSTALL_COMPONENTS})

INCLUDE(CPack)
