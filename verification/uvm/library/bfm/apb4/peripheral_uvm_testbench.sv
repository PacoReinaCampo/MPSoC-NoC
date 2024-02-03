// Adder RTL verified with UVM
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "peripheral_uvm_agent.sv"
`include "peripheral_uvm_coverage.sv"
`include "peripheral_uvm_environment.sv"
`include "peripheral_uvm_interface.sv"
`include "peripheral_uvm_sequence.sv"
`include "peripheral_uvm_test.sv"

module peripheral_uvm_testbench;
  // Declaration of Local Fields
  bit pclk;

  // Clock Generation
  always #1 pclk = ~pclk;

  initial begin
    pclk = 0;
  end

  // Creatinng instance of interface, in order to connect DUT and testcase
  peripheral_uvm_interface vif (pclk);

  // Peripheral_adder DUT Instantation
  peripheral_design dut (
    .pclk   (vif.pclk),
    .presetn(vif.presetn),

    .paddr  (vif.paddr),
    .pstrb  (vif.pstrb),
    .pwrite (vif.pwrite),
    .pready (vif.pready),
    .psel   (vif.psel),
    .pwdata (vif.pwdata),
    .prdata (vif.prdata),
    .penable(vif.penable),
    .pslverr(vif.pslverr)
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
