@echo off
call ../../../../settings64_ghdl.bat

ghdl -a --std=08 ../../../../rtl/vhdl/pkg/vhdl_pkg.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/peripheral_arbiter_rr.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/peripheral_noc_buffer.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/peripheral_noc_demux.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/peripheral_noc_mux.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/core/peripheral_noc_vchannel_mux.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/peripheral_noc_router_input.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/peripheral_noc_router_lookup_slice.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/peripheral_noc_router_lookup.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/peripheral_noc_router_output.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/router/peripheral_noc_router.vhd
ghdl -a --std=08 ../../../../rtl/vhdl/topology/peripheral_noc_mesh4d.vhd
ghdl -a --std=08 ../../../../bench/vhdl/tests/peripheral_noc_testbench.vhd
ghdl -m --std=08 peripheral_noc_testbench
ghdl -r --std=08 peripheral_noc_testbench --ieee-asserts=disable-at-0 --disp-tree=inst > peripheral_noc_testbench.tree
pause
