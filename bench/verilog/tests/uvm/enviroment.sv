class peripheral_enviroment extends uvm_env;
  `uvm_component_utils(peripheral_enviroment)
  peripheral_agent agent;
  peripheral_scoreboard scoreboard;
 
  function new(string name = "peripheral_enviroment", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = peripheral_agent::type_id::create("agent", this);
    scoreboard = peripheral_scoreboard::type_id::create("scoreboard", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    agent.monitor.item_collect_port.connect(scoreboard.item_collect_export);
  endfunction
endclass