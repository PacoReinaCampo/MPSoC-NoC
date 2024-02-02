import peripheral_bb_pkg::*;

class peripheral_uvm_monitor extends uvm_monitor;
  // Declaration of Virtual interface
  virtual peripheral_uvm_interface                vif;

  // Declaration of Analysis ports and exports
  uvm_analysis_port #(peripheral_uvm_transaction) monitor2scoreboard_port;

  // Declaration of transaction item
  peripheral_uvm_transaction                      act_transaction;

  // Declaration of component utils to register with factory
  `uvm_component_utils(peripheral_uvm_monitor)

  // Method name : new
  // Description : constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_transaction         = new();
    monitor2scoreboard_port = new("monitor2scoreboard_port", this);
  endfunction : new

  // Method name : build_phase
  // Description : construct the components
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual peripheral_uvm_interface)::get(this, "", "intf", vif)) begin
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    end
  endfunction : build_phase

  // Method name : run_phase
  // Description : Extract the info from DUT via interface
  virtual task run_phase(uvm_phase phase);
    forever begin
      collect_write_transaction();
      collect_read_transaction();
      monitor2scoreboard_port.write(act_transaction);
    end
  endtask : run_phase

  // Method name : collect_actual_trans
  // Description : run task for collecting peripheral_adder transactions
  task collect_write_transaction();
    begin
      @(posedge vif.mclk);

      act_transaction.addr <= vif.rc_cb.addr;
      act_transaction.din  <= vif.rc_cb.din;
      act_transaction.dout <= vif.rc_cb.dout;
      act_transaction.cen  <= vif.rc_cb.cen;
      act_transaction.wen  <= vif.rc_cb.wen;

      @(posedge vif.mclk);
      act_transaction.cen  <= vif.rc_cb.cen;
    end
  endtask

  task collect_read_transaction();
    begin
      act_transaction.addr <= vif.rc_cb.addr;
      act_transaction.din  <= vif.rc_cb.din;
      act_transaction.dout <= vif.rc_cb.dout;
      act_transaction.cen  <= vif.rc_cb.cen;
      act_transaction.wen  <= vif.rc_cb.wen;

      @(posedge vif.mclk);
      act_transaction.cen  <= vif.rc_cb.cen;
    end
  endtask
endclass : peripheral_uvm_monitor
