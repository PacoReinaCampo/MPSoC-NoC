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
//              Wishbone Bus Interface                                        //
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
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

module mpsoc_noc_testbench;

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //
  parameter FLIT_WIDTH       = 34;
  parameter CHANNELS         = 9;

  parameter ENABLE_VCHANNELS = 1;

  parameter T                = 2;
  parameter X                = 2;
  parameter Y                = 2;
  parameter Z                = 2;

  parameter BUFFER_SIZE_IN   = 4;
  parameter BUFFER_SIZE_OUT  = 4;

  parameter NODES            = 16;

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  wire clk;
  wire rst;

  wire [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] mpsoc_noc_out_flit;
  wire [NODES-1:0][CHANNELS-1:0]                 mpsoc_noc_out_last;
  wire [NODES-1:0][CHANNELS-1:0]                 mpsoc_noc_out_valid;
  wire [NODES-1:0][CHANNELS-1:0]                 mpsoc_noc_out_ready;

  wire [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] mpsoc_noc_in_flit;
  wire [NODES-1:0][CHANNELS-1:0]                 mpsoc_noc_in_last;
  wire [NODES-1:0][CHANNELS-1:0]                 mpsoc_noc_in_valid;
  wire [NODES-1:0][CHANNELS-1:0]                 mpsoc_noc_in_ready;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //DUT
  noc_mesh4d #(
    .FLIT_WIDTH       (FLIT_WIDTH),
    .CHANNELS         (CHANNELS),

    .ENABLE_VCHANNELS (ENABLE_VCHANNELS),

    .T                (T),
    .X                (X),
    .Y                (Y),
    .Z                (Z),

    .BUFFER_SIZE_IN   (BUFFER_SIZE_IN),
    .BUFFER_SIZE_OUT  (BUFFER_SIZE_OUT),

    .NODES            (NODES)
  )
  mesh (
    .rst       ( rst ),
    .clk       ( clk ),

    .in_flit   ( mpsoc_noc_in_flit  ),
    .in_last   ( mpsoc_noc_in_last  ),
    .in_valid  ( mpsoc_noc_in_valid ),
    .in_ready  ( mpsoc_noc_in_ready ),

    .out_flit  ( mpsoc_noc_out_flit  ),
    .out_last  ( mpsoc_noc_out_last  ),
    .out_valid ( mpsoc_noc_out_valid ),
    .out_ready ( mpsoc_noc_out_ready )
  );
endmodule
