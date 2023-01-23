class peripheral_monitor extends uvm_monitor;
  virtual add_if vif;
  uvm_analysis_port #(peripheral_sequence_item) item_collect_port;
  peripheral_sequence_item monitor_item;
  `uvm_component_utils(peripheral_monitor)
  
  function new(string name = "peripheral_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collect_port = new("item_collect_port", this);
    monitor_item = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual add_if) :: get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Not set at top level");
  endfunction
  
  task run_phase (uvm_phase phase);
    forever begin
      wait(!vif.rst);
      @(posedge vif.clk);
      monitor_item.ip1 = vif.ip1;
      monitor_item.ip2 = vif.ip2;
      `uvm_info(get_type_name, $sformatf("ip1 = %0d, ip2 = %0d", monitor_item.ip1, monitor_item.ip2), UVM_HIGH);
      @(posedge vif.clk);
      monitor_item.out = vif.out;
      item_collect_port.write(monitor_item);
    end
  endtask
endclass