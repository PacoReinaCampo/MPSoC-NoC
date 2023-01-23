class peripheral_sequence extends uvm_sequence#(peripheral_sequence_item);
  peripheral_sequence_item req;
  `uvm_object_utils(peripheral_sequence)
  
  function new (string name = "peripheral_sequence");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "Base Sequence: Inside Body", UVM_LOW);
    `uvm_do(req);
  endtask
endclass