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
//              Peripheral-NTM for MPSoC                                      //
//              Neural Turing Machine for MPSoC                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022-2025 by the author(s)
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

import peripheral_bb_pkg::*;

module peripheral_design #(
  parameter AW = 32,  // Address bus
  parameter DW = 32,  // Data bus

  parameter MEMORY_SIZE = 256  // Memory Size
) (
  input  wire          mclk,  // RAM clock
  input  wire          rst,   // Asynchronous Reset - active low

  input  wire [AW-1:0] addr,  // RAM address
  output reg  [DW-1:0] dout,  // RAM data input
  input  wire [DW-1:0] din,   // RAM data output
  input  wire          cen,   // RAM chip enable (low active)
  input  wire [   1:0] wen    // RAM write enable (low active)
);

  // RAM Memory

  reg  [DW-1:0] memory [0:(MEMORY_SIZE/2)-1];

  reg  [AW-1:0] ram_address_register;

  wire [DW-1:0] memory_value = memory[addr];

  always @(posedge mclk) begin
    if (~rst) begin
      memory[addr] <= 0;
    end else if (~cen & addr < (MEMORY_SIZE/2)) begin
      if (wen == 2'b00) begin
        memory[addr] <= din;
      end else if (wen == 2'b01) begin
        memory[addr] <= {din[DW-1:DW/2], memory_value[DW/2-1:0]};
      end else if (wen == 2'b10) begin
        memory[addr] <= {memory_value[DW-1:DW/2], din[DW/2-1:0]};
      end

      ram_address_register <= addr;
    end
  end

  assign dout = memory[ram_address_register];

endmodule  // peripheral_design
