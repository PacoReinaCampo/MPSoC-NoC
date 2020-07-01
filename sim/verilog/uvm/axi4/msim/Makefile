all: build

build:
	@if [ ! -e work ]; then vlib work; fi
	@vlog -sv -f system.vc
	vsim -c -do run.do work.testbench
