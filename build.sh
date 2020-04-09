#!/bin/bash
###############################################################################
###
### @file       build.sh
###
### @brief      Linux build script.
###
### @project    elf2mif
###
###############################################################################
###
###############################################################################
###
### @copyright Copyright (C) 2020 EM Microelectronic
### @cond
###
### All rights reserved.
###
### Disclosure to third parties or reproduction in any form what-
### soever, without prior written consent, is strictly forbidden
###
###############################################################################
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
###############################################################################

set -e

BRANCH=`git rev-parse --abbrev-ref HEAD`
GOAL=$1
GENERATOR=""

export CTEST_PARALLEL_LEVEL=8
export CTEST_OUTPUT_ON_FAILURE=1

CMAKE=`which cmake3 2>/dev/null || true`
if [[ "${CMAKE}" == "" ]]
then
    CMAKE=`which cmake 2>/dev/null || true`
fi

CPACK=`which cpack3 2>/dev/null || true`
if [[ "${CPACK}" == "" ]]
then
    CPACK=`which cpack 2>/dev/null || true`
fi

if [[ "${CMAKE}" == "" ]]
then
    echo "Unable to locate cmake executable."
    exit -1
fi

NINJA=`which ninja 2>/dev/null || true`
if [[ "${NINJA}" == "" ]]
then
    NINJA=`which ninja-build 2>/dev/null || true`
fi

if [[ "${NINJA}" != "" ]]
then
    GENERATOR="-G Ninja"
fi

echo "Attempting to build branch ${BRANCH}"

rm -rf build release artifacts
mkdir build release artifacts
RELEASE_DIR=`pwd`/release/
cd build
${CMAKE} ${GENERATOR} "${@:2}" -DCMAKE_INSTALL_PREFIX="`pwd`/../release" ..
${CMAKE} --build .
${CMAKE} --build . --target test

if ${CPACK}
then
    find _CPack_Packages/ -maxdepth 3 -type f -exec mv {} "`pwd`/../artifacts/" \;
fi
