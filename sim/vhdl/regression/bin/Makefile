all: build

build:
	@if [ ! -e work ]; then vlib work; fi
	@vcom -2008 -f noc.vc
	vsim -c -do run.do work.mpsoc_noc_mesh
