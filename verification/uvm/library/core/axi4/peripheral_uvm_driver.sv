`include "peripheral_uvm_transaction.sv"

import peripheral_axi4_pkg::*;

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
      // Operate in a synchronous manner
      @(posedge vif.clk_i);

      // Address Phase
      vif.dr_cb.axi_aw_id    <= 0;
      vif.dr_cb.axi_aw_addr  <= req.address;
      vif.dr_cb.axi_aw_valid <= 1;
      vif.dr_cb.axi_aw_len   <= AXI_BURST_LENGTH_1;
      vif.dr_cb.axi_aw_size  <= AXI_BURST_SIZE_WORD;
      vif.dr_cb.axi_aw_burst <= AXI_BURST_TYPE_FIXED;
      vif.dr_cb.axi_aw_lock  <= AXI_LOCK_NORMAL;
      vif.dr_cb.axi_aw_cache <= 0;
      vif.dr_cb.axi_aw_prot  <= AXI_PROTECTION_NORMAL;
      @(posedge vif.axi_aw_ready);

      // Data Phase
      vif.dr_cb.axi_aw_valid <= 0;
      vif.dr_cb.axi_aw_addr  <= 'bX;
      vif.dr_cb.axi_aw_id    <= 0;
      vif.dr_cb.axi_w_valid  <= 1;
      vif.dr_cb.axi_w_data   <= req.axi_w_data;
      vif.dr_cb.axi_w_strb   <= 4'hF;
      vif.dr_cb.axi_w_last   <= 1;
      @(posedge vif.axi_w_ready);

      // Response Phase
      vif.dr_cb.axi_aw_id   <= 0;
      vif.dr_cb.axi_w_valid <= 0;
      vif.dr_cb.axi_w_data  <= 'bX;
      vif.dr_cb.axi_w_strb  <= 0;
      vif.dr_cb.axi_w_last  <= 0;
    end
  endtask

  task read_drive();
    begin
      // Address Phase
      vif.dr_cb.axi_ar_id    <= 0;
      vif.dr_cb.axi_ar_addr  <= req.address;
      vif.dr_cb.axi_ar_valid <= 1;
      vif.dr_cb.axi_ar_len   <= AXI_BURST_LENGTH_1;
      vif.dr_cb.axi_ar_size  <= AXI_BURST_SIZE_WORD;
      vif.dr_cb.axi_ar_lock  <= AXI_LOCK_NORMAL;
      vif.dr_cb.axi_ar_cache <= 0;
      vif.dr_cb.axi_ar_prot  <= AXI_PROTECTION_NORMAL;
      vif.dr_cb.axi_r_ready  <= 0;
      @(posedge vif.axi_ar_ready);

      // Data Phase
      vif.dr_cb.axi_ar_valid <= 0;
      vif.dr_cb.axi_r_ready  <= 1;
      @(posedge vif.axi_r_valid);

      vif.dr_cb.axi_r_ready <= 0;
      @(negedge vif.axi_r_valid);

      vif.dr_cb.axi_ar_addr <= 'bx;
    end
  endtask

  // Method name : reset
  // Description : Driving the dut inputs
  task reset();
    // Global Signals
    vif.dr_cb.rst_ni <= 0;  // Active LOW

    vif.dr_cb.axi_aw_id <= 0;
    vif.dr_cb.axi_aw_addr <= 0;
    vif.dr_cb.axi_aw_len <= 0;
    vif.dr_cb.axi_aw_size <= 0;
    vif.dr_cb.axi_aw_burst <= 0;
    vif.dr_cb.axi_aw_lock <= 0;
    vif.dr_cb.axi_aw_cache <= 0;
    vif.dr_cb.axi_aw_prot <= 0;
    vif.dr_cb.axi_aw_qos <= 0;
    vif.dr_cb.axi_aw_region <= 0;
    vif.dr_cb.axi_aw_user <= 0;
    vif.dr_cb.axi_aw_valid <= 0;

    vif.dr_cb.axi_ar_id <= 0;
    vif.dr_cb.axi_ar_addr <= 0;
    vif.dr_cb.axi_ar_len <= 0;
    vif.dr_cb.axi_ar_size <= 0;
    vif.dr_cb.axi_ar_burst <= 0;
    vif.dr_cb.axi_ar_lock <= 0;
    vif.dr_cb.axi_ar_cache <= 0;
    vif.dr_cb.axi_ar_prot <= 0;
    vif.dr_cb.axi_ar_qos <= 0;
    vif.dr_cb.axi_ar_region <= 0;
    vif.dr_cb.axi_ar_user <= 0;
    vif.dr_cb.axi_ar_valid <= 0;

    vif.dr_cb.axi_w_data <= 0;
    vif.dr_cb.axi_w_strb <= 0;
    vif.dr_cb.axi_w_last <= 0;
    vif.dr_cb.axi_w_user <= 0;
    vif.dr_cb.axi_w_valid <= 0;

    vif.dr_cb.axi_r_ready <= 0;

    vif.dr_cb.axi_b_ready <= 0;

    repeat (5) @(posedge vif.clk_i);

    vif.dr_cb.rst_ni <= 1;  // Inactive HIGH
  endtask
endclass : peripheral_uvm_driver
