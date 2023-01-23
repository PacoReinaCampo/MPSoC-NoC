class peripheral_sequence_item extends uvm_sequence_item;
  rand bit [7:0] ip1;
  rand bit [7:0] ip2;

  bit [8:0] out;
  
  function new(string name = "peripheral_sequence_item");
    super.new(name);
  endfunction
  
  `uvm_object_utils_begin(peripheral_sequence_item)
    `uvm_field_int(ip1,UVM_ALL_ON)
    `uvm_field_int(ip2,UVM_ALL_ON)
  `uvm_object_utils_end
  
  constraint ip_c {ip1 < 100; ip2 < 100;}
endclass