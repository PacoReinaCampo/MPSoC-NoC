@echo off
call ../../../../../../settings64_msim.bat

vlib work
vlog -sv -stats=none +incdir+../../../../../../uvm/src -f system.verilog.vc
vcom -2008 -f system.vhdl.vc
vsim -c -do run.do work.testbench
pause
