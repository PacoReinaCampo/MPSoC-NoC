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

class peripheral_monitor;
  // Interface instantiation
  virtual peripheral_design_if vif;

  mailbox monitor_to_scoreboard;

  // Constructor
  function new(mailbox monitor_to_scoreboard, virtual peripheral_design_if vif);
    this.vif = vif;

    this.monitor_to_scoreboard = monitor_to_scoreboard;
  endfunction

  task run;
    forever begin
      // Transaction method instantiation
      peripheral_transaction monitor_transaction;

      // Create transaction method
      monitor_transaction = new();

      // Task: Write
      @(posedge vif.pclk);
      monitor_transaction.paddr  = vif.paddr;
      monitor_transaction.pwrite = vif.pwrite;
      monitor_transaction.psel   = vif.psel;
      monitor_transaction.pwdata = vif.pwdata;

      @(posedge vif.pclk);
      monitor_transaction.psel    = vif.psel;
      monitor_transaction.penable = vif.penable;

      @(posedge vif.pclk);
      monitor_transaction.psel    = vif.psel;
      monitor_transaction.penable = vif.penable;

      monitor_transaction.prdata = vif.prdata;

      // Task: Read
      @(posedge vif.pclk);
      monitor_transaction.pwrite  = vif.pwrite;
      monitor_transaction.psel    = vif.psel;
      monitor_transaction.penable = vif.penable;

      @(posedge vif.pclk);
      monitor_transaction.paddr   = vif.paddr;
      monitor_transaction.psel    = vif.psel;
      monitor_transaction.penable = vif.penable;

      @(posedge vif.pclk);
      monitor_transaction.psel    = vif.psel;
      monitor_transaction.penable = vif.penable;

      monitor_transaction.prdata = vif.prdata;

      monitor_to_scoreboard.put(monitor_transaction);
    end
  endtask
endclass
