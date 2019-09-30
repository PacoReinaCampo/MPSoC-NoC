all: build

build:
	@if [ ! -e work ]; then vlib work; fi
	@vlog -sv +incdir+../../../../rtl/verilog/pkg -f noc.vc
	vsim -c -do run.do work.riscv_noc_mesh_testbench
