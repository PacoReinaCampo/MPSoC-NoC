all: build

build:
	@if [ ! -e work ]; then vlib work; fi
	@vlog -sv -f noc_verilog.vc
	@vcom -2008 -f noc_vhdl.vc
	vsim -c -do run.do work.mpsoc_noc_testbench
