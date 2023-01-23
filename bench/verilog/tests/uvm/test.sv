`include "peripheral_package.sv"

class peripheral_test extends uvm_test;
  peripheral_enviroment enviroment;
  peripheral_sequence base_sequence;
  `uvm_component_utils(peripheral_test)
  
  function new(string name = "peripheral_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    enviroment = peripheral_enviroment::type_id::create("enviroment", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    base_sequence = peripheral_sequence::type_id::create("base_sequence");
        
    repeat(10) begin 
      #5; base_sequence.start(enviroment.agent.sequencer);
    end
    
    phase.drop_objection(this);
    `uvm_info(get_type_name, "End of TestCase", UVM_LOW);
  endtask
endclass
