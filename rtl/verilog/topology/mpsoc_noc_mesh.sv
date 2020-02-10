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

module mpsoc_noc_mesh #(
  parameter FLIT_WIDTH       = 34,
  parameter VCHANNELS        = 7,
  parameter CHANNELS         = 7,
  parameter OUTPUTS          = 7,
  parameter ENABLE_VCHANNELS = 1,
  parameter X                = 2,
  parameter Y                = 2,
  parameter Z                = 2,
  parameter NODES            = 8,
  parameter BUFFER_SIZE_IN   = 4,
  parameter BUFFER_SIZE_OUT  = 4
)
  (
    input                                            clk,
    input                                            rst,

    input  [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] in_flit,
    input  [NODES-1:0][CHANNELS-1:0]                 in_last,
    input  [NODES-1:0][CHANNELS-1:0]                 in_valid,
    output [NODES-1:0][CHANNELS-1:0]                 in_ready,

    output [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] out_flit,
    output [NODES-1:0][CHANNELS-1:0]                 out_last,
    output [NODES-1:0][CHANNELS-1:0]                 out_valid,
    input  [NODES-1:0][CHANNELS-1:0]                 out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //

  // Those are indexes into the wiring arrays
  localparam LOCAL = 0;
  localparam UP    = 1;
  localparam NORTH = 2;
  localparam EAST  = 3;
  localparam DOWN  = 4;
  localparam SOUTH = 5;
  localparam WEST  = 6;

  // Those are direction codings that match the wiring indices
  // above. The router is configured to use those to select the
  // proper output port.
  localparam DIR_LOCAL = 7'b0000001;
  localparam DIR_UP    = 7'b0000010;
  localparam DIR_NORTH = 7'b0000100;
  localparam DIR_EAST  = 7'b0001000;
  localparam DIR_DOWN  = 7'b0010000;
  localparam DIR_SOUTH = 7'b0100000;
  localparam DIR_WEST  = 7'b1000000;

  // Number of physical channels between routers. This is essentially
  // the number of flits (and last) between the routers.
  localparam PCHANNELS = ENABLE_VCHANNELS ? 1 : CHANNELS;

  //////////////////////////////////////////////////////////////////
  //
  // Functions
  //

  // Get the node number
  function integer nodenum(input integer x, input integer y, input integer z);
    nodenum = x+y*X+z*X;
  endfunction // nodenum

  // Get the node up of position
  function integer upof(input integer x, input integer y, input integer z);
    upof = x+y*X+(z+1)*X;
  endfunction // upof

  // Get the node north of position
  function integer northof(input integer x, input integer y, input integer z);
    northof = x+(y+1)*X+z*X;
  endfunction // northof

  // Get the node east of position
  function integer eastof(input integer x, input integer y, input integer z);
    eastof  = (x+1)+y*X+z*X;
  endfunction // eastof

  // Get the node down of position
  function integer downof(input integer x, input integer y, input integer z);
    downof = x+y*X+(z-1)*X;
  endfunction // downof

  // Get the node south of position
  function integer southof(input integer x, input integer y, input integer z);
    southof = x+(y-1)*X+z*X;
  endfunction // southof

  // Get the node west of position
  function integer westof(input integer x, input integer y, input integer z);
    westof = (x-1)+y*X+z*X;
  endfunction // westof

  // This generates the lookup table for each individual node
  function [NODES-1:0][OUTPUTS-1:0] genroutes(input integer x, input integer y, input integer z);
    integer zd,yd,xd;
    integer nd;
    reg [OUTPUTS-1:0] d;

    genroutes = {NODES{7'b0000000}};

    for (zd = 0; zd < Z; zd=zd+1) begin
      for (yd = 0; yd < Y; yd=yd+1) begin
        for (xd = 0; xd < X; xd=xd+1) begin : inner_loop
          nd = nodenum(xd, yd, zd);
          d = 7'b0000000;
          if ((xd==x) && (yd==y) && (zd==z)) begin
            d = DIR_LOCAL;
          end
          else if ((xd==x) && (yd==z)) begin
            if (zd<z) begin
              d = DIR_DOWN;
            end
            else begin
              d = DIR_UP;
            end
          end
          else if ((xd==x) && (zd==z)) begin
            if (yd<y) begin
              d = DIR_SOUTH;
            end
            else begin
              d = DIR_NORTH;
            end
          end
          else if ((yd==y) && (zd==z)) begin
            if (xd<x) begin
              d = DIR_WEST;
            end
            else begin
              d = DIR_EAST;
            end
          end // else: !if(xd==x)
          genroutes[nd] = d;
        end
      end
    end
  endfunction

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  genvar c, o, p, x, y, z;

  // Arrays of wires between the routers. Each router has a
  // pair of NoC wires per direction and below those are hooked
  // up.
  wire [CHANNELS-1:0][PCHANNELS-1:0][FLIT_WIDTH-1:0] node_in_flit   [NODES];
  wire [CHANNELS-1:0][PCHANNELS-1:0]                 node_in_last   [NODES];
  wire [CHANNELS-1:0][ CHANNELS-1:0]                 node_in_valid  [NODES];
  wire [CHANNELS-1:0][ CHANNELS-1:0]                 node_in_ready  [NODES];

  wire [OUTPUTS-1:0][PCHANNELS-1:0][FLIT_WIDTH-1:0] node_out_flit  [NODES];
  wire [OUTPUTS-1:0][PCHANNELS-1:0]                 node_out_last  [NODES];
  wire [OUTPUTS-1:0][ CHANNELS-1:0]                 node_out_valid [NODES];
  wire [OUTPUTS-1:0][ CHANNELS-1:0]                 node_out_ready [NODES];

  // First we just need to re-arrange the wires a bit
  // because the array structure varies a bit here:
  // The directions and channels and differently
  // multiplexed here. Hence create some helper
  // arrays.
  wire [CHANNELS-1:0]               [FLIT_WIDTH-1:0] phys_in_flit  [NODES];
  wire [CHANNELS-1:0]                                phys_in_last  [NODES];
  wire [CHANNELS-1:0][VCHANNELS-1:0]                 phys_in_valid [NODES];
  wire [CHANNELS-1:0][VCHANNELS-1:0]                 phys_in_ready [NODES];

  wire [OUTPUTS-1:0]               [FLIT_WIDTH-1:0] phys_out_flit  [NODES];
  wire [OUTPUTS-1:0]                                phys_out_last  [NODES];
  wire [OUTPUTS-1:0][VCHANNELS-1:0]                 phys_out_valid [NODES];
  wire [OUTPUTS-1:0][VCHANNELS-1:0]                 phys_out_ready [NODES];

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
  generate
    // With virtual channels, we generate one router per node and
    // then add a virtual channel muxer between the tiles and the
    // local router input. On the output the "demux" is plain
    // wiring.
    for (z = 0; z < Z; z=z+1) begin : zdir
      for (y = 0; y < Y; y=y+1) begin : ydir
        for (x = 0; x < X; x=x+1) begin : xdir
          if (ENABLE_VCHANNELS) begin
            // Mux inputs to virtual channels
            mpsoc_noc_vchannel_mux #(
              .FLIT_WIDTH (FLIT_WIDTH),
              .CHANNELS   (CHANNELS)
            )
            vchannel_mux (
              .clk (clk),
              .rst (rst),

              .in_flit   (in_flit  [nodenum(x,y,z)]),
              .in_last   (in_last  [nodenum(x,y,z)]),
              .in_valid  (in_valid [nodenum(x,y,z)]),
              .in_ready  (in_ready [nodenum(x,y,z)]),

              .out_flit  (node_in_flit  [nodenum(x,y,z)][LOCAL][0]),
              .out_last  (node_in_last  [nodenum(x,y,z)][LOCAL][0]),
              .out_valid (node_in_valid [nodenum(x,y,z)][LOCAL]),
              .out_ready (node_in_ready [nodenum(x,y,z)][LOCAL])
            );

            // Replicate the flit to all output channels and the
            // rest is just wiring
            for (c = 0; c < CHANNELS; c=c+1) begin : flit_demux
              assign out_flit[nodenum(x,y,z)][c] = node_out_flit[nodenum(x,y,z)][LOCAL][0];
              assign out_last[nodenum(x,y,z)][c] = node_out_last[nodenum(x,y,z)][LOCAL][0];
            end

            assign out_valid[nodenum(x,y,z)] = node_out_valid[nodenum(x,y,z)][LOCAL];

            assign node_out_ready[nodenum(x,y,z)][LOCAL] = out_ready[nodenum(x,y,z)];

            // Instantiate the router. We call a function to
            // generate the routing table
            mpsoc_noc_router #(
              .FLIT_WIDTH      (FLIT_WIDTH),
              .VCHANNELS       (CHANNELS),
              .CHANNELS        (CHANNELS),
              .OUTPUTS         (OUTPUTS),
              .BUFFER_SIZE_IN  (BUFFER_SIZE_IN),
              .BUFFER_SIZE_OUT (BUFFER_SIZE_OUT),
              .NODES           (NODES)
            )
            router (
              .clk (clk),
              .rst (rst),

              .routes    (genroutes(x,y,z)),

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
            for (c = 0; c < CHANNELS; c=c+1) begin : flit_demux_out
              assign out_flit [nodenum(x,y,z)][c] = node_out_flit [nodenum(x,y,z)][LOCAL][c];
              assign out_last [nodenum(x,y,z)][c] = node_out_last [nodenum(x,y,z)][LOCAL][c];
            end

            assign out_valid [nodenum(x,y,z)] = node_out_valid [nodenum(x,y,z)][LOCAL];

            assign node_out_ready [nodenum(x,y,z)][LOCAL] = out_ready [nodenum(x,y,z)];

            for (c = 0; c < CHANNELS; c=c+1) begin : flit_demux
              assign node_in_flit [nodenum(x,y,z)][LOCAL][c] = in_flit [nodenum(x,y,z)][c];
              assign node_in_last [nodenum(x,y,z)][LOCAL][c] = in_last [nodenum(x,y,z)][c];
            end

            assign node_in_valid [nodenum(x,y,z)][LOCAL] = in_valid [nodenum(x,y,z)];

            assign in_ready [nodenum(x,y,z)] = node_in_ready [nodenum(x,y,z)][LOCAL];

            // Instantiate the router. We call a function to
            // generate the routing table
            mpsoc_noc_router #(
              .FLIT_WIDTH      (FLIT_WIDTH),
              .VCHANNELS       (1),
              .CHANNELS        (CHANNELS),
              .OUTPUTS         (OUTPUTS),
              .BUFFER_SIZE_IN  (BUFFER_SIZE_IN),
              .BUFFER_SIZE_OUT (BUFFER_SIZE_OUT),
              .NODES           (NODES)
            )
            router (
              .clk       (clk),
              .rst       (rst),

              .routes    (genroutes(x,y,z)),

              .in_flit   (phys_in_flit  [nodenum(x,y,z)]),
              .in_last   (phys_in_last  [nodenum(x,y,z)]),
              .in_valid  (phys_in_valid [nodenum(x,y,z)]),
              .in_ready  (phys_in_ready [nodenum(x,y,z)]),

              .out_flit  (phys_out_flit  [nodenum(x,y,z)]),
              .out_last  (phys_out_last  [nodenum(x,y,z)]),
              .out_valid (phys_out_valid [nodenum(x,y,z)]),
              .out_ready (phys_out_ready [nodenum(x,y,z)])
            );

            for (c = 0; c < CHANNELS; c=c+1) begin
              // Re-wire the ports
              for (p = 0; p < CHANNELS; p=p+1) begin
                assign phys_in_flit  [nodenum(x,y,z)][p] = node_in_flit  [nodenum(x,y,z)][p][c];
                assign phys_in_last  [nodenum(x,y,z)][p] = node_in_last  [nodenum(x,y,z)][p][c];

                assign phys_in_valid [nodenum(x,y,z)][p][c] = node_in_valid [nodenum(x,y,z)][p][c];

                assign node_in_ready [nodenum(x,y,z)][p][c] = phys_in_ready [nodenum(x,y,z)][p];
              end
              for (o = 0; o < OUTPUTS; o=o+1) begin
                assign node_out_flit  [nodenum(x,y,z)][o][c] = phys_out_flit  [nodenum(x,y,z)][o];
                assign node_out_last  [nodenum(x,y,z)][o][c] = phys_out_last  [nodenum(x,y,z)][o];

                assign node_out_valid [nodenum(x,y,z)][o][c] = phys_out_valid [nodenum(x,y,z)][o][c];

                assign phys_out_ready [nodenum(x,y,z)][o][c] = node_out_ready [nodenum(x,y,z)][o][c];
              end
            end
          end

          // The following are all the connections of the routers
          // in the four directions. If the router is on an outer
          // border, tie off.
          if (z > 0) begin
            assign node_in_flit   [nodenum(x,y,z)][DOWN] = node_out_flit  [southof(x,y,z)][UP];
            assign node_in_last   [nodenum(x,y,z)][DOWN] = node_out_last  [southof(x,y,z)][UP];
            assign node_in_valid  [nodenum(x,y,z)][DOWN] = node_out_valid [southof(x,y,z)][UP];
            assign node_out_ready [nodenum(x,y,z)][DOWN] = node_in_ready  [southof(x,y,z)][UP];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][DOWN] = 'x;
            assign node_in_last   [nodenum(x,y,z)][DOWN] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][DOWN] = 0;
            assign node_out_ready [nodenum(x,y,z)][DOWN] = 0;
          end

          if (z < Z-1) begin
            assign node_in_flit   [nodenum(x,y,z)][UP] = node_out_flit  [northof(x,y,z)][DOWN];
            assign node_in_last   [nodenum(x,y,z)][UP] = node_out_last  [northof(x,y,z)][DOWN];
            assign node_in_valid  [nodenum(x,y,z)][UP] = node_out_valid [northof(x,y,z)][DOWN];
            assign node_out_ready [nodenum(x,y,z)][UP] = node_in_ready  [northof(x,y,z)][DOWN];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][UP] = 'x;
            assign node_in_last   [nodenum(x,y,z)][UP] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][UP] = 0;
            assign node_out_ready [nodenum(x,y,z)][UP] = 0;
          end

          if (y > 0) begin
            assign node_in_flit   [nodenum(x,y,z)][SOUTH] = node_out_flit  [southof(x,y,z)][NORTH];
            assign node_in_last   [nodenum(x,y,z)][SOUTH] = node_out_last  [southof(x,y,z)][NORTH];
            assign node_in_valid  [nodenum(x,y,z)][SOUTH] = node_out_valid [southof(x,y,z)][NORTH];
            assign node_out_ready [nodenum(x,y,z)][SOUTH] = node_in_ready  [southof(x,y,z)][NORTH];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][SOUTH] = 'x;
            assign node_in_last   [nodenum(x,y,z)][SOUTH] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][SOUTH] = 0;
            assign node_out_ready [nodenum(x,y,z)][SOUTH] = 0;
          end

          if (y < Y-1) begin
            assign node_in_flit   [nodenum(x,y,z)][NORTH] = node_out_flit  [northof(x,y,z)][SOUTH];
            assign node_in_last   [nodenum(x,y,z)][NORTH] = node_out_last  [northof(x,y,z)][SOUTH];
            assign node_in_valid  [nodenum(x,y,z)][NORTH] = node_out_valid [northof(x,y,z)][SOUTH];
            assign node_out_ready [nodenum(x,y,z)][NORTH] = node_in_ready  [northof(x,y,z)][SOUTH];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][NORTH] = 'x;
            assign node_in_last   [nodenum(x,y,z)][NORTH] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][NORTH] = 0;
            assign node_out_ready [nodenum(x,y,z)][NORTH] = 0;
          end

          if (x > 0) begin
            assign node_in_flit   [nodenum(x,y,z)][WEST] = node_out_flit  [westof(x,y,z)][EAST];
            assign node_in_last   [nodenum(x,y,z)][WEST] = node_out_last  [westof(x,y,z)][EAST];
            assign node_in_valid  [nodenum(x,y,z)][WEST] = node_out_valid [westof(x,y,z)][EAST];
            assign node_out_ready [nodenum(x,y,z)][WEST] = node_in_ready  [westof(x,y,z)][EAST];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][WEST] = 'x;
            assign node_in_last   [nodenum(x,y,z)][WEST] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][WEST] = 0;
            assign node_out_ready [nodenum(x,y,z)][WEST] = 0;
          end

          if (x < X-1) begin
            assign node_in_flit   [nodenum(x,y,z)][EAST] = node_out_flit  [eastof(x,y,z)][WEST];
            assign node_in_last   [nodenum(x,y,z)][EAST] = node_out_last  [eastof(x,y,z)][WEST];
            assign node_in_valid  [nodenum(x,y,z)][EAST] = node_out_valid [eastof(x,y,z)][WEST];
            assign node_out_ready [nodenum(x,y,z)][EAST] = node_in_ready  [eastof(x,y,z)][WEST];
          end
          else begin
            assign node_in_flit   [nodenum(x,y,z)][EAST] = 'x;
            assign node_in_last   [nodenum(x,y,z)][EAST] = 'x;
            assign node_in_valid  [nodenum(x,y,z)][EAST] = 0;
            assign node_out_ready [nodenum(x,y,z)][EAST] = 0;
          end
        end
      end
    end
  endgenerate
endmodule // mesh
