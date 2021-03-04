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
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

module noc_mesh4d #(
  parameter FLIT_WIDTH = 32,
  parameter CHANNELS   = 1,

  parameter logic ENABLE_VCHANNELS = 1,

  parameter T = 'x,
  parameter X = 'x,
  parameter Y = 'x,
  parameter Z = 'x,

  parameter BUFFER_SIZE_IN  = 4,
  parameter BUFFER_SIZE_OUT = 4,

  parameter NODES = X*Y*Z*T
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
  localparam FWARD = 1;
  localparam UP    = 2;
  localparam NORTH = 3;
  localparam EAST  = 4;
  localparam BWARD = 5;
  localparam DOWN  = 6;
  localparam SOUTH = 7;
  localparam WEST  = 8;

  // Those are direction codings that match the wiring indices
  // above. The router is configured to use those to select the
  // proper output port.
  localparam DIR_LOCAL = 9'b000000001;
  localparam DIR_FWARD = 9'b000000010;
  localparam DIR_UP    = 9'b000000100;
  localparam DIR_NORTH = 9'b000001000;
  localparam DIR_EAST  = 9'b000010000;
  localparam DIR_BWARD = 9'b000100000;
  localparam DIR_DOWN  = 9'b001000000;
  localparam DIR_SOUTH = 9'b010000000;
  localparam DIR_WEST  = 9'b100000000;

  // Number of physical channels between routers. This is essentially
  // the number of flits (and last) between the routers.
  localparam PCHANNELS = ENABLE_VCHANNELS ? 1 : CHANNELS;

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //

  genvar c, p, x, y, z, t;

  wire [8:0][PCHANNELS-1:0][FLIT_WIDTH-1:0]     node_in_flit   [0:NODES-1];
  wire [8:0][PCHANNELS-1:0]                     node_in_last   [0:NODES-1];
  wire [8:0][ CHANNELS-1:0]                     node_in_valid  [0:NODES-1];
  wire [8:0][ CHANNELS-1:0]                     node_in_ready  [0:NODES-1];
  wire [8:0][PCHANNELS-1:0][FLIT_WIDTH-1:0]     node_out_flit  [0:NODES-1];
  wire [8:0][PCHANNELS-1:0]                     node_out_last  [0:NODES-1];
  wire [8:0][ CHANNELS-1:0]                     node_out_valid [0:NODES-1];
  wire [8:0][ CHANNELS-1:0]                     node_out_ready [0:NODES-1];

  wire [8:0][FLIT_WIDTH-1:0] phys_in_flit;
  wire [8:0]                 phys_in_last;
  wire [8:0]                 phys_in_valid;
  wire [8:0]                 phys_in_ready;
  wire [8:0][FLIT_WIDTH-1:0] phys_out_flit;
  wire [8:0]                 phys_out_last;
  wire [8:0]                 phys_out_valid;
  wire [8:0]                 phys_out_ready;

  //////////////////////////////////////////////////////////////////
  //
  // Functions
  //

  // Get the node number
  function integer nodenum(input integer x, input integer y, input integer z, input integer t);
    nodenum = x+y*X+z*X*Y+t*X*Y*Z;
  endfunction // nodenum

  // Get the node up of position
  function integer fwardof(input integer x, input integer y, input integer z, input integer t);
    fwardof = x+y*X+z*X*Y+(t+1)*X*Y*Z;
  endfunction // fwardof

  // Get the node up of position
  function integer upof(input integer x, input integer y, input integer z, input integer t);
    upof = x+y*X+(z+1)*X*Y+t*X*Y*Z;
  endfunction // upof

  // Get the node north of position
  function integer northof(input integer x, input integer y, input integer z, input integer t);
    northof = x+(y+1)*X+z*X*Y+t*X*Y*Z;
  endfunction // northof

  // Get the node east of position
  function integer eastof(input integer x, input integer y, input integer z, input integer t);
    eastof  = (x+1)+y*X+z*X*Y+t*X*Y*Z;
  endfunction // eastof

  // Get the node down of position
  function integer bwardof(input integer x, input integer y, input integer z, input integer t);
    bwardof = x+y*X+z*X*Y+(t-1)*X*Y*Z;
  endfunction // bwardof

  // Get the node down of position
  function integer downof(input integer x, input integer y, input integer z, input integer t);
    downof = x+y*X+(z-1)*X*Y+t*X*Y*Z;
  endfunction // downof

  // Get the node south of position
  function integer southof(input integer x, input integer y, input integer z, input integer t);
    southof = x+(y-1)*X+z*X*Y+t*X*Y*Z;
  endfunction // southof

  // Get the node west of position
  function integer westof(input integer x, input integer y, input integer z, input integer t);
    westof = (x-1)+y*X+z*X*Y+t*X*Y*Z;
  endfunction // westof

  // This generates the lookup table for each individual node
  function [NODES-1:0][8:0] genroutes(input integer x, input integer y, input integer z, input integer t);
    integer td,zd,yd,xd;
    integer nd;
    reg [8:0] d;

    genroutes = {NODES{9'b000000000}};

    for (td = 0; td < T; td=td+1) begin : inner_loop_t
      for (zd = 0; zd < Z; zd=zd+1) begin : inner_loop_z
        for (yd = 0; yd < Y; yd=yd+1) begin : inner_loop_y
          for (xd = 0; xd < X; xd=xd+1) begin : inner_loop_x
            nd = nodenum(xd, yd, zd, td);
            d = 9'b000000000;
            if ((xd==x) && (yd==y) && (zd==z) && (td==t)) begin
              d = DIR_LOCAL;
            end
            else if ((xd==x) && (yd==z) && (zd==z)) begin
              if (td<t) begin
                d = DIR_BWARD;
              end
              else begin
                d = DIR_FWARD;
              end
            end
            else if ((td==t) && (xd==x) && (yd==z)) begin
              if (zd<z) begin
                d = DIR_DOWN;
              end
              else begin
                d = DIR_UP;
              end
            end
            else if ((td==t) && (xd==x) && (zd==z)) begin
              if (yd<y) begin
                d = DIR_SOUTH;
              end
              else begin
                d = DIR_NORTH;
              end
            end
            else if (((td==t) && yd==y) && (zd==z)) begin
              if (xd<x) begin
                d = DIR_WEST;
              end
              else begin
                d = DIR_EAST;
              end
            end
            genroutes[nd] = d;
          end
        end
      end
    end
  endfunction

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  generate
    // With virtual channels, we generate one router per node and
    // then add a virtual channel muxer between the tiles and the
    // local router input. On the output the "demux" is plain
    // wiring.

    // Arrays of wires between the routers. Each router has a
    // pair of NoC wires per direction and below those are hooked
    // up.
    for (t = 0; t < T; t=t+1) begin : tdir
      for (z = 0; z < Z; z=z+1) begin : zdir
        for (y = 0; y < Y; y=y+1) begin : ydir
          for (x = 0; x < X; x=x+1) begin : xdir
            if (ENABLE_VCHANNELS) begin
              // Mux inputs to virtual channels
              noc_vchannel_mux #(
                .FLIT_WIDTH (FLIT_WIDTH),
                .CHANNELS   (CHANNELS)
              )
              u_vc_mux (
                .clk (clk),
                .rst (rst),

                .in_flit   (in_flit  [nodenum(x,y,z,t)]),
                .in_last   (in_last  [nodenum(x,y,z,t)]),
                .in_valid  (in_valid [nodenum(x,y,z,t)]),
                .in_ready  (in_ready [nodenum(x,y,z,t)]),

                .out_flit  (node_in_flit  [nodenum(x,y,z,t)][LOCAL][0]),
                .out_last  (node_in_last  [nodenum(x,y,z,t)][LOCAL][0]),
                .out_valid (node_in_valid [nodenum(x,y,z,t)][LOCAL]),
                .out_ready (node_in_ready [nodenum(x,y,z,t)][LOCAL])
              );

              // Replicate the flit to all output channels and the
              // rest is just wiring
              for (c = 0; c < CHANNELS; c=c+1) begin : flit_demux
                assign out_flit[nodenum(x,y,z,t)][c] = node_out_flit[nodenum(x,y,z,t)][LOCAL][0];
                assign out_last[nodenum(x,y,z,t)][c] = node_out_last[nodenum(x,y,z,t)][LOCAL][0];
              end
              assign out_valid[nodenum(x,y,z,t)] = node_out_valid[nodenum(x,y,z,t)][LOCAL];
              assign node_out_ready[nodenum(x,y,z,t)][LOCAL] = out_ready[nodenum(x,y,z,t)];

              // Instantiate the router. We call a function to
              // generate the routing table
              noc_router #(
                .FLIT_WIDTH      (FLIT_WIDTH),
                .VCHANNELS       (CHANNELS),
                .INPUTS          (9),
                .OUTPUTS         (9),
                .BUFFER_SIZE_IN  (BUFFER_SIZE_IN),
                .BUFFER_SIZE_OUT (BUFFER_SIZE_OUT),
                .DESTS           (NODES)
              )
              u_router (
                .clk (clk),
                .rst (rst),

                .ROUTES    (genroutes(x,y,z,t)),

                .in_flit   (node_in_flit  [nodenum(x,y,z,t)]),
                .in_last   (node_in_last  [nodenum(x,y,z,t)]),
                .in_valid  (node_in_valid [nodenum(x,y,z,t)]),
                .in_ready  (node_in_ready [nodenum(x,y,z,t)]),

                .out_flit  (node_out_flit  [nodenum(x,y,z,t)]),
                .out_last  (node_out_last  [nodenum(x,y,z,t)]),
                .out_valid (node_out_valid [nodenum(x,y,z,t)]),
                .out_ready (node_out_ready [nodenum(x,y,z,t)])
              );
            end
            else begin
              assign out_flit  [nodenum(x,y,z,t)] = node_out_flit  [nodenum(x,y,z,t)][LOCAL];
              assign out_last  [nodenum(x,y,z,t)] = node_out_last  [nodenum(x,y,z,t)][LOCAL];
              assign out_valid [nodenum(x,y,z,t)] = node_out_valid [nodenum(x,y,z,t)][LOCAL];

              assign node_out_ready [nodenum(x,y,z,t)][LOCAL] = out_ready [nodenum(x,y,z,t)];

              assign node_in_flit  [nodenum(x,y,z,t)][LOCAL] = in_flit  [nodenum(x,y,z,t)];
              assign node_in_last  [nodenum(x,y,z,t)][LOCAL] = in_last  [nodenum(x,y,z,t)];
              assign node_in_valid [nodenum(x,y,z,t)][LOCAL] = in_valid [nodenum(x,y,z,t)];

              assign in_ready [nodenum(x,y,z,t)] = node_in_ready [nodenum(x,y,z,t)][LOCAL];

              for (c = 0; c < CHANNELS; c=c+1) begin
                // First we just need to re-arrange the wires a bit
                // because the array structure varies a bit here:
                // The directions and channels and differently
                // multiplexed here. Hence create some helper
                // arrays.

                // Re-wire the ports
                for (p = 0; p < 7; p=p+1) begin
                  assign phys_in_flit  [p] = node_in_flit  [nodenum(x,y,z,t)][p][c];
                  assign phys_in_last  [p] = node_in_last  [nodenum(x,y,z,t)][p][c];
                  assign phys_in_valid [p] = node_in_valid [nodenum(x,y,z,t)][p][c];

                  assign node_in_ready [nodenum(x,y,z,t)][p][c] = phys_in_ready [p];

                  assign node_out_flit  [nodenum(x,y,z,t)][p][c] = phys_out_flit  [p];
                  assign node_out_last  [nodenum(x,y,z,t)][p][c] = phys_out_last  [p];
                  assign node_out_valid [nodenum(x,y,z,t)][p][c] = phys_out_valid [p];

                  assign phys_out_ready [p] = node_out_ready [nodenum(x,y,z,t)][p][c];
                end

                // Instantiate the router. We call a function to
                // generate the routing table
                noc_router #(
                  .FLIT_WIDTH (FLIT_WIDTH),
                  .VCHANNELS  (1),
                  .INPUTS     (9),
                  .OUTPUTS    (9),
                  .DESTS      (NODES)
                )
                u_router (
                  .clk (clk),
                  .rst (rst),

                  .ROUTES    (genroutes(x,y,z,t)),

                  .in_flit   (phys_in_flit),
                  .in_last   (phys_in_last),
                  .in_valid  (phys_in_valid),
                  .in_ready  (phys_in_ready),

                  .out_flit  (phys_out_flit),
                  .out_last  (phys_out_last),
                  .out_valid (phys_out_valid),
                  .out_ready (phys_out_ready)
                );
              end
            end

            // The following are all the connections of the routers
            // in the four directions. If the router is on an outer
            // border, tie off.
            if (t > 0) begin
              assign node_in_flit   [nodenum(x,y,z,t)][BWARD] = node_out_flit  [bwardof(x,y,z,t)][FWARD];
              assign node_in_last   [nodenum(x,y,z,t)][BWARD] = node_out_last  [bwardof(x,y,z,t)][FWARD];
              assign node_in_valid  [nodenum(x,y,z,t)][BWARD] = node_out_valid [bwardof(x,y,z,t)][FWARD];
              assign node_out_ready [nodenum(x,y,z,t)][BWARD] = node_in_ready  [bwardof(x,y,z,t)][FWARD];
            end
            else begin
              assign node_in_flit   [nodenum(x,y,z,t)][BWARD] = 'x;
              assign node_in_last   [nodenum(x,y,z,t)][BWARD] = 'x;
              assign node_in_valid  [nodenum(x,y,z,t)][BWARD] = 0;
              assign node_out_ready [nodenum(x,y,z,t)][BWARD] = 0;
            end

            if (t < T-1) begin
              assign node_in_flit   [nodenum(x,y,z,t)][FWARD] = node_out_flit  [fwardof(x,y,z,t)][BWARD];
              assign node_in_last   [nodenum(x,y,z,t)][FWARD] = node_out_last  [fwardof(x,y,z,t)][BWARD];
              assign node_in_valid  [nodenum(x,y,z,t)][FWARD] = node_out_valid [fwardof(x,y,z,t)][BWARD];
              assign node_out_ready [nodenum(x,y,z,t)][FWARD] = node_in_ready  [fwardof(x,y,z,t)][BWARD];
            end
            else begin
              assign node_in_flit   [nodenum(x,y,z,t)][FWARD] = 'x;
              assign node_in_last   [nodenum(x,y,z,t)][FWARD] = 'x;
              assign node_in_valid  [nodenum(x,y,z,t)][FWARD] = 0;
              assign node_out_ready [nodenum(x,y,z,t)][FWARD] = 0;
            end

            if (z > 0) begin
              assign node_in_flit   [nodenum(x,y,z,t)][DOWN] = node_out_flit  [southof(x,y,z,t)][UP];
              assign node_in_last   [nodenum(x,y,z,t)][DOWN] = node_out_last  [southof(x,y,z,t)][UP];
              assign node_in_valid  [nodenum(x,y,z,t)][DOWN] = node_out_valid [southof(x,y,z,t)][UP];
              assign node_out_ready [nodenum(x,y,z,t)][DOWN] = node_in_ready  [southof(x,y,z,t)][UP];
            end
            else begin
              assign node_in_flit   [nodenum(x,y,z,t)][DOWN] = 'x;
              assign node_in_last   [nodenum(x,y,z,t)][DOWN] = 'x;
              assign node_in_valid  [nodenum(x,y,z,t)][DOWN] = 0;
              assign node_out_ready [nodenum(x,y,z,t)][DOWN] = 0;
            end

            if (z < Z-1) begin
              assign node_in_flit   [nodenum(x,y,z,t)][UP] = node_out_flit  [northof(x,y,z,t)][DOWN];
              assign node_in_last   [nodenum(x,y,z,t)][UP] = node_out_last  [northof(x,y,z,t)][DOWN];
              assign node_in_valid  [nodenum(x,y,z,t)][UP] = node_out_valid [northof(x,y,z,t)][DOWN];
              assign node_out_ready [nodenum(x,y,z,t)][UP] = node_in_ready  [northof(x,y,z,t)][DOWN];
            end
            else begin
              assign node_in_flit   [nodenum(x,y,z,t)][UP] = 'x;
              assign node_in_last   [nodenum(x,y,z,t)][UP] = 'x;
              assign node_in_valid  [nodenum(x,y,z,t)][UP] = 0;
              assign node_out_ready [nodenum(x,y,z,t)][UP] = 0;
            end

            if (y > 0) begin
              assign node_in_flit   [nodenum(x,y,z,t)][SOUTH] = node_out_flit  [southof(x,y,z,t)][NORTH];
              assign node_in_last   [nodenum(x,y,z,t)][SOUTH] = node_out_last  [southof(x,y,z,t)][NORTH];
              assign node_in_valid  [nodenum(x,y,z,t)][SOUTH] = node_out_valid [southof(x,y,z,t)][NORTH];
              assign node_out_ready [nodenum(x,y,z,t)][SOUTH] = node_in_ready  [southof(x,y,z,t)][NORTH];
            end
            else begin
              assign node_in_flit   [nodenum(x,y,z,t)][SOUTH] = 'x;
              assign node_in_last   [nodenum(x,y,z,t)][SOUTH] = 'x;
              assign node_in_valid  [nodenum(x,y,z,t)][SOUTH] = 0;
              assign node_out_ready [nodenum(x,y,z,t)][SOUTH] = 0;
            end

            if (y < Y-1) begin
              assign node_in_flit   [nodenum(x,y,z,t)][NORTH] = node_out_flit  [northof(x,y,z,t)][SOUTH];
              assign node_in_last   [nodenum(x,y,z,t)][NORTH] = node_out_last  [northof(x,y,z,t)][SOUTH];
              assign node_in_valid  [nodenum(x,y,z,t)][NORTH] = node_out_valid [northof(x,y,z,t)][SOUTH];
              assign node_out_ready [nodenum(x,y,z,t)][NORTH] = node_in_ready  [northof(x,y,z,t)][SOUTH];
            end
            else begin
              assign node_in_flit   [nodenum(x,y,z,t)][NORTH] = 'x;
              assign node_in_last   [nodenum(x,y,z,t)][NORTH] = 'x;
              assign node_in_valid  [nodenum(x,y,z,t)][NORTH] = 0;
              assign node_out_ready [nodenum(x,y,z,t)][NORTH] = 0;
            end

            if (x > 0) begin
              assign node_in_flit   [nodenum(x,y,z,t)][WEST] = node_out_flit  [westof(x,y,z,t)][EAST];
              assign node_in_last   [nodenum(x,y,z,t)][WEST] = node_out_last  [westof(x,y,z,t)][EAST];
              assign node_in_valid  [nodenum(x,y,z,t)][WEST] = node_out_valid [westof(x,y,z,t)][EAST];
              assign node_out_ready [nodenum(x,y,z,t)][WEST] = node_in_ready  [westof(x,y,z,t)][EAST];
            end
            else begin
              assign node_in_flit   [nodenum(x,y,z,t)][WEST] = 'x;
              assign node_in_last   [nodenum(x,y,z,t)][WEST] = 'x;
              assign node_in_valid  [nodenum(x,y,z,t)][WEST] = 0;
              assign node_out_ready [nodenum(x,y,z,t)][WEST] = 0;
            end

            if (x < X-1) begin
              assign node_in_flit   [nodenum(x,y,z,t)][EAST] = node_out_flit  [eastof(x,y,z,t)][WEST];
              assign node_in_last   [nodenum(x,y,z,t)][EAST] = node_out_last  [eastof(x,y,z,t)][WEST];
              assign node_in_valid  [nodenum(x,y,z,t)][EAST] = node_out_valid [eastof(x,y,z,t)][WEST];
              assign node_out_ready [nodenum(x,y,z,t)][EAST] = node_in_ready  [eastof(x,y,z,t)][WEST];
            end
            else begin
              assign node_in_flit   [nodenum(x,y,z,t)][EAST] = 'x;
              assign node_in_last   [nodenum(x,y,z,t)][EAST] = 'x;
              assign node_in_valid  [nodenum(x,y,z,t)][EAST] = 0;
              assign node_out_ready [nodenum(x,y,z,t)][EAST] = 0;
            end
          end
        end
      end
    end
  endgenerate
endmodule
