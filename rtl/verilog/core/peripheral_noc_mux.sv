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
//              Peripheral-NoC for MPSoC                                      //
//              Network on Chip for MPSoC                                     //
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
 *   Stefan Wallentowitz <stefan@wallentowitz.de>
 *   Andreas Lankes <andreas.lankes@tum.de>
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

module peripheral_noc_mux #(
  parameter FLIT_WIDTH = 32,
  parameter CHANNELS   = 2
)
  (
    input                                     clk,
    input                                     rst,

    input      [CHANNELS-1:0][FLIT_WIDTH-1:0] in_flit,
    input      [CHANNELS-1:0]                 in_last,
    input      [CHANNELS-1:0]                 in_valid,
    output reg [CHANNELS-1:0]                 in_ready,

    output reg               [FLIT_WIDTH-1:0] out_flit,
    output reg                                out_last,
    output reg                                out_valid,
    input                                     out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  wire [CHANNELS-1:0] select;
  reg  [CHANNELS-1:0] active;

  reg                 activeroute;
  reg                 nxt_activeroute;

  wire [CHANNELS-1:0] req_masked;

  integer c;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
  assign req_masked = {CHANNELS{~activeroute & out_ready}} & in_valid;

  always @(*) begin
    out_flit = {FLIT_WIDTH{1'b0}};
    out_last = 1'b0;
    for (c = 0; c < CHANNELS; c = c + 1) begin
      if (select[c]) begin
        out_flit = in_flit[c];
        out_last = in_last[c];
      end
    end
  end

  always @(*) begin
    nxt_activeroute = activeroute;
    in_ready        = {CHANNELS{1'b0}};

    if (activeroute) begin
      if (|(in_valid & active) && out_ready) begin
        in_ready  = active;
        out_valid = 1;
        if (out_last)
          nxt_activeroute = 0;
      end
      else begin
        out_valid = 1'b0;
        in_ready  = 0;
      end
    end
    else begin
      out_valid = 0;
      if (|in_valid && out_ready) begin
        out_valid       = 1'b1;
        nxt_activeroute = ~out_last;
        in_ready        = select;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      activeroute <= 0;
      active      <= {{CHANNELS-1{1'b0}},1'b1};
    end
    else begin
      activeroute <= nxt_activeroute;
      active      <= select;
    end
  end

  peripheral_arbiter_rr #(
    .N (CHANNELS)
  )
  arbiter_rr (
    .nxt_gnt (select),
    .req     (req_masked),
    .gnt     (active),
    .en      (1'b1)
  );
endmodule
