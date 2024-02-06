import peripheral_bb_pkg::*;

class peripheral_uvm_transaction extends uvm_sequence_item;
  // Declaration of peripheral_adder transaction fields
  bit               rst;  // Asynchronous reset active low

  rand bit [AW-1:0] addr;  // RAM address
  bit      [DW-1:0] dout;  // RAM data input
  rand bit [DW-1:0] din;   // RAM data output
  bit               cen;   // RAM chip enable (low active)
  bit      [   1:0] wen;   // RAM write enable (low active)

  rand bit [31:0] address;  // Target Address

  // Declaration of Utility and Field macros
  `uvm_object_utils_begin(peripheral_uvm_transaction)

  `uvm_field_int(rst, UVM_ALL_ON)  // Asynchronous reset active low

  `uvm_field_int(addr, UVM_ALL_ON)
  `uvm_field_int(dout, UVM_ALL_ON)
  `uvm_field_int(din, UVM_ALL_ON)
  `uvm_field_int(cen, UVM_ALL_ON)
  `uvm_field_int(wen, UVM_ALL_ON)

  `uvm_field_int(address, UVM_ALL_ON)

  `uvm_object_utils_end

  // Constructor
  function new(string name = "peripheral_uvm_transaction");
    super.new(name);
  endfunction

  // Declaration of Constraints
  constraint addr_c {addr inside {[32'h00000000 : 32'hFFFFFFFF]};}
  constraint din_c {din inside {[32'h00000000 : 32'hFFFFFFFF]};}

  constraint address_c {address inside {[32'h00000000 : 32'hFFFFFFFF]};}

  // Method name : post_randomize();
  // Description : To display transaction info after randomization
  function void post_randomize();
  endfunction
endclass
