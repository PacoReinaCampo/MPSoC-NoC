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
//              Network on Chip Top                                           //
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

`include "riscv_mpsoc_pkg.sv"
`include "riscv_noc_pkg.sv"

module riscv_noc_mesh #(
  parameter PLEN = 64,
  parameter NODES = 8,
  parameter INPUTS = 7,
  parameter OUTPUTS = 7,
  parameter CHANNELS = 2,
  parameter VCHANNELS = 2
)
  (
    input                           clk,
    input                           rst,

    input  [NODES-1:0][CHANNELS-1:0][PLEN-1:0] in_flit,
    input  [NODES-1:0][CHANNELS-1:0]           in_last,
    input  [NODES-1:0][CHANNELS-1:0]           in_valid,
    output [NODES-1:0][CHANNELS-1:0]           in_ready,

    output [NODES-1:0][CHANNELS-1:0][PLEN-1:0] out_flit,
    output [NODES-1:0][CHANNELS-1:0]           out_last,
    output [NODES-1:0][CHANNELS-1:0]           out_valid,
    input  [NODES-1:0][CHANNELS-1:0]           out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Functions
  //

  // Get the node number
  function integer nodenum(input integer x, input integer y, input integer z);
    nodenum = x+y*`X+z*`X;
  endfunction // nodenum

  // Get the node up of position
  function integer upof(input integer x, input integer y, input integer z);
    upof = x+y*`X+(z+1)*`X;
  endfunction // upof

  // Get the node north of position
  function integer northof(input integer x, input integer y, input integer z);
    northof = x+(y+1)*`X+z*`X;
  endfunction // northof

  // Get the node east of position
  function integer eastof(input integer x, input integer y, input integer z);
    eastof  = (x+1)+y*`X+z*`X;
  endfunction // eastof

  // Get the node down of position
  function integer downof(input integer x, input integer y, input integer z);
    downof = x+y*`X+(z-1)*`X;
  endfunction // downof

  // Get the node south of position
  function integer southof(input integer x, input integer y, input integer z);
    southof = x+(y-1)*`X+z*`X;
  endfunction // southof

  // Get the node west of position
  function integer westof(input integer x, input integer y, input integer z);
    westof = (x-1)+y*`X+z*`X;
  endfunction // westof

  // This generates the lookup table for each individual node
  function [NODES-1:0][OUTPUTS-1:0] genroutes(input integer x, input integer y, input integer z);
    integer zd,yd,xd;
    integer nd;
    reg [OUTPUTS-1:0] d;

    for (zd = 0; zd < `Z; zd=zd+1) begin
      for (yd = 0; yd < `Y; yd=yd+1) begin
        for (xd = 0; xd < `X; xd=xd+1) begin : inner_loop
          nd = nodenum(xd, yd, zd);
          d = 'b0;
          if ((xd==x) && (yd==y) && (zd==z)) begin
            d = `DIR_LOCAL;
          end
          else if ((xd==x) && (yd==z)) begin
            if (zd<z) begin
              d = `DIR_DOWN;
            end
            else begin
              d = `DIR_UP;
            end
          end
          else if ((xd==x) && (zd==z)) begin
            if (yd<y) begin
              d = `DIR_SOUTH;
            end
            else begin
              d = `DIR_NORTH;
            end
          end
          else if ((yd==y) && (zd==z)) begin
            if (xd<x) begin
              d = `DIR_WEST;
            end
            else begin
              d = `DIR_EAST;
            end
          end // else: !if(xd==x)
          genroutes[nd] = d;
        end
      end
    end
  endfunction

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //

  // Number of physical channels between routers. This is essentially
  // the number of flits (and last) between the routers.
  localparam PCHANNELS = `ENABLE_VCHANNELS ? 1 : CHANNELS;

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  genvar c, p, x, y, z;

  // Arrays of wires between the routers. Each router has a
  // pair of NoC wires per direction and below those are hooked
  // up.
  wire  [INPUTS-1:0][PCHANNELS-1:0][PLEN-1:0] node_in_flit   [NODES];
  wire  [INPUTS-1:0][PCHANNELS-1:0]           node_in_last   [NODES];
  wire  [INPUTS-1:0] [CHANNELS-1:0]           node_in_valid  [NODES];
  wire  [INPUTS-1:0] [CHANNELS-1:0]           node_in_ready  [NODES];

  wire [OUTPUTS-1:0][PCHANNELS-1:0][PLEN-1:0] node_out_flit  [NODES];
  wire [OUTPUTS-1:0][PCHANNELS-1:0]           node_out_last  [NODES];
  wire [OUTPUTS-1:0] [CHANNELS-1:0]           node_out_valid [NODES];
  wire [OUTPUTS-1:0] [CHANNELS-1:0]           node_out_ready [NODES];

  // First we just need to re-arrange the wires a bit
  // because the array structure varies a bit here:
  // The directions and channels and differently
  // multiplexed here. Hence create some helper
  // arrays.
  wire [PLEN-1:0] phys_in_flit   [INPUTS];
  wire            phys_in_last   [INPUTS];
  wire            phys_in_valid  [INPUTS];
  wire            phys_in_ready  [INPUTS];

  wire [PLEN-1:0] phys_out_flit  [OUTPUTS];
  wire            phys_out_last  [OUTPUTS];
  wire            phys_out_valid [OUTPUTS];
  wire            phys_out_ready [OUTPUTS];

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
  generate
    // With virtual channels, we generate one router per node and
    // then add a virtual channel muxer between the tiles and the
    // local router input. On the output the "demux" is plain
    // wiring.

    for (z = 0; z < `Z; z=z+1) begin : zdir
      for (y = 0; y < `Y; y=y+1) begin : ydir
        for (x = 0; x < `X; x=x+1) begin : xdir
          if (`ENABLE_VCHANNELS) begin
            // Mux inputs to virtual channels
            riscv_noc_channel_mux #(
              .PLEN     (PLEN),
              .CHANNELS (CHANNELS)
            )
            noc_channel_mux (
              .clk       ( clk ),
              .rst       ( rst ),

              .in_flit   ( in_flit       [nodenum(x,y,z)]),
              .in_last   ( in_last       [nodenum(x,y,z)]),
              .in_valid  ( in_valid      [nodenum(x,y,z)]),
              .in_ready  ( in_ready      [nodenum(x,y,z)]),

              .out_flit  ( node_in_flit  [nodenum(x,y,z)][`LOCAL][0]),
              .out_last  ( node_in_last  [nodenum(x,y,z)][`LOCAL][0]),
              .out_valid ( node_in_valid [nodenum(x,y,z)][`LOCAL]),
              .out_ready ( node_in_ready [nodenum(x,y,z)][`LOCAL])
            );

            // Replicate the flit to all output channels and the
            // rest is just wiring
            for (c = 0; c < CHANNELS; c=c+1) begin : flit_demux
              assign out_flit[nodenum(x,y,z)][c] = node_out_flit[nodenum(x,y,z)][`LOCAL];
              assign out_last[nodenum(x,y,z)][c] = node_out_last[nodenum(x,y,z)][`LOCAL];
            end
            assign out_valid[nodenum(x,y,z)] = node_out_valid[nodenum(x,y,z)][`LOCAL];
            assign node_out_ready[nodenum(x,y,z)][`LOCAL] = out_ready[nodenum(x,y,z)];

            // Instantiate the router. We call a function to
            // generate the routing table
            riscv_noc_router #(
              .PLEN      (PLEN),
              .INPUTS    (INPUTS),
              .OUTPUTS   (OUTPUTS),
              .VCHANNELS (VCHANNELS),
              .ROUTES    (56'b0)
            )
            noc_router (
              .clk       ( clk ),
              .rst       ( rst ),

              .in_flit   (node_in_flit   [nodenum(x,y,z)]),
              .in_last   (node_in_last   [nodenum(x,y,z)]),
              .in_valid  (node_in_valid  [nodenum(x,y,z)]),
              .in_ready  (node_in_ready  [nodenum(x,y,z)]),

              .out_flit  (node_out_flit  [nodenum(x,y,z)]),
              .out_last  (node_out_last  [nodenum(x,y,z)]),
              .out_valid (node_out_valid [nodenum(x,y,z)]),
              .out_ready (node_out_ready [nodenum(x,y,z)])
            );
          end
          else begin // if (ENABLE_VCHANNELS == 1)
            for (c = 0; c < CHANNELS; c=c+1) begin
              assign out_flit  [nodenum(x,y,z)][c] = node_out_flit  [nodenum(x,y,z)][`LOCAL];
              assign out_last  [nodenum(x,y,z)][c] = node_out_last  [nodenum(x,y,z)][`LOCAL];
              assign out_valid [nodenum(x,y,z)] = node_out_valid [nodenum(x,y,z)][`LOCAL];

              assign node_out_ready[nodenum(x,y,z)][`LOCAL] = out_ready[nodenum(x,y,z)];

              assign node_in_flit  [nodenum(x,y,z)][`LOCAL] = in_flit  [nodenum(x,y,z)][`LOCAL];
              assign node_in_last  [nodenum(x,y,z)][`LOCAL] = in_last  [nodenum(x,y,z)][`LOCAL];
              assign node_in_valid [nodenum(x,y,z)][`LOCAL] = in_valid [nodenum(x,y,z)];

              assign in_ready[nodenum(x,y,z)] = node_in_ready[nodenum(x,y,z)][`LOCAL];

              // Re-wire the ports
              for (p = 0; p < INPUTS; p=p+1) begin
                assign phys_in_flit  [p] = node_in_flit  [nodenum(x,y,z)][p][0];
                assign phys_in_last  [p] = node_in_last  [nodenum(x,y,z)][p][0];
                assign phys_in_valid [p] = node_in_valid [nodenum(x,y,z)][p][0];

                assign node_in_ready[nodenum(x,y,z)][p][c] = phys_in_ready[p];
              end
              for (p = 0; p < OUTPUTS; p=p+1) begin
                assign node_out_flit  [nodenum(x,y,z)][p][c] = phys_out_flit  [p];
                assign node_out_last  [nodenum(x,y,z)][p][c] = phys_out_last  [p];
                assign node_out_valid [nodenum(x,y,z)][p][c] = phys_out_valid [p];

                assign phys_out_ready[p] = node_out_ready[nodenum(x,y,z)][p][0];
              end

              // Instantiate the router. We call a function to
              // generate the routing table
              riscv_noc_router #(
                .PLEN      (PLEN),
                .INPUTS    (INPUTS),
                .OUTPUTS   (OUTPUTS),
                .VCHANNELS (VCHANNELS),
                .ROUTES    (genroutes(x,y,z))
              )
              noc_router (
                .clk       ( clk ),
                .rst       ( rst ),

                .in_flit   ( phys_in_flit   ),
                .in_last   ( phys_in_last   ),
                .in_valid  ( phys_in_valid  ),
                .in_ready  ( phys_in_ready  ),

                .out_flit  ( phys_out_flit  ),
                .out_last  ( phys_out_last  ),
                .out_valid ( phys_out_valid ),
                .out_ready ( phys_out_ready )
              );
            end
          end

          // The following are all the connections of the routers
          // in the four directions. If the router is on an outer
          // border, tie off.
          if (z > 0) begin
            assign node_in_flit   [nodenum(x,y,z)][`DOWN] = node_out_flit  [southof(x,y,z)][`UP];
            assign node_in_last   [nodenum(x,y,z)][`DOWN] = node_out_last  [southof(x,y,z)][`UP];
            assign node_in_valid  [nodenum(x,y,z)][`DOWN] = node_out_valid [southof(x,y,z)][`UP];
            assign node_out_ready [nodenum(x,y,z)][`DOWN] = node_in_ready  [southof(x,y,z)][`UP];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][`DOWN] = 'x;
            assign node_in_last   [nodenum(x,y,z)][`DOWN] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][`DOWN] = 0;
            assign node_out_ready [nodenum(x,y,z)][`DOWN] = 0;
          end

          if (z < `Z-1) begin
            assign node_in_flit   [nodenum(x,y,z)][`UP] = node_out_flit  [northof(x,y,z)][`DOWN];
            assign node_in_last   [nodenum(x,y,z)][`UP] = node_out_last  [northof(x,y,z)][`DOWN];
            assign node_in_valid  [nodenum(x,y,z)][`UP] = node_out_valid [northof(x,y,z)][`DOWN];
            assign node_out_ready [nodenum(x,y,z)][`UP] = node_in_ready  [northof(x,y,z)][`DOWN];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][`UP] = 'x;
            assign node_in_last   [nodenum(x,y,z)][`UP] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][`UP] = 0;
            assign node_out_ready [nodenum(x,y,z)][`UP] = 0;
          end

          if (y > 0) begin
            assign node_in_flit   [nodenum(x,y,z)][`SOUTH] = node_out_flit  [southof(x,y,z)][`NORTH];
            assign node_in_last   [nodenum(x,y,z)][`SOUTH] = node_out_last  [southof(x,y,z)][`NORTH];
            assign node_in_valid  [nodenum(x,y,z)][`SOUTH] = node_out_valid [southof(x,y,z)][`NORTH];
            assign node_out_ready [nodenum(x,y,z)][`SOUTH] = node_in_ready  [southof(x,y,z)][`NORTH];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][`SOUTH] = 'x;
            assign node_in_last   [nodenum(x,y,z)][`SOUTH] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][`SOUTH] = 0;
            assign node_out_ready [nodenum(x,y,z)][`SOUTH] = 0;
          end

          if (y < `Y-1) begin
            assign node_in_flit   [nodenum(x,y,z)][`NORTH] = node_out_flit  [northof(x,y,z)][`SOUTH];
            assign node_in_last   [nodenum(x,y,z)][`NORTH] = node_out_last  [northof(x,y,z)][`SOUTH];
            assign node_in_valid  [nodenum(x,y,z)][`NORTH] = node_out_valid [northof(x,y,z)][`SOUTH];
            assign node_out_ready [nodenum(x,y,z)][`NORTH] = node_in_ready  [northof(x,y,z)][`SOUTH];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][`NORTH] = 'x;
            assign node_in_last   [nodenum(x,y,z)][`NORTH] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][`NORTH] = 0;
            assign node_out_ready [nodenum(x,y,z)][`NORTH] = 0;
          end

          if (x > 0) begin
            assign node_in_flit   [nodenum(x,y,z)][`WEST] = node_out_flit  [westof(x,y,z)][`EAST];
            assign node_in_last   [nodenum(x,y,z)][`WEST] = node_out_last  [westof(x,y,z)][`EAST];
            assign node_in_valid  [nodenum(x,y,z)][`WEST] = node_out_valid [westof(x,y,z)][`EAST];
            assign node_out_ready [nodenum(x,y,z)][`WEST] = node_in_ready  [westof(x,y,z)][`EAST];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][`WEST] = 'x;
            assign node_in_last   [nodenum(x,y,z)][`WEST] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][`WEST] = 0;
            assign node_out_ready [nodenum(x,y,z)][`WEST] = 0;
          end

          if (x < `X-1) begin
            assign node_in_flit   [nodenum(x,y,z)][`EAST] = node_out_flit  [eastof(x,y,z)][`WEST];
            assign node_in_last   [nodenum(x,y,z)][`EAST] = node_out_last  [eastof(x,y,z)][`WEST];
            assign node_in_valid  [nodenum(x,y,z)][`EAST] = node_out_valid [eastof(x,y,z)][`WEST];
            assign node_out_ready [nodenum(x,y,z)][`EAST] = node_in_ready  [eastof(x,y,z)][`WEST];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][`EAST] = 'x;
            assign node_in_last   [nodenum(x,y,z)][`EAST] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][`EAST] = 0;
            assign node_out_ready [nodenum(x,y,z)][`EAST] = 0;
          end
        end
      end
    end
  endgenerate
endmodule
