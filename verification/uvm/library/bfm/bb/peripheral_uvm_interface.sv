interface peripheral_uvm_interface (
    input logic mclk
);

    logic          rst;  // RAM reset

    logic [AW-1:0] addr;  // RAM address
    logic [DW-1:0] dout;  // RAM data output
    logic [DW-1:0] din;   // RAM data input
    logic          cen;   // RAM chip enable (low active)
    logic [   1:0] wen;   // RAM write enable (low active)

  // Clocking block and modport declaration for driver
  clocking dr_cb @(posedge mclk);
    output rst;   // RAM reset
 
    output addr;  // RAM address
    input  dout;  // RAM data output
    output din;   // RAM data input
    output cen;   // RAM chip enable (low active)
    output wen;   // RAM write enable (low active)
  endclocking

  modport DRV(clocking dr_cb, input mclk);

  // Clocking block and modport declaration for monitor
  clocking rc_cb @(negedge mclk);
    input rst;  // RAM reset

    input addr;  // RAM address
    input dout;  // RAM data output
    input din;   // RAM data input
    input cen;   // RAM chip enable (low active)
    input wen;   // RAM write enable (low active)
  endclocking

  modport RCV(clocking rc_cb, input mclk);
endinterface
