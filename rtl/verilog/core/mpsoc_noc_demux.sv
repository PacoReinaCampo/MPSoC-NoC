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
//              Network on Chip                                               //
//              AMBA3 AHB-Lite Bus Interface                                  //
//              WishBone Bus Interface                                        //
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

module mpsoc_noc_demux #(
  parameter        FLIT_WIDTH = 32,
  parameter        CHANNELS   = 7,
  parameter [63:0] MAPPING    = 'x
)
  (
    input                                     clk,
    input                                     rst,

    input                    [FLIT_WIDTH-1:0] in_flit,
    input                                     in_last,
    input                                     in_valid,
    output reg                                in_ready,

    output     [CHANNELS-1:0][FLIT_WIDTH-1:0] out_flit,
    output     [CHANNELS-1:0]                 out_last,
    output reg [CHANNELS-1:0]                 out_valid,
    input      [CHANNELS-1:0]                 out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //

  // NoC packet header
  // Mandatory fields
  localparam mpsoc_noc_CLASS_MSB = 26;
  localparam mpsoc_noc_CLASS_LSB = 24;

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  reg [CHANNELS-1:0] active;
  reg [CHANNELS-1:0] nxt_active;

  wire [         2:0] packet_class;
  reg  [CHANNELS-1:0] select;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
  assign packet_class = in_flit[mpsoc_noc_CLASS_MSB:mpsoc_noc_CLASS_LSB];

  always @(*) begin : gen_select
    select = MAPPING[8*packet_class +: CHANNELS];
    if (select == 0) begin
      select = { {CHANNELS-1{1'b0}}, 1'b1};
    end
  end

  assign out_flit = {CHANNELS{in_flit}};
  assign out_last = {CHANNELS{in_last}};

  always @(*) begin
    nxt_active = active;

    out_valid = 0;
    in_ready  = 0;

    if (active == 0) begin
      in_ready  = |(select & out_ready);
      out_valid =   select & {CHANNELS{in_valid}};

      if (in_valid & ~in_last) begin
        nxt_active = select;
      end
    end
    else begin
      in_ready  = |(active & out_ready);
      out_valid = active & {CHANNELS{in_valid}};

      if (in_valid & in_last) begin
        nxt_active = 0;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      active <= '0;
    end
    else begin
      active <= nxt_active;
    end
  end
endmodule // mpsoc_noc_demux
