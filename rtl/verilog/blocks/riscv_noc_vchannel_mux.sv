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
//              Network on Chip Virtual Channel Multiplexer                   //
//              Mesh Topology                                                 //
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
 *   Francisco Javier Reina Campo <frareicam@gmail.com>
 */

`include "riscv_noc_pkg.sv"

module riscv_noc_vchannel_mux #(
  parameter PLEN = 64,
  parameter VCHANNELS = 2
)
  (
    input                                clk,
    input                                rst,

    input      [VCHANNELS-1:0][PLEN-1:0] in_flit,
    input      [VCHANNELS-1:0]           in_last,
    input      [VCHANNELS-1:0]           in_valid,
    output     [VCHANNELS-1:0]           in_ready,

    output reg                [PLEN-1:0] out_flit,
    output reg                           out_last,
    output     [VCHANNELS-1:0]           out_valid,
    input      [VCHANNELS-1:0]           out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  reg   [VCHANNELS-1:0] selected;
  logic [VCHANNELS-1:0] nxt_selected;

  integer c;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
  assign out_valid = in_valid  & selected;
  assign in_ready  = out_ready & selected;

  always @(*) begin
    if (rst) begin
      out_flit = 'x;
      out_last = 'x;
    end
    else begin
      for (c = 0; c < VCHANNELS; c=c+1) begin
        if (selected[c]) begin
          out_flit = in_flit[c];
          out_last = in_last[c];
        end
      end
    end
  end

  riscv_arb_rr #(
    .N (VCHANNELS)
  )
  arb_rr (
    .req (in_valid & out_ready),
    .en  (1'b1),
    .gnt (selected),
    .nxt_gnt (nxt_selected)
  );

  always @(posedge clk) begin
    if (rst) begin
      selected <= {{VCHANNELS-1{1'b0}},1'b1};
    end
    else begin
      selected <= nxt_selected;
    end
  end
endmodule
