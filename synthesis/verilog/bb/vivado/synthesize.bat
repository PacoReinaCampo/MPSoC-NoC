@echo off
REM #################################################################
REM # Copyright (c) 1986-2020 Xilinx, Inc.  All rights reserved.    #
REM #################################################################

call ../../../../settings64_vivado.bat

vivado -nojournal -log system.log -mode batch -source system.tcl
pause