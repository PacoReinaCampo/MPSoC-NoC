all: build

build:
	@if [ ! -e work ]; then vlib work; fi
	@vlog -sv -f system.vc
	vsim -c -do run.do work.mpsoc_noc_testbench
