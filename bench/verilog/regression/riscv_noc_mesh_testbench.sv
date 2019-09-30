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
//              Network on Chip TestBench                                     //
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

module riscv_noc_mesh_testbench;

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //

  parameter PLEN = 64;
  parameter NODES = 8;
  parameter INPUTS = 7;
  parameter OUTPUTS = 7;
  parameter CHANNELS = 2;
  parameter VCHANNELS = 2;

  parameter [PLEN-1:0] MAPPING = 'x;

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  wire                                     HCLK;
  wire                                     HRESETn;

  wire [NODES-1:0][CHANNELS-1:0][PLEN-1:0] noc_out_flit;
  wire [NODES-1:0][CHANNELS-1:0]           noc_out_last;
  wire [NODES-1:0][CHANNELS-1:0]           noc_out_valid;
  wire [NODES-1:0][CHANNELS-1:0]           noc_out_ready;

  wire [NODES-1:0][CHANNELS-1:0][PLEN-1:0] noc_in_flit;
  wire [NODES-1:0][CHANNELS-1:0]           noc_in_last;
  wire [NODES-1:0][CHANNELS-1:0]           noc_in_valid;
  wire [NODES-1:0][CHANNELS-1:0]           noc_in_ready;

  wire               [PLEN-1:0] demux_in_flit;
  wire                          demux_in_last;
  wire                          demux_in_valid;
  wire                          demux_in_ready;

  wire [CHANNELS-1:0][PLEN-1:0] demux_out_flit;
  wire [CHANNELS-1:0]           demux_out_last;
  wire [CHANNELS-1:0]           demux_out_valid;
  wire [CHANNELS-1:0]           demux_out_ready;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //DUT
  riscv_noc_mesh #(
    .PLEN      (PLEN),
    .NODES     (NODES),
    .INPUTS    (INPUTS),
    .OUTPUTS   (OUTPUTS),
    .CHANNELS  (CHANNELS),
    .VCHANNELS (VCHANNELS)
  )
  noc_mesh (
    .rst       ( HRESETn ),
    .clk       ( HCLK    ),

    .in_flit   ( noc_out_flit  ),
    .in_last   ( noc_out_last  ),
    .in_valid  ( noc_out_valid ),
    .in_ready  ( noc_out_ready ),

    .out_flit  ( noc_in_flit  ),
    .out_last  ( noc_in_last  ),
    .out_valid ( noc_in_valid ),
    .out_ready ( noc_in_ready )
  );

  riscv_noc_demux #(
    .PLEN     (PLEN),
    .CHANNELS (CHANNELS),

    .MAPPING (MAPPING)
  )
  noc_demux (
    .rst ( HRESETn ),
    .clk ( HCLK    ),

    .in_flit  ( demux_in_flit  ),
    .in_last  ( demux_in_last  ),
    .in_valid ( demux_in_valid ),
    .in_ready ( demux_in_ready ),

    .out_flit  ( demux_out_flit  ),
    .out_last  ( demux_out_last  ),
    .out_valid ( demux_out_valid ),
    .out_ready ( demux_out_ready )
  );
endmodule
