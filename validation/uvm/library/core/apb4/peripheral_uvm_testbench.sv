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

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "peripheral_uvm_interface.sv"
`include "peripheral_uvm_test.sv"

module peripheral_uvm_testbench;
  // Clock and Reset declaration
  bit PCLK;

  // Clock Generation
  always #1 PCLK = ~PCLK;

  initial begin
    PCLK = 0;
  end

  // Virtual interface
  peripheral_design_if vif (PCLK);

  // DUT instantiation
  peripheral_design dut (
    // Global Signals
    .PCLK   (vif.PCLK),
    .PRESETn(vif.PRESETn),

    .PADDR   (vif.PADDR),
    .PWRITE  (vif.PWRITE),
    .PSEL    (vif.PSEL),
    .PENABLE (vif.PENABLE),
    .PWDATA  (vif.PWDATA),
    .PRDATA  (vif.PRDATA),
    .PREADY  (vif.PREADY),
    .PSLVERR (vif.PSLVERR)
  );

  initial begin
    // Passing the interface handle to lower heirarchy using set method
    uvm_config_db#(virtual peripheral_design_if)::set(uvm_root::get(), "*", "vif", vif);

    // Enable wave dump
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

  // Calling TestCase
  initial begin
    run_test("base_test");
  end
endmodule
