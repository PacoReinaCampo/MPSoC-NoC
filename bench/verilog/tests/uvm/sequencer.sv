class peripheral_sequencer extends uvm_sequencer#(peripheral_sequence_item);
  `uvm_component_utils(peripheral_sequencer)
  
  function new(string name = "peripheral_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass