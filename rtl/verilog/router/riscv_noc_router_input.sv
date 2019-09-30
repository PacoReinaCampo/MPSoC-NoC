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
//              Router Input                                                  //
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

module riscv_noc_router_input #(
  parameter PLEN = 64,
  parameter OUTPUTS = 7,
  parameter VCHANNELS = 2,
  parameter BUFFER_DEPTH = 4,

  parameter [8*7-1:0] ROUTES = {{7'b0},{7'b0},{7'b0},{7'b0},{7'b0},{7'b0},{7'b0},{7'b0}}
)
  (
    input                                         clk,
    input                                         rst,

    input                              [PLEN-1:0] in_flit,
    input                                         in_last,
    input  [VCHANNELS-1:0]                        in_valid,
    output [VCHANNELS-1:0]                        in_ready,

    output [VCHANNELS-1:0][OUTPUTS-1:0]           out_valid,
    output [VCHANNELS-1:0]                        out_last,
    output [VCHANNELS-1:0]             [PLEN-1:0] out_flit,
    input  [VCHANNELS-1:0][OUTPUTS-1:0]           out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  genvar v;

  wire [VCHANNELS-1:0][PLEN-1:0] buffer_flit;
  wire [VCHANNELS-1:0]           buffer_last;
  wire [VCHANNELS-1:0]           buffer_valid;
  wire [VCHANNELS-1:0]           buffer_ready;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
  generate
    for (v = 0; v < VCHANNELS; v=v+1) begin : vc

      riscv_noc_buffer #(
        .PLEN         (PLEN),
        .BUFFER_DEPTH (BUFFER_DEPTH),
        .FULLPACKET   (0)
      )
      noc_buffer (
        .clk         (clk              ),
        .rst         (rst              ),

        .in_flit     (in_flit          ),
        .in_last     (in_last          ),
        .in_valid    (in_valid     [v] ),
        .in_ready    (in_ready     [v] ),

        .out_flit    (buffer_flit  [v] ),
        .out_last    (buffer_last  [v] ),
        .out_valid   (buffer_valid [v] ),
        .out_ready   (buffer_ready [v] ),

        .packet_size ()
      );

      riscv_noc_router_lookup #(
        .PLEN   ( PLEN ),
        .OUTPUTS ( OUTPUTS ),
        .ROUTES  ( ROUTES )
      )
      noc_router_lookup (
        .clk       (clk               ),
        .rst       (rst               ),

        .in_flit   ( buffer_flit  [v] ),
        .in_last   ( buffer_last  [v] ),
        .in_valid  ( buffer_valid [v] ),
        .in_ready  ( buffer_ready [v] ),

        .out_flit  ( out_flit     [v] ),
        .out_last  ( out_last     [v] ),
        .out_valid ( out_valid    [v] ),
        .out_ready ( out_ready    [v] )
      );
    end
  endgenerate
endmodule
