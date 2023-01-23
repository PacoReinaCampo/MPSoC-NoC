`include "uvm_macros.svh"

import uvm_pkg::*;

`include "peripheral_interface.sv"
`include "peripheral_test.sv"

module testbench;
  bit clk;
  bit rst;

  always #2 clk = ~clk;
  
  initial begin
    //clk = 0;
    rst = 1;
    #5; 
    rst = 0;
  end

  add_if vif(clk, rst);
  
  adder DUT(
    .clk(vif.clk),
    .rst(vif.rst),

    .in1(vif.ip1),
    .in2(vif.ip2),

    .out(vif.out)
  );
  
  initial begin
    // set interface in config_db
    uvm_config_db#(virtual add_if)::set(uvm_root::get(), "*", "vif", vif);
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

  initial begin
    run_test("peripheral_test");
  end
endmodule
