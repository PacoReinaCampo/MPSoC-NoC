interface peripheral_uvm_interface (
    input logic pclk
);

  logic        presetn;

  logic [31:0] paddr;
  logic [ 1:0] pstrb;
  logic        pwrite;
  logic        pready;
  logic        psel;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic        penable;
  logic        pslverr;

  // Clocking block and modport declaration for driver
  clocking dr_cb @(posedge pclk);
    output presetn;

    output paddr;
    output pstrb;
    output pwrite;
    input  pready;
    output psel;
    output pwdata;
    input  prdata;
    output penable;
    input  pslverr;
  endclocking

  modport DRV(clocking dr_cb, input pclk);

  // Clocking block and modport declaration for monitor
  clocking rc_cb @(negedge pclk);
    input presetn;

    input paddr;
    input pstrb;
    input pwrite;
    input pready;
    input psel;
    input pwdata;
    input prdata;
    input penable;
    input pslverr;
  endclocking

  modport RCV(clocking rc_cb, input pclk);
endinterface
