@echo off
call ../../../../settings64_yosys.bat

yosys -s system.ys
pause