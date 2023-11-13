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
//              Master Slave Interface Tesbench                               //
//              Wishbone Bus Interface                                        //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018-2019 by the author(s)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////
// Author(s):
//   Paco Reina Campo <pacoreinacampo@queenfield.tech>

module peripheral_noc_synthesis #(
  parameter SIM   = 0,
  parameter DEBUG = 0
) (
  input clk,
  input rst,

  // WISHBONE interface
  input  [2:0] wb_adr_i,
  input  [7:0] wb_dat_i,
  output [7:0] wb_dat_o,
  input        wb_we_i,
  input        wb_stb_i,
  input        wb_cyc_i,
  input  [3:0] wb_sel_i,
  output       wb_ack_o,
  output       int_o,

  // UART signals
  input  srx_pad_i,
  output stx_pad_o,
  output rts_pad_o,
  input  cts_pad_i,
  output dtr_pad_o,
  input  dsr_pad_i,
  input  ri_pad_i,
  input  dcd_pad_i,

  // optional baudrate output
  output baud_o
);

  //////////////////////////////////////////////////////////////////////////////
  // Module Body
  //////////////////////////////////////////////////////////////////////////////

  // DUT WB
  peripheral_wb_noc #(
    .SIM  (SIM),
    .DEBUG(DEBUG)
  ) wb_noc (
    .wb_clk_i(clk),
    .wb_rst_i(rst),

    // WISHBONE interface
    .wb_adr_i(wb_adr_i),
    .wb_dat_i(wb_dat_i),
    .wb_dat_o(wb_dat_o),
    .wb_we_i (wb_we_i),
    .wb_stb_i(wb_stb_i),
    .wb_cyc_i(wb_cyc_i),
    .wb_sel_i(wb_sel_i),
    .wb_ack_o(wb_ack_o),
    .int_o   (int_o),

    // UART  signals
    .srx_pad_i(srx_pad_i),
    .stx_pad_o(stx_pad_o),
    .rts_pad_o(rts_pad_o),
    .cts_pad_i(cts_pad_i),
    .dtr_pad_o(dtr_pad_o),
    .dsr_pad_i(dsr_pad_i),
    .ri_pad_i (ri_pad_i),
    .dcd_pad_i(dcd_pad_i),

    // optional baudrate output
    .baud_o(baud_o)
  );
endmodule
