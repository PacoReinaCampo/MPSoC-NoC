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
//              Network on Chip Demultiplexer                                 //
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

module riscv_noc_demux #(
  parameter PLEN = 64,
  parameter CHANNELS = 2,

  parameter [63:0] MAPPING = 'x
)
  (
    input                               clk,
    input                               rst,

    input                    [PLEN-1:0] in_flit,
    input                               in_last,
    input                               in_valid,
    output reg                          in_ready,

    output     [CHANNELS-1:0][PLEN-1:0] out_flit,
    output     [CHANNELS-1:0]           out_last,
    output reg [CHANNELS-1:0]           out_valid,
    input      [CHANNELS-1:0]           out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  reg  [CHANNELS-1:0] actived;
  reg  [CHANNELS-1:0] nxt_actived;

  wire [         2:0] packet_class;
  reg  [CHANNELS-1:0] selected;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
  assign packet_class = in_flit[`NOC_CLASS_MSB:`NOC_CLASS_LSB];

  always @(*) begin : gen_selected
    selected = MAPPING[8*packet_class +: CHANNELS];
    if (selected == 0) begin
      selected = { {CHANNELS-1{1'b0}}, 1'b1};
    end
  end

  assign out_flit = {CHANNELS{in_flit}};
  assign out_last = {CHANNELS{in_last}};

  always @(*) begin
    nxt_actived = actived;

    out_valid = 0;
    in_ready  = 0;

    if (actived == 0) begin
      in_ready = |(selected & out_ready);
      out_valid = selected & {CHANNELS{in_valid}};

      if (in_valid & ~in_last) begin
        nxt_actived = selected;
      end
    end
    else begin
      in_ready = |(actived & out_ready);
      out_valid = actived & {CHANNELS{in_valid}};

      if (in_valid & in_last) begin
        nxt_actived = 0;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      actived <= '0;
    end
    else begin
      actived <= nxt_actived;
    end
  end
endmodule
