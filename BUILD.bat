@echo off

:: Copyright 2019 Michael Thomas Greer
:: Distributed under the Boost Software License, Version 1.0.
:: (See accompanying file LICENSE_1_0.txt
::  or copy at https://www.boost.org/LICENSE_1_0.txt )

if "%1"=="msvc"  goto :MSVC
if "%1"=="mingw" goto :MINGW
if "%1"=="clang" goto :CLANG
if "%1"=="clean" goto :CLEAN
if "%1"==""      goto :SEARCH

::----------------------------------------------------------------------------
:USAGE
echo.usage:
echo.  BUILD.bat [COMPILER [ARCH]]
echo.
echo.where COMPILER is one of:
echo.  msvc     -- Make sure you are running at a Native C++ Visual Studio prompt
echo.              (either x86 or x64)
echo.  clang    -- Make sure that Clang is in the path
echo.  mingw    -- Make sure that MinGW is in the path
echo.  clean    -- Removes all generated obj and exe files.
echo.
echo.and where ARCH is one of:
echo.  -m32
echo.  -m64
echo.
echo.If you do not specify a compiler, then the first one found in the %%PATH%%
echo.will be used, preferring Clang over MinGW.
echo.
echo.If you do not specify an architecture, the compiler default is used.
echo.Valid only for Clang and MinGW targets. (If supported. For example,
echo.Clang-CL supports it, but MSYS2's Clang-w64 does not.)
echo.
goto :EOF

::----------------------------------------------------------------------------
:SEARCH
for %%A in ("%PATH:;=";"%") do (
  if exist "%%~A\cl.exe"      goto :MSVC
  if exist "%%~A\clang++.exe" goto :CLANG
  if exist "%%~A\g++.exe"     goto :MINGW
)
goto :USAGE

::----------------------------------------------------------------------------
:MSVC
:: MSVC must have been initialized properly at the command line, either by
:: running one of the "Native Tools Command Prompt for Visual Studio" shortcuts
:: or by executing "vcvarsall.bat" with a x86 or x64 argument.
echo.MSVC
cl /nologo /EHsc /std:c++17 /Ox /W3 /utf-8 /c utf8_console.cpp /Fo:utf8_console.obj
if ERRORLEVEL 1 goto :ERROR
cl /nologo /EHsc /std:c++14 /Ox /W3 /utf-8 example.cpp utf8_console.obj /Fe:example.ms.no-argv.exe
cl /nologo /EHsc /std:c++14 /Ox /W3 /utf-8 example.cpp utf8_console.obj /Fe:example.ms.argv.exe /DUSE_ARGV
goto :DONE

::----------------------------------------------------------------------------
:MINGW
:: MinGW must be in the %PATH%.
for /F %%I in ('g++ -dumpmachine') do set M=%%I
if "%M:w64=%"=="%M%" goto :MINGW2

:MINGW1
echo.MinGW-w64
echo.utf8_console.cpp
g++ %2 -std=c++17 -O3 -c utf8_console.cpp -o utf8_console.o -municode
if ERRORLEVEL 1 goto :ERROR
echo.example.cpp
g++ %2 -std=c++14 -O3 -Wall -pedantic-errors example.cpp utf8_console.o -o example.mingw.no-argv.exe -municode -mconsole
echo.example.cpp
g++ %2 -std=c++14 -O3 -Wall -pedantic-errors example.cpp utf8_console.o -o example.mingw.argv.exe -DUSE_ARGV -municode -mconsole
goto :DONE

:MINGW2
echo.MinGW
echo.utf8_console.cpp
g++ %2 -std=c++17 -O3 -c utf8_console.cpp -o utf8_console.o
if ERRORLEVEL 1 goto :ERROR
echo.example.cpp
g++ %2 -std=c++14 -O3 -Wall -pedantic-errors example.cpp utf8_console.o -o example.mingw.no-argv.exe
echo.example.cpp
g++ %2 -std=c++14 -O3 -Wall -pedantic-errors example.cpp utf8_console.o -o example.mingw.argv.exe -DUSE_ARGV
goto :DONE

::----------------------------------------------------------------------------
:CLANG
:: Clang++ must be in the %PATH%.
for /F "delims=" %%I in ('clang++ -dumpmachine') do set M=%%I
if not "%M:msvc=%"=="%M%" goto :CLANG1
if "%M:w64=%"=="%M%" goto :CLANG2

:CLANG1
echo.Clang-CL / Clang-w64
echo.utf8_console.cpp
clang++ %2 -std=c++17 -O3 -c utf8_console.cpp -o utf8_console.o -municode
if ERRORLEVEL 1 goto :ERROR
echo.example.cpp
clang++ %2 -std=c++14 -O3 -Wall -pedantic-errors example.cpp utf8_console.o -o example.clang.no-argv.exe -municode -mconsole
echo.example.cpp
clang++ %2 -std=c++14 -O3 -Wall -pedantic-errors example.cpp utf8_console.o -o example.clang.argv.exe -DUSE_ARGV -municode -mconsole
goto :DONE

:CLANG2
echo.Clang
echo.utf8_console.cpp
clang++ %2 -std=c++17 -O3 -c utf8_console.cpp -o utf8_console.o
if ERRORLEVEL 1 goto :ERROR
echo.example.cpp
clang++ %2 -std=c++14 -O3 -Wall -pedantic-errors example.cpp utf8_console.o -o example.clang.no-argv.exe
echo.example.cpp
clang++ %2 -std=c++14 -O3 -Wall -pedantic-errors example.cpp utf8_console.o -o example.clang.argv.exe -DUSE_ARGV
goto :DONE

::----------------------------------------------------------------------------
:CLEAN
if exist *.o   del /F/Q *.o
if exist *.obj del /F/Q *.obj
if exist *.exe del /F/Q *.exe
goto :EOF

::----------------------------------------------------------------------------
:ERROR
echo.Failure to build the utf8_console object file!
goto :EOF

::----------------------------------------------------------------------------
:DONE
if ERRORLEVEL 1 (
  echo.Failure to build the example
) else (
  echo.Success
)
goto :EOF
