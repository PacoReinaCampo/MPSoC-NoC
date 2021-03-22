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

module peripheral_noc_router_lookup_slice #(
  parameter FLIT_WIDTH = 32,
  parameter OUTPUTS    = 7
)
  (
    input clk,
    input rst,

    input                   [FLIT_WIDTH-1:0] in_flit,
    input                                    in_last,
    input      [OUTPUTS-1:0]                 in_valid,
    output                                   in_ready,

    output reg                               out_last,
    output reg              [FLIT_WIDTH-1:0] out_flit,
    output reg [OUTPUTS-1:0]                 out_valid,
    input      [OUTPUTS-1:0]                 out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //

  // This is an intermediate register that we use to avoid
  // stop-and-go behavior
  reg              [FLIT_WIDTH-1:0] reg_flit;
  reg                               reg_last;
  reg [OUTPUTS-1:0]                 reg_valid;

  // This signal selects where to store the next incoming flit
  reg pressure;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  // A backpressure in the output port leads to backpressure on the
  // input with one cycle delay
  assign in_ready = !pressure;

  always @(posedge clk) begin
    if (rst) begin
      pressure  <= 0;
      out_valid <= 0;
    end
    else begin
      if (!pressure) begin
        // We are accepting the input in this cycle, determine
        // where to store it..
        // There is no flit waiting in the register, or
        // The current flit is transfered this cycle
        if (~|out_valid | (|(out_ready & out_valid))) begin
          out_flit  <= in_flit;
          out_last  <= in_last;
          out_valid <= in_valid;
        end
        else if (|out_valid & ~|out_ready) begin
          // Otherwise if there is a flit waiting and upstream
          // not ready, push it to the second register. Enter the
          // backpressure mode.
          reg_flit  <= in_flit;
          reg_last  <= in_last;
          reg_valid <= in_valid;
          pressure  <= 1;
        end
      end
      else begin // if (!pressure)
        // We can be sure that a flit is waiting now (don't need
        // to check)
        if (|out_ready) begin
          // If the output accepted this flit, go back to
          // accepting input flits.
          out_flit  <= reg_flit;
          out_last  <= reg_last;
          out_valid <= reg_valid;
          pressure  <= 0;
        end
      end
    end
  end
endmodule
