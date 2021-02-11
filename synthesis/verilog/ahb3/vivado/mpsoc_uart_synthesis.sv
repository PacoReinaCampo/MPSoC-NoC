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

module mpsoc_uart_synthesis #(
  parameter HADDR_SIZE =  8,
  parameter HDATA_SIZE = 32,
  parameter APB_ADDR_WIDTH =  8,
  parameter APB_DATA_WIDTH = 32,
  parameter SYNC_DEPTH =  3
)
  (
    //Common signals
    input                         HRESETn,
    input                         HCLK,
								  
    //UART AHB3
    input                         uart_HSEL,
    input      [HADDR_SIZE  -1:0] uart_HADDR,
    input      [HDATA_SIZE  -1:0] uart_HWDATA,
    output reg [HDATA_SIZE  -1:0] uart_HRDATA,
    input                         uart_HWRITE,
    input      [             2:0] uart_HSIZE,
    input      [             2:0] uart_HBURST,
    input      [             3:0] uart_HPROT,
    input      [             1:0] uart_HTRANS,
    input                         uart_HMASTLOCK,
    output reg                    uart_HREADYOUT,
    input                         uart_HREADY,
    output reg                    uart_HRESP
  );

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //

  //Common signals
  logic [APB_ADDR_WIDTH -1:0] uart_PADDR;
  logic [APB_DATA_WIDTH -1:0] uart_PWDATA;
  logic                       uart_PWRITE;
  logic                       uart_PSEL;
  logic                       uart_PENABLE;
  logic [APB_DATA_WIDTH -1:0] uart_PRDATA;
  logic                       uart_PREADY;
  logic                       uart_PSLVERR;

  logic                       uart_rx_i;  // Receiver input
  logic                       uart_tx_o;  // Transmitter output

  logic                       uart_event_o;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //DUT AHB3
  mpsoc_bridge_apb2ahb #(
    .HADDR_SIZE ( HADDR_SIZE     ),
    .HDATA_SIZE ( HDATA_SIZE     ),
    .PADDR_SIZE ( APB_ADDR_WIDTH ),
    .PDATA_SIZE ( APB_DATA_WIDTH ),
    .SYNC_DEPTH ( SYNC_DEPTH     )
  )
  bridge_apb2ahb (
    //AHB Slave Interface
    .HRESETn   ( HRESETn ),
    .HCLK      ( HCLK    ),

    .HSEL      ( uart_HSEL      ),
    .HADDR     ( uart_HADDR     ),
    .HWDATA    ( uart_HWDATA    ),
    .HRDATA    ( uart_HRDATA    ),
    .HWRITE    ( uart_HWRITE    ),
    .HSIZE     ( uart_HSIZE     ),
    .HBURST    ( uart_HBURST    ),
    .HPROT     ( uart_HPROT     ),
    .HTRANS    ( uart_HTRANS    ),
    .HMASTLOCK ( uart_HMASTLOCK ),
    .HREADYOUT ( uart_HREADYOUT ),
    .HREADY    ( uart_HREADY    ),
    .HRESP     ( uart_HRESP     ),

    //APB Master Interface
    .PRESETn ( HRESETn ),
    .PCLK    ( HCLK    ),

    .PSEL    ( uart_PSEL    ),
    .PENABLE ( uart_PENABLE ),
    .PPROT   (              ),
    .PWRITE  ( uart_PWRITE  ),
    .PSTRB   (              ),
    .PADDR   ( uart_PADDR   ),
    .PWDATA  ( uart_PWDATA  ),
    .PRDATA  ( uart_PRDATA  ),
    .PREADY  ( uart_PREADY  ),
    .PSLVERR ( uart_PSLVERR )
  );

  mpsoc_apb4_uart #(
    .APB_ADDR_WIDTH ( APB_ADDR_WIDTH ),
    .APB_DATA_WIDTH ( APB_DATA_WIDTH )
  )
  apb4_uart (
    .RSTN ( HRESETn ),
    .CLK  ( HCLK    ),

    .PADDR   ( uart_PADDR   ),
    .PWDATA  ( uart_PWDATA  ),
    .PWRITE  ( uart_PWRITE  ),
    .PSEL    ( uart_PSEL    ),
    .PENABLE ( uart_PENABLE ),
    .PRDATA  ( uart_PRDATA  ),
    .PREADY  ( uart_PREADY  ),
    .PSLVERR ( uart_PSLVERR ),

    .rx_i ( uart_rx_i ),
    .tx_o ( uart_tx_o ),

    .event_o ( uart_event_o )
  );
endmodule
