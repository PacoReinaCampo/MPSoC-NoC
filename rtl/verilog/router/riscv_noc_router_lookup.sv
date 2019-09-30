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
//              Network on Chip Router Lookup                                 //
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

module riscv_noc_router_lookup #(
  parameter PLEN = 64,
  parameter OUTPUTS = 7,

  parameter [8*7-1:0] ROUTES = {{7'b0},{7'b0},{7'b0},{7'b0},{7'b0},{7'b0},{7'b0},{7'b0}}
)
  (
    input                          clk,
    input                          rst,

    input               [PLEN-1:0] in_flit,
    input                          in_last,
    input                          in_valid,
    output                         in_ready,

    output [OUTPUTS-1:0]           out_valid,
    output                         out_last,
    output              [PLEN-1:0] out_flit,
    input  [OUTPUTS-1:0]           out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //

  // We need to track worms and directly encode the output of the
  // current worm.
  reg   [OUTPUTS-1:0] worm;
  logic [OUTPUTS-1:0] nxt_worm;
  // This is high if we are in a worm
  logic wormhole;

  // Extract destination from flit
  logic [OUTPUTS-1:0] dest;

  // This is the selection signal of the slave, one hot so that it
  // directly serves as flow control valid
  logic [OUTPUTS-1:0] valid;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  // We need to track worms and directly encode the output of the
  // This is high if we are in a worm
  assign wormhole = |worm;

  // Extract destination from flit
  assign dest = in_flit[PLEN-1 -: OUTPUTS];

  // Register slice at the output.
  riscv_noc_router_lookup_slice #(
    .PLEN    (PLEN),
    .OUTPUTS (OUTPUTS)
  )
  noc_router_lookup_slice (
    .clk (clk),
    .rst (rst),

    .in_flit  (in_flit),
    .in_last  (in_last),
    .in_valid (valid),
    .in_ready (in_ready),

    .out_valid (out_valid),
    .out_last  (out_last),
    .out_flit  (out_flit),
    .out_ready (out_ready)
  );

  always @(*) begin
    nxt_worm = worm;
    valid    = 'b0;

    if (!wormhole) begin
      // We are waiting for a flit
      if (in_valid) begin
        // This is a header. Lookup output
        valid = ROUTES[(dest+1)*(OUTPUTS+1)-1];
        if (in_ready & !in_last) begin
          // If we can push it further and it is not the only
          // flit, enter a worm and store the output
          nxt_worm = ROUTES[(dest+1)*(OUTPUTS+1)-1];
        end
      end
    end
    else begin // if (!wormhole)
      // We are in a worm
      // The valid is set on the currently select output
      valid = worm & {OUTPUTS{in_valid}};
      if (in_ready & in_last) begin
        // End of worm
        nxt_worm = 'b0;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      worm <= 'b0;
    end
    else begin
      worm <= nxt_worm;
    end
  end
endmodule
