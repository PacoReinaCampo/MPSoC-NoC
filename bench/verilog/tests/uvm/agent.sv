class peripheral_agent extends uvm_agent;
  `uvm_component_utils(peripheral_agent)
  peripheral_driver driver;
  peripheral_sequencer sequencer;
  peripheral_monitor monitor;
  
  function new(string name = "peripheral_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(get_is_active == UVM_ACTIVE) begin 
      driver = peripheral_driver::type_id::create("driver", this);
      sequencer = peripheral_sequencer::type_id::create("sequencer", this);
    end
    
    monitor = peripheral_monitor::type_id::create("monitor", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    if(get_is_active == UVM_ACTIVE) begin 
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
endclass