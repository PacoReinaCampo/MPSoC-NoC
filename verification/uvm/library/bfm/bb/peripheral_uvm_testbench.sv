// Adder RTL verified with UVM
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "peripheral_uvm_agent.sv"
`include "peripheral_uvm_coverage.sv"
`include "peripheral_uvm_environment.sv"
`include "peripheral_uvm_interface.sv"
`include "peripheral_uvm_sequence.sv"
`include "peripheral_uvm_test.sv"

import peripheral_bb_pkg::*;

module peripheral_uvm_testbench;
  // Declaration of Local Fields
  bit mclk;

  // Clock Generation
  always #1 mclk = ~mclk;

  initial begin
    mclk = 0;
  end

  // Creatinng instance of interface, in order to connect DUT and testcase
  peripheral_uvm_interface vif (mclk);

  // BlackBone Memory DUT Instantation
  peripheral_design #(
    .AW      (AW),       // Address bus
    .DW      (DW),       // Data bus

    .MEMMORY_SIZE(MEMORY_SIZE)  // Memory Size
  ) dut (
    .mclk (vif.mclk),  // RAM clock
    .rst (vif.rst),  // Asynchronous Reset - active low

    .addr(vif.addr),  // RAM address
    .dout(vif.dout),  // RAM data output
    .din (vif.din),   // RAM data input
    .cen (vif.cen),   // RAM chip enable (low active)
    .wen (vif.wen)    // RAM write enable (low active)
  );

  // Starting the execution uvm phases
  initial begin
    run_test();
  end

  initial begin
    // Set the Interface instance Using Configuration Database
    uvm_config_db#(virtual peripheral_uvm_interface)::set(uvm_root::get(), "*", "intf", vif);

    // Enable wave dump
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

endmodule
