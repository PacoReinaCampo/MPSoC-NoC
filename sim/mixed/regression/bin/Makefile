all: build

build:
	@if [ ! -e work ]; then vlib work; fi
	@vlog -sv +incdir+../../../../rtl/verilog/pkg -f noc_verilog.vc
	@vcom -2008 -f noc_vhdl.vc
	vsim -c -do run.do work.riscv_noc_mesh_testbench
