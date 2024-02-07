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

class peripheral_uvm_sequence_item extends uvm_sequence_item;

  bit                       presetn;

  rand bit [PADDR_SIZE-1:0] paddr;
  bit      [           1:0] pstrb;
  bit                       pwrite;
  bit                       pready;
  bit                       psel;
  rand bit [PDATA_SIZE-1:0] pwdata;
  bit      [PDATA_SIZE-1:0] prdata;
  bit                       penable;
  bit                       pslverr;

  // Constructor
  function new(string name = "peripheral_uvm_sequence_item");
    super.new(name);
  endfunction

  // Utility and Field declarations
  `uvm_object_utils_begin(peripheral_uvm_sequence_item)

  `uvm_field_int(presetn, UVM_ALL_ON)

  `uvm_field_int(paddr, UVM_ALL_ON)
  `uvm_field_int(pstrb, UVM_ALL_ON)
  `uvm_field_int(pwrite, UVM_ALL_ON)
  `uvm_field_int(pready, UVM_ALL_ON)
  `uvm_field_int(psel, UVM_ALL_ON)
  `uvm_field_int(pwdata, UVM_ALL_ON)
  `uvm_field_int(prdata, UVM_ALL_ON)
  `uvm_field_int(penable, UVM_ALL_ON)
  `uvm_field_int(pslverr, UVM_ALL_ON)

  `uvm_object_utils_end

  // Constraints
  constraint paddr_c {paddr inside {[32'h00000000 : 32'hFFFFFFFF]};}
  constraint pwdata_c {pwdata inside {[32'h00000000 : 32'hFFFFFFFF]};}
endclass
