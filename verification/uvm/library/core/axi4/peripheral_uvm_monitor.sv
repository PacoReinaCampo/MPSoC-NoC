import peripheral_axi4_pkg::*;

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
      // Operate in a synchronous manner
      @(posedge vif.clk_i);

      // Address Phase
      act_transaction.axi_aw_id    <= vif.rc_cb.axi_aw_id;
      act_transaction.axi_aw_addr  <= vif.rc_cb.axi_aw_addr;
      act_transaction.axi_aw_valid <= vif.rc_cb.axi_aw_valid;
      act_transaction.axi_aw_len   <= vif.rc_cb.axi_aw_len;
      act_transaction.axi_aw_size  <= vif.rc_cb.axi_aw_size;
      act_transaction.axi_aw_burst <= vif.rc_cb.axi_aw_burst;
      act_transaction.axi_aw_lock  <= vif.rc_cb.axi_aw_lock;
      act_transaction.axi_aw_cache <= vif.rc_cb.axi_aw_cache;
      act_transaction.axi_aw_prot  <= vif.rc_cb.axi_aw_prot;
      @(posedge vif.axi_aw_ready);

      // Data Phase
      act_transaction.axi_aw_valid <= vif.rc_cb.axi_aw_valid;
      act_transaction.axi_aw_addr  <= vif.rc_cb.axi_aw_addr;
      act_transaction.axi_aw_id    <= vif.rc_cb.axi_aw_id;
      act_transaction.axi_aw_valid <= vif.rc_cb.axi_aw_valid;
      act_transaction.axi_w_data   <= vif.rc_cb.axi_w_data;
      act_transaction.axi_w_strb   <= vif.rc_cb.axi_w_strb;
      act_transaction.axi_w_last   <= vif.rc_cb.axi_w_last;
      @(posedge vif.axi_aw_ready);

      // Response Phase
      act_transaction.axi_aw_id    <= vif.rc_cb.axi_aw_id;
      act_transaction.axi_aw_valid <= vif.rc_cb.axi_aw_valid;
      act_transaction.axi_w_data   <= vif.rc_cb.axi_w_data;
      act_transaction.axi_w_strb   <= vif.rc_cb.axi_w_strb;
      act_transaction.axi_w_last   <= vif.rc_cb.axi_w_last;
    end
  endtask

  task collect_read_transaction();
    begin
      // Address Phase
      act_transaction.axi_ar_id    <= vif.rc_cb.axi_ar_id;
      act_transaction.axi_ar_addr  <= vif.rc_cb.axi_aw_addr;
      act_transaction.axi_ar_valid <= vif.rc_cb.axi_ar_valid;
      act_transaction.axi_ar_len   <= vif.rc_cb.axi_ar_len;
      act_transaction.axi_ar_size  <= vif.rc_cb.axi_ar_size;
      act_transaction.axi_ar_lock  <= vif.rc_cb.axi_ar_lock;
      act_transaction.axi_ar_cache <= vif.rc_cb.axi_ar_cache;
      act_transaction.axi_ar_prot  <= vif.rc_cb.axi_ar_prot;
      act_transaction.axi_r_ready  <= vif.rc_cb.axi_r_ready;
      @(posedge vif.axi_ar_ready);

      // Data Phase
      act_transaction.axi_ar_valid <= vif.rc_cb.axi_ar_valid;
      act_transaction.axi_r_ready  <= vif.rc_cb.axi_r_ready;
      @(posedge vif.axi_r_valid);

      act_transaction.axi_r_ready <= vif.rc_cb.axi_r_ready;
      act_transaction.axi_r_data  <= vif.rc_cb.axi_r_data;
      @(negedge vif.axi_r_valid);

      act_transaction.axi_ar_addr <= vif.rc_cb.axi_ar_addr;
    end
  endtask
endclass : peripheral_uvm_monitor
