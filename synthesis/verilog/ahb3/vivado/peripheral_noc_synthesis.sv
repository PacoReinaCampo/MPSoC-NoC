////////////////////////////////////////////////////////////////////////////////
//                                            __ _      _     _               //
//                                           / _(_)    | |   | |              //
//                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
//               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
//              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
//               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
//                  | |                                                       //
//                  |_|                                                       //
//                                                                            //
//                                                                            //
//              MPSoC-RISCV CPU                                               //
//              Universal Asynchronous Receiver-Transmitter                   //
//              AMBA3 AHB-Lite Bus Interface                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2018-2019 by the author(s)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * =============================================================================
 * Author(s):
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

module peripheral_noc_synthesis #(
  parameter HADDR_SIZE     = 8,
  parameter HDATA_SIZE     = 32,
  parameter APB_ADDR_WIDTH = 8,
  parameter APB_DATA_WIDTH = 32,
  parameter SYNC_DEPTH     = 3
) (
  // Common signals
  input HRESETn,
  input HCLK,

  // UART AHB3
  input                         noc_HSEL,
  input      [HADDR_SIZE  -1:0] noc_HADDR,
  input      [HDATA_SIZE  -1:0] noc_HWDATA,
  output reg [HDATA_SIZE  -1:0] noc_HRDATA,
  input                         noc_HWRITE,
  input      [             2:0] noc_HSIZE,
  input      [             2:0] noc_HBURST,
  input      [             3:0] noc_HPROT,
  input      [             1:0] noc_HTRANS,
  input                         noc_HMASTLOCK,
  output reg                    noc_HREADYOUT,
  input                         noc_HREADY,
  output reg                    noc_HRESP
);

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //

  // Common signals
  logic [APB_ADDR_WIDTH -1:0] noc_PADDR;
  logic [APB_DATA_WIDTH -1:0] noc_PWDATA;
  logic                       noc_PWRITE;
  logic                       noc_PSEL;
  logic                       noc_PENABLE;
  logic [APB_DATA_WIDTH -1:0] noc_PRDATA;
  logic                       noc_PREADY;
  logic                       noc_PSLVERR;

  logic                       noc_rx_i;  // Receiver input
  logic                       noc_tx_o;  // Transmitter output

  logic                       noc_event_o;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  // DUT AHB3
  peripheral_bridge_apb2ahb #(
    .HADDR_SIZE(HADDR_SIZE),
    .HDATA_SIZE(HDATA_SIZE),
    .PADDR_SIZE(APB_ADDR_WIDTH),
    .PDATA_SIZE(APB_DATA_WIDTH),
    .SYNC_DEPTH(SYNC_DEPTH)
  ) bridge_apb2ahb (
    // AHB Slave Interface
    .HRESETn(HRESETn),
    .HCLK   (HCLK),

    .HSEL     (noc_HSEL),
    .HADDR    (noc_HADDR),
    .HWDATA   (noc_HWDATA),
    .HRDATA   (noc_HRDATA),
    .HWRITE   (noc_HWRITE),
    .HSIZE    (noc_HSIZE),
    .HBURST   (noc_HBURST),
    .HPROT    (noc_HPROT),
    .HTRANS   (noc_HTRANS),
    .HMASTLOCK(noc_HMASTLOCK),
    .HREADYOUT(noc_HREADYOUT),
    .HREADY   (noc_HREADY),
    .HRESP    (noc_HRESP),

    // APB Master Interface
    .PRESETn(HRESETn),
    .PCLK   (HCLK),

    .PSEL   (noc_PSEL),
    .PENABLE(noc_PENABLE),
    .PPROT  (),
    .PWRITE (noc_PWRITE),
    .PSTRB  (),
    .PADDR  (noc_PADDR),
    .PWDATA (noc_PWDATA),
    .PRDATA (noc_PRDATA),
    .PREADY (noc_PREADY),
    .PSLVERR(noc_PSLVERR)
  );

  peripheral_apb4_noc #(
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
    .APB_DATA_WIDTH(APB_DATA_WIDTH)
  ) apb4_noc (
    .RSTN(HRESETn),
    .CLK (HCLK),

    .PADDR  (noc_PADDR),
    .PWDATA (noc_PWDATA),
    .PWRITE (noc_PWRITE),
    .PSEL   (noc_PSEL),
    .PENABLE(noc_PENABLE),
    .PRDATA (noc_PRDATA),
    .PREADY (noc_PREADY),
    .PSLVERR(noc_PSLVERR),

    .rx_i(noc_rx_i),
    .tx_o(noc_tx_o),

    .event_o(noc_event_o)
  );
endmodule
