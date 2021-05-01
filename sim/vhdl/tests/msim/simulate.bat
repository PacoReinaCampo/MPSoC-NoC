@echo off
call ../../../../settings64_msim.bat

vlib work
vcom -2008 -f system.vc
vsim -c -do run.do work.peripheral_noc_mesh4d
pause
