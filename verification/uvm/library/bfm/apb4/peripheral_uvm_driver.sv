`include "peripheral_uvm_transaction.sv"

import peripheral_apb4_pkg::*;

class peripheral_uvm_driver extends uvm_driver #(peripheral_uvm_transaction);
  // Declaration of component utils to register with factory
  peripheral_uvm_transaction       transaction;

  // Declaration of Virtual interface
  virtual peripheral_uvm_interface vif;

  // Declaration of component utils to register with factory
  `uvm_component_utils(peripheral_uvm_driver)

  uvm_analysis_port #(peripheral_uvm_transaction) driver2rm_port;

  // Method name : new
  // Description : constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Method name : build_phase
  // Description : construct the components
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual peripheral_uvm_interface)::get(this, "", "intf", vif)) begin
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    end
    driver2rm_port = new("driver2rm_port", this);
  endfunction : build_phase

  // Method name : run_phase
  // Description : Drive the transaction info to DUT
  virtual task run_phase(uvm_phase phase);
    reset();
    forever begin
      seq_item_port.get_next_item(req);
      write_drive();
      read_drive();
      `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM DRIVER"), UVM_LOW);
      req.print();
      @(vif.dr_cb);
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      driver2rm_port.write(rsp);
      seq_item_port.item_done();
      seq_item_port.put(rsp);
    end
  endtask : run_phase

  // Method name : drive
  // Description : Driving the dut inputs
  task write_drive();
    begin
      @(posedge vif.pclk);
      vif.dr_cb.paddr  <= req.address;
      vif.dr_cb.pwrite <= 1;
      vif.dr_cb.psel   <= 1;
      vif.dr_cb.pwdata <= req.pwdata;

      @(posedge vif.pclk);
      vif.dr_cb.psel    <= 1;
      vif.dr_cb.penable <= 1;

      @(posedge vif.pclk);
      vif.dr_cb.psel    <= 0;
      vif.dr_cb.penable <= 0;
    end
  endtask

  task read_drive();
    begin
      @(posedge vif.pclk);
      vif.dr_cb.pwrite  <= 0;
      vif.dr_cb.psel    <= 1;
      vif.dr_cb.penable <= 0;

      @(posedge vif.pclk);
      vif.dr_cb.paddr   <= req.address;
      vif.dr_cb.psel    <= 1;
      vif.dr_cb.penable <= 1;

      @(posedge vif.pclk);
      vif.dr_cb.psel    <= 0;
      vif.dr_cb.penable <= 0;
    end
  endtask

  // Method name : reset
  // Description : Driving the dut inputs
  task reset();
    vif.dr_cb.presetn <= 1;  // Active HIGH

    vif.dr_cb.paddr   <= 0;
    vif.dr_cb.pstrb   <= 0;
    vif.dr_cb.pwrite  <= 0;
    vif.dr_cb.psel    <= 0;
    vif.dr_cb.pwdata  <= 0;
    vif.dr_cb.penable <= 0;

    repeat (5) @(posedge vif.pclk);

    vif.dr_cb.presetn <= 0;  // Inactive LOW
  endtask
endclass : peripheral_uvm_driver
