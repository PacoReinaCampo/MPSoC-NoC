import peripheral_apb4_pkg::*;

class peripheral_uvm_transaction extends uvm_sequence_item;
  // Declaration of peripheral_adder transaction fields
  bit                       presetn;

  rand bit [PADDR_SIZE-1:0] paddr;
  bit      [           1:0] pstrb;
  bit                       pwrite;
  bit                       pready;
  bit                       psel;
  rand bit [PDATA_SIZE-1:0] pwdata;
  bit      [PDATA_SIZE-1:0] prdata;
  bit                       penable;
  bit                       pslverr;

  rand bit [PADDR_SIZE-1:0] address;  // Target Address

  // Declaration of Utility and Field macros
  `uvm_object_utils_begin(peripheral_uvm_transaction)

  // Global Signals
  `uvm_field_int(presetn, UVM_ALL_ON)

  `uvm_field_int(paddr, UVM_ALL_ON)
  `uvm_field_int(pstrb, UVM_ALL_ON)
  `uvm_field_int(pwrite, UVM_ALL_ON)
  `uvm_field_int(pready, UVM_ALL_ON)
  `uvm_field_int(psel, UVM_ALL_ON)
  `uvm_field_int(pwdata, UVM_ALL_ON)
  `uvm_field_int(prdata, UVM_ALL_ON)
  `uvm_field_int(penable, UVM_ALL_ON)
  `uvm_field_int(pslverr, UVM_ALL_ON)

  `uvm_field_int(address, UVM_ALL_ON)  // Target Address

  `uvm_object_utils_end

  // Constructor
  function new(string name = "peripheral_uvm_transaction");
    super.new(name);
  endfunction

  // Declaration of Constraints
  constraint paddr_c {paddr inside {[32'h00000000 : 32'hFFFFFFFF]};}
  constraint pwdata_c {pwdata inside {[32'h00000000 : 32'hFFFFFFFF]};}

  constraint address_c {address inside {[32'h00000000 : 32'hFFFFFFFF]};}

  // Method name : post_randomize();
  // Description : To display transaction info after randomization
  function void post_randomize();
  endfunction
endclass
