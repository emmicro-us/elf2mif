@echo off
rem ###########################################################################
rem
rem @file       build.bat
rem
rem @brief      Windows build script.
rem
rem @project    elf2mif
rem
rem ###########################################################################
rem
rem ###########################################################################
rem
rem @copyright Copyright (C) 2020 EM Microelectronic
rem @cond
rem
rem All rights reserved.
rem
rem Disclosure to third parties or reproduction in any form what-
rem soever, without prior written consent, is strictly forbidden
rem
rem ###########################################################################
rem
rem THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
rem AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
rem IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
rem ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
rem LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
rem CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
rem SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
rem INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
rem CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
rem ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
rem POSSIBILITY OF SUCH DAMAGE.
rem @endcond
rem ###########################################################################

SETLOCAL enableextensions enabledelayedexpansion

SET BUILDDIR=build
SET RELEASE_DIR=artifacts
SET GENERATOR=-G"Visual Studio 15 2017 Win64"
SET DEFINES=
SET CMAKE=cmake
SET BUILD_ARGS=--config Release

SET DEFINES=!DEFINES! -DCMAKE_INSTALL_PREFIX="..\!RELEASE_DIR!"

"!CMAKE!" -E remove_directory "!BUILDDIR!"
IF ERRORLEVEL 1 (
    echo Unable to remove the build directory. Pleaes manually remove it and re-run built.bat.
    exit /B 1
)

"!CMAKE!" -E remove_directory "!RELEASE_DIR!"
IF ERRORLEVEL 1 (
    echo Unable to remove the release directory. Pleaes manually remove it and re-run built.bat.
    exit /B 1
)

"!CMAKE!" -E make_directory "!BUILDDIR!"
IF ERRORLEVEL 1 (
    echo Unable create the build directory.
    exit /B 1
)

"!CMAKE!" -E make_directory "!RELEASE_DIR!"
IF ERRORLEVEL 1 (
    echo Unable create the release directory.
    exit /B 1
)

cd !BUILDDIR!

echo Running cmake generator
"!CMAKE!" !GENERATOR! .. !DEFINES!
IF ERRORLEVEL 1 (
    echo Error running cmake generation
    exit /B 1
)

echo Running build
"!CMAKE!" --build . !BUILD_ARGS!
IF ERRORLEVEL 1 (
    echo Error running cmake build
    exit /B 1
)

echo Running test
"!CMAKE!" --build . --target test !BUILD_ARGS!
IF ERRORLEVEL 1 (
    echo Error running cmake test
    exit /B 1
)

@echo Build complete
exit /B 0
