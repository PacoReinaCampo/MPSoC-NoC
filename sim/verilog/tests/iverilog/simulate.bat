@echo off
call ../../../../settings64_iverilog.bat

iverilog -g2012 -o system.vvp -c system.vc -s peripheral_noc_testbench
vvp system.vvp
pause
