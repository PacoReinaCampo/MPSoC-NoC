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
//   Paco Reina Campo <pacoreinacampo@queenfield.tech>

module peripheral_arbiter_rr_testbench;

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  parameter N = 2;

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  reg [N-1:0] req;
  reg         en;
  reg [N-1:0] gnt;

  reg [N-1:0] nxt_gnt;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // DUT
  peripheral_arbiter_rr #(
    .N(N)
  ) arbiter_rr (
    .req(req),
    .en (en),
    .gnt(gnt),

    .nxt_gnt(nxt_gnt)
  );

  // STIMULUS
  initial begin
    // Dump waves
    $dumpfile("system.vcd");
    $dumpvars(0, peripheral_arbiter_rr_testbench);

    en  = 1'b0;
    req = 2'b00;
    gnt = 2'b00;

    en  = 1'b1;
    req = 2'b11;
    gnt = 2'b11;
    #1;

    en  = 1'b0;
    req = 2'b01;
    gnt = 2'b01;
    #2;

    en  = 1'b1;
    req = 2'b10;
    gnt = 2'b10;
    #3;

    en  = 1'b0;
    req = 2'b01;
    gnt = 2'b10;
    #4;

    en  = 1'b1;
    req = 2'b10;
    gnt = 2'b01;
    #5;

    $display("End");
    $finish();
  end
endmodule
