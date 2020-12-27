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

module mpsoc_noc_wrapper #(
  parameter FLIT_WIDTH       = 34,
  parameter CHANNELS         = 9,

  parameter ENABLE_VCHANNELS = 1,

  parameter X                = 2,
  parameter Y                = 2,

  parameter BUFFER_SIZE_IN   = 4,
  parameter BUFFER_SIZE_OUT  = 4,

  parameter NODES            = 4
)
  (
    input clk,
    input rst
  );

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //DUT
  noc_mesh2d #(
    .FLIT_WIDTH       (FLIT_WIDTH),
    .CHANNELS         (CHANNELS),

    .ENABLE_VCHANNELS (ENABLE_VCHANNELS),

    .X                (X),
    .Y                (Y),

    .BUFFER_SIZE_IN   (BUFFER_SIZE_IN),
    .BUFFER_SIZE_OUT  (BUFFER_SIZE_OUT),

    .NODES            (NODES)
  )
  mesh (
    .rst       ( rst ),
    .clk       ( clk ),

    .in_flit   ( '0 ),
    .in_last   ( '0 ),
    .in_valid  ( '0 ),
    .in_ready  (    ),

    .out_flit  (    ),
    .out_last  (    ),
    .out_valid (    ),
    .out_ready ( '0 )
  );
endmodule
