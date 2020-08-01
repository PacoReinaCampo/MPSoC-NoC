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
//              MPSoC-RISCV / OR1K / MSP430 CPU                               //
//              General Purpose Input Output Bridge                           //
//              Network on Chip 2D Interface                                  //
//              Universal Verification Methodology                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2020-2021 by the author(s)
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

interface dut_if #(
  parameter FLIT_WIDTH = 32,
  parameter CHANNELS   = 7,

  parameter ENABLE_VCHANNELS = 1,

  parameter X = 2,
  parameter Y = 2,

  parameter BUFFER_SIZE_IN  = 4,
  parameter BUFFER_SIZE_OUT = 4,

  parameter NODES = X*Y
)
  ();

  logic clk;
  logic rst;

  logic [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] in_flit;
  logic [NODES-1:0][CHANNELS-1:0]                 in_last;
  logic [NODES-1:0][CHANNELS-1:0]                 in_valid;
  logic [NODES-1:0][CHANNELS-1:0]                 in_ready;

  logic [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] out_flit;
  logic [NODES-1:0][CHANNELS-1:0]                 out_last;
  logic [NODES-1:0][CHANNELS-1:0]                 out_valid;
  logic [NODES-1:0][CHANNELS-1:0]                 out_ready;

  //Master Clocking block - used for Drivers
  clocking master_cb @(posedge clk);
    output in_flit;
    output in_last;
    output in_valid;
    input  in_ready;

    input  out_flit;
    input  out_last;
    input  out_valid;
    output out_ready;
  endclocking: master_cb

  //Slave Clocking Block - used for any Slave BFMs
  clocking slave_cb @(posedge clk);
    input  in_flit;
    input  in_last;
    input  in_valid;
    output in_ready;

    output out_flit;
    output out_last;
    output out_valid;
    input  out_ready;
  endclocking: slave_cb

  //Monitor Clocking block - For sampling by monitor components
  clocking monitor_cb @(posedge clk);
    input in_flit;
    input in_last;
    input in_valid;
    input in_ready;

    input out_flit;
    input out_last;
    input out_valid;
    input out_ready;
  endclocking: monitor_cb

  modport master(clocking master_cb);
  modport slave(clocking slave_cb);
  modport passive(clocking monitor_cb);
endinterface
