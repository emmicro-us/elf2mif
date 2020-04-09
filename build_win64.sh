#!/bin/bash
###############################################################################
###
### @file       build_win64.sh
###
### @brief      Windows build script (for Travis CI).
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
GENERATOR="Visual Studio 15 2017 Win64"
BUILD_CONFIG="Release"

export CTEST_PARALLEL_LEVEL=8
export CTEST_OUTPUT_ON_FAILURE=1

CMAKE="cmake"
CPACK="cpack"
CTEST="ctest"

echo "Attempting to build branch ${BRANCH}"

rm -rf build release artifacts
mkdir build release artifacts
RELEASE_DIR=`pwd`/release/
cd build
${CMAKE} -G "${GENERATOR}" "${@:2}" -DCMAKE_INSTALL_PREFIX="`pwd`/../release" ..
${CMAKE} --build . --config ${BUILD_CONFIG}
${CMAKE} --build . --config ${BUILD_CONFIG} --target package
${CMAKE} --build . --config ${BUILD_CONFIG} --target run_tests

cp elf2mif-*.zip ../artifacts
