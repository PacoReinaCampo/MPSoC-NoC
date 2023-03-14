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
// Copyright (c) 2020-2021 by the author(s)
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

class peripheral_bus_generator extends peripheral_base_transaction;
  bit TrWrite;  //read/write transaction
  int TrType;
  int TrSize;

  extern function new();
  extern virtual function bit compare(input peripheral_base_transaction to);
  extern virtual function peripheral_base_transaction copy(input peripheral_base_transaction to = null);
  extern virtual function void display(input string prefix = "");
endclass : peripheral_bus_generator

////////////////////////////////////////////////////////////////////////////////
//
// Class Methods
//
function peripheral_bus_generator::new();
  super.new();
endfunction : new

function bit peripheral_bus_generator::compare(input peripheral_base_transaction to);
  peripheral_bus_generator cmp;

  if (!$cast(cmp, to))  //is 'to' the correct type?
    $finish;

  return ((this.TrWrite == cmp.TrWrite) && (this.TrType == cmp.TrType) && (this.TrSize == cmp.TrSize));
endfunction : compare

function peripheral_base_transaction peripheral_bus_generator::copy(input peripheral_base_transaction to = null);
  peripheral_bus_generator cp;

  if (to == null) cp = new();
  else $cast(cp, to);
endfunction : copy
