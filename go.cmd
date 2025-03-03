@echo off
if .%USERDOMAIN% == .kipra goto :my_pc
set PATH=C:\PROGRA~2\Dev-Cpp\MinGW64\bin\;%PATH%
mingw32-make.exe
goto :exe

:my_pc
make

:exe
program.exe > program.txt
echo Results have been saved to test.txt