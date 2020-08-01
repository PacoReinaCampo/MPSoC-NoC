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

//Include UVM files
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;

//Include common files
`include "noc2d_transaction.svh"
`include "noc2d_sequence.svh"
`include "noc2d_sequencer.svh"
`include "noc2d_driver.svh"
`include "noc2d_monitor.svh"
`include "noc2d_agent.svh"
`include "noc2d_scoreboard.svh"
`include "noc2d_subscriber.svh"
`include "noc2d_env.svh"
`include "noc2d_test.svh"

module test;

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //

  parameter FLIT_WIDTH = 32;
  parameter CHANNELS   = 7;

  parameter ENABLE_VCHANNELS = 1;

  parameter X = 2;
  parameter Y = 2;

  parameter BUFFER_SIZE_IN  = 4;
  parameter BUFFER_SIZE_OUT = 4;

  localparam NODES = X*Y;

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //

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

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  dut_if noc2d_if();

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
  dut (
    .clk       ( noc2d_if.clk ),
    .rst       ( noc2d_if.rst ),

    .in_flit   ( noc2d_if.in_flit  ),
    .in_last   ( noc2d_if.in_last  ),
    .in_valid  ( noc2d_if.in_valid ),
    .in_ready  ( noc2d_if.in_ready ),

    .out_flit  ( noc2d_if.out_flit  ),
    .out_last  ( noc2d_if.out_last  ),
    .out_valid ( noc2d_if.out_valid ),
    .out_ready ( noc2d_if.out_ready )
  );

  initial begin
    noc2d_if.clk=0;
  end

  //Generate a clock
  always begin
    #10 noc2d_if.clk = ~noc2d_if.clk;
  end

  initial begin
    noc2d_if.rst=0;
    repeat (1) @(posedge noc2d_if.clk);
    noc2d_if.rst=1;
  end

  initial begin
    uvm_config_db#(virtual dut_if)::set( null, "uvm_test_top", "vif", noc2d_if);
    run_test("noc2d_test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
