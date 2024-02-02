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

module peripheral_design (
  input  wire        pclk,
  input  wire        presetn,

  input  wire [15:0] paddr,
  input  wire [ 1:0] pstrb,
  input  wire        pwrite,
  output reg         pready,
  input  wire        psel,
  input  wire [ 7:0] pwdata,
  output reg  [ 7:0] prdata,
  input  wire        penable,
  output reg         pslverr
);

  const logic [1:0] SETUP    = 0;
  const logic [1:0] W_ENABLE = 1;
  const logic [1:0] R_ENABLE = 2;

  // RAM Memory

  logic [7:0] memory [0:255];

  logic [1:0] apb4_state;

  always @(posedge pclk or negedge presetn) begin
    if (presetn == 0) begin
      prdata <= 0;
      pready <= 1;
 
      for (int i = 0; i < 256; i++) begin
        memory[i] = 0;
      end

      apb4_state <= 0;
    end else begin
      case (apb4_state)
        SETUP: begin
          prdata <= 0;

          if (psel && !penable) begin
            if (pwrite) begin
              apb4_state <= W_ENABLE;
            end else begin
              apb4_state <= R_ENABLE;
              prdata <= memory[paddr];
            end
          end
        end
        W_ENABLE: begin
          if (psel && penable && pwrite) begin
            memory[paddr] <= pwdata;
          end
          apb4_state <= SETUP;
        end
        R_ENABLE: begin
          apb4_state <= SETUP;
        end
      endcase
    end
  end

endmodule  // peripheral_design
