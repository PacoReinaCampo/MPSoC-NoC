@echo off
call ../../../../../../settings64_msim.bat

vlib work
vlog -sv -f system.vc
vsim -c -do run.do work.mpsoc_noc_testbench
pause
