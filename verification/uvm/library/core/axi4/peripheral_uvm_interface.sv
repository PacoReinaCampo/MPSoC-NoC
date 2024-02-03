interface peripheral_uvm_interface (
    input logic clk_i
);

  logic                        rst_ni;  // Asynchronous reset active low

  logic [AXI_ID_WIDTH    -1:0] axi_aw_id;
  logic [AXI_ADDR_WIDTH  -1:0] axi_aw_addr;
  logic [                 7:0] axi_aw_len;
  logic [                 2:0] axi_aw_size;
  logic [                 1:0] axi_aw_burst;
  logic                        axi_aw_lock;
  logic [                 3:0] axi_aw_cache;
  logic [                 2:0] axi_aw_prot;
  logic [                 3:0] axi_aw_qos;
  logic [                 3:0] axi_aw_region;
  logic [AXI_USER_WIDTH  -1:0] axi_aw_user;
  logic                        axi_aw_valid;
  logic                        axi_aw_ready;

  logic [AXI_ID_WIDTH    -1:0] axi_ar_id;
  logic [AXI_ADDR_WIDTH  -1:0] axi_ar_addr;
  logic [                 7:0] axi_ar_len;
  logic [                 2:0] axi_ar_size;
  logic [                 1:0] axi_ar_burst;
  logic                        axi_ar_lock;
  logic [                 3:0] axi_ar_cache;
  logic [                 2:0] axi_ar_prot;
  logic [                 3:0] axi_ar_qos;
  logic [                 3:0] axi_ar_region;
  logic [AXI_USER_WIDTH  -1:0] axi_ar_user;
  logic                        axi_ar_valid;
  logic                        axi_ar_ready;

  logic [AXI_DATA_WIDTH  -1:0] axi_w_data;
  logic [AXI_STRB_WIDTH  -1:0] axi_w_strb;
  logic                        axi_w_last;
  logic [AXI_USER_WIDTH  -1:0] axi_w_user;
  logic                        axi_w_valid;
  logic                        axi_w_ready;

  logic [AXI_ID_WIDTH    -1:0] axi_r_id;
  logic [AXI_DATA_WIDTH  -1:0] axi_r_data;
  logic [                 1:0] axi_r_resp;
  logic                        axi_r_last;
  logic [AXI_USER_WIDTH  -1:0] axi_r_user;
  logic                        axi_r_valid;
  logic                        axi_r_ready;

  logic [AXI_ID_WIDTH    -1:0] axi_b_id;
  logic [                 1:0] axi_b_resp;
  logic [AXI_USER_WIDTH  -1:0] axi_b_user;
  logic                        axi_b_valid;
  logic                        axi_b_ready;

  // Clocking block and modport declaration for driver
  clocking dr_cb @(posedge clk_i);
    output rst_ni;  // Asynchronous reset active low

    output axi_aw_id;
    output axi_aw_addr;
    output axi_aw_len;
    output axi_aw_size;
    output axi_aw_burst;
    output axi_aw_lock;
    output axi_aw_cache;
    output axi_aw_prot;
    output axi_aw_qos;
    output axi_aw_region;
    output axi_aw_user;
    output axi_aw_valid;
    input  axi_aw_ready;

    output axi_ar_id;
    output axi_ar_addr;
    output axi_ar_len;
    output axi_ar_size;
    output axi_ar_burst;
    output axi_ar_lock;
    output axi_ar_cache;
    output axi_ar_prot;
    output axi_ar_qos;
    output axi_ar_region;
    output axi_ar_user;
    output axi_ar_valid;
    input  axi_ar_ready;

    output axi_w_data;
    output axi_w_strb;
    output axi_w_last;
    output axi_w_user;
    output axi_w_valid;
    input  axi_w_ready;

    input  axi_r_id;
    input  axi_r_data;
    input  axi_r_resp;
    input  axi_r_last;
    input  axi_r_user;
    input  axi_r_valid;
    output axi_r_ready;

    input  axi_b_id;
    input  axi_b_resp;
    input  axi_b_user;
    input  axi_b_valid;
    output axi_b_ready;
  endclocking

  modport DRV(clocking dr_cb, input clk_i);

  // Clocking block and modport declaration for monitor
  clocking rc_cb @(negedge clk_i);
    input rst_ni;  // Asynchronous reset active low

    input axi_aw_id;
    input axi_aw_addr;
    input axi_aw_len;
    input axi_aw_size;
    input axi_aw_burst;
    input axi_aw_lock;
    input axi_aw_cache;
    input axi_aw_prot;
    input axi_aw_qos;
    input axi_aw_region;
    input axi_aw_user;
    input axi_aw_valid;
    input axi_aw_ready;

    input axi_ar_id;
    input axi_ar_addr;
    input axi_ar_len;
    input axi_ar_size;
    input axi_ar_burst;
    input axi_ar_lock;
    input axi_ar_cache;
    input axi_ar_prot;
    input axi_ar_qos;
    input axi_ar_region;
    input axi_ar_user;
    input axi_ar_valid;
    input axi_ar_ready;

    input axi_w_data;
    input axi_w_strb;
    input axi_w_last;
    input axi_w_user;
    input axi_w_valid;
    input axi_w_ready;

    input axi_r_id;
    input axi_r_data;
    input axi_r_resp;
    input axi_r_last;
    input axi_r_user;
    input axi_r_valid;
    input axi_r_ready;

    input axi_b_id;
    input axi_b_resp;
    input axi_b_user;
    input axi_b_valid;
    input axi_b_ready;
  endclocking

  modport RCV(clocking rc_cb, input clk_i);
endinterface
