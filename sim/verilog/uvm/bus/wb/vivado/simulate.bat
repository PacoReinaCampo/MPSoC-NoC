@echo off
call ../../../../../../settings64_vivado.bat

xvlog -i ../../../../../../uvm/src -prj system.prj
xelab test
xsim -R test
pause
