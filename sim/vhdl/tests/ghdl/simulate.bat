@echo off
call ../../../../settings64_ghdl.bat

ghdl -a --std=08 ../../../../rtl/vhdl/pkg/mpsoc_noc_pkg.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/arb_rr.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/noc_buffer.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/noc_demux.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/noc_mux.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/noc_vchannel_mux.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/noc_router_input.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/noc_router_lookup_slice.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/noc_router_lookup.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/noc_router_output.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/noc_router.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/topology/noc_mesh4d.vhd
ghdl -a --std=08 ../../../../bench/vhdl/tests/mpsoc_noc_testbench.vhd
ghdl -m --std=08 mpsoc_noc_testbench
ghdl -r --std=08 mpsoc_noc_testbench --ieee-asserts=disable-at-0 --disp-tree=inst > mpsoc_noc_testbench.tree
pause
