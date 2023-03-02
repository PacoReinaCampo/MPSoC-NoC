###################################################################################
##                                            __ _      _     _                  ##
##                                           / _(_)    | |   | |                 ##
##                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |                 ##
##               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |                 ##
##              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |                 ##
##               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|                 ##
##                  | |                                                          ##
##                  |_|                                                          ##
##                                                                               ##
##                                                                               ##
##              Peripheral for MPSoC                                             ##
##              Multi-Processor System on Chip                                   ##
##                                                                               ##
###################################################################################

###################################################################################
##                                                                               ##
## Copyright (c) 2015-2016 by the author(s)                                      ##
##                                                                               ##
## Permission is hereby granted, free of charge, to any person obtaining a copy  ##
## of this software and associated documentation files (the "Software"), to deal ##
## in the Software without restriction, including without limitation the rights  ##
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     ##
## copies of the Software, and to permit persons to whom the Software is         ##
## furnished to do so, subject to the following conditions:                      ##
##                                                                               ##
## The above copyright notice and this permission notice shall be included in    ##
## all copies or substantial portions of the Software.                           ##
##                                                                               ##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    ##
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   ##
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, ##
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     ##
## THE SOFTWARE.                                                                 ##
##                                                                               ##
## ============================================================================= ##
## Author(s):                                                                    ##
##   Paco Reina Campo <pacoreinacampo@queenfield.tech>                           ##
##                                                                               ##
###################################################################################

all: build simulate

build:
	ghdl -a --std=08 ../../../../rtl/vhdl/pkg/core/vhdl_pkg.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/main/peripheral_arbiter_rr.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/main/peripheral_noc_buffer.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/main/peripheral_noc_demux.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/main/peripheral_noc_mux.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/main/peripheral_noc_vchannel_mux.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/router/peripheral_noc_router_input.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/router/peripheral_noc_router_lookup_slice.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/router/peripheral_noc_router_lookup.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/router/peripheral_noc_router_output.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/router/peripheral_noc_router.vhd
	ghdl -a --std=08 ../../../../rtl/vhdl/peripheral/topology/peripheral_noc_mesh4d.vhd
	ghdl -a --std=08 ../../../../bench/vhdl/tests/peripheral_noc_testbench.vhd

simulate:
	ghdl -m --std=08 peripheral_noc_testbench
	ghdl -r --std=08 peripheral_noc_testbench --ieee-asserts=disable-at-0 --disp-tree=inst > peripheral_noc_testbench.tree

clean:
	rm -f *.cf *.tree


