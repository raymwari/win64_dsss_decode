@echo off
if exist main.exe (del main.exe)
nasm -f win64 main.asm
nasm -f win64 dec.asm
golink /console /entry _main main.obj dec.obj ecodes.obj kernel32.dll
main.exe
if exist main.exe (del main.obj dec.obj)
if exist main.exe (main.exe)