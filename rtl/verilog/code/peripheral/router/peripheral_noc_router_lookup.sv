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
//   Stefan Wallentowitz <stefan@wallentowitz.de>
//   Paco Reina Campo <pacoreinacampo@queenfield.tech>

module peripheral_noc_router_lookup #(
  parameter FLIT_WIDTH = 32,
  parameter DEST_WIDTH = 5,
  parameter DESTS      = 1,
  parameter OUTPUTS    = 1
) (
  input clk,
  input rst,

  input [DESTS*OUTPUTS-1:0] ROUTES,

  input  [FLIT_WIDTH-1:0] in_flit,
  input                   in_last,
  input                   in_valid,
  output                  in_ready,

  output [OUTPUTS   -1:0] out_valid,
  output                  out_last,
  output [FLIT_WIDTH-1:0] out_flit,
  input  [OUTPUTS   -1:0] out_ready
);

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  // We need to track worms and directly encode the output of the
  // current worm.
  reg   [   OUTPUTS-1:0] worm;
  logic [   OUTPUTS-1:0] nxt_worm;
  logic                  wormhole;

  logic [DEST_WIDTH-1:0] dest;

  logic [   OUTPUTS-1:0] valid;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // This is high if we are in a worm
  assign wormhole = |worm;

  // Extract destination from flit
  assign dest     = in_flit[FLIT_WIDTH-1-:DEST_WIDTH];

  // This is the selection signal of the slave, one hot so that it
  // directly serves as flow control valid

  // Register slice at the output.
  peripheral_noc_router_lookup_slice #(
    .FLIT_WIDTH(FLIT_WIDTH),
    .OUTPUTS   (OUTPUTS)
  ) u_slice (
    .clk(clk),
    .rst(rst),

    .in_valid(valid),
    .in_last (in_last),
    .in_flit (in_flit),
    .in_ready(in_ready),

    .out_valid(out_valid),
    .out_last (out_last),
    .out_flit (out_flit),
    .out_ready(out_ready)
  );

  always @(*) begin
    nxt_worm = worm;
    valid    = 0;
    if (!wormhole) begin
      // We are waiting for a flit
      if (in_valid) begin
        // This is a header. Lookup output
        valid = ROUTES[dest*OUTPUTS+:OUTPUTS];
        if (in_ready & !in_last) begin
          // If we can push it further and it is not the only
          // flit, enter a worm and store the output
          nxt_worm = ROUTES[dest*OUTPUTS+:OUTPUTS];
        end
      end
    end else begin
      // We are in a worm
      // The valid is set on the currently select output
      valid = worm & {OUTPUTS{in_valid}};
      if (in_ready & in_last) begin
        // End of worm
        nxt_worm = 0;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      worm <= 0;
    end else begin
      worm <= nxt_worm;
    end
  end
endmodule
