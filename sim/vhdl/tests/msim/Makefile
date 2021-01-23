all: build simulate

build:
	if [ ! -e work ]; then vlib work; fi
	vcom -2008 -f system.vc

simulate:
	vsim -c -do run.do work.mpsoc_noc_testbench

clean:
	rm -rf work transcript
