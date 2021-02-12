@echo off
call ../../../../../../settings64_msim.bat

vlib work
vlog -sv -stats=none +incdir+../../../../../../uvm/src -f system.vc
vsim -c -do run.do work.testbench
pause
