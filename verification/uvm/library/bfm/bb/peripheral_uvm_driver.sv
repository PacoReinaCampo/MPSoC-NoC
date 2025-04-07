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

class peripheral_uvm_driver extends uvm_driver #(peripheral_uvm_sequence_item);
  // Virtual Interface
  virtual peripheral_design_if vif;

  // Utility declaration
  `uvm_component_utils(peripheral_uvm_driver)

  // Constructor
  function new(string name = "peripheral_uvm_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual peripheral_design_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal(get_type_name(), "Not set at top level");
    end
  endfunction

  // Run phase
  task run_phase(uvm_phase phase);
    forever begin
      // Driver to the DUT
      seq_item_port.get_next_item(req);

      // Single Write Transaction
      write_phase_single();

      // Single Read Transaction
      read_phase_single();

      seq_item_port.item_done();
    end
  endtask

  // Task: Single Write Transaction
  task write_phase_single;
    begin
      @(posedge vif.mclk);
      vif.addr <= 15;
      vif.din  <= req.din;
      vif.cen  <= 0;
      vif.wen  <= 0;

      @(posedge vif.mclk);
      vif.cen  <= 1;
    end
  endtask

  // Task: Single Read Transaction
  task read_phase_single;
    begin
      @(posedge vif.mclk);
      vif.addr <= 15;
      vif.din  <= req.din;
      vif.cen  <= 0;
      vif.wen  <= 1;

      @(posedge vif.mclk);
      vif.cen  <= 1;
    end
  endtask
endclass
