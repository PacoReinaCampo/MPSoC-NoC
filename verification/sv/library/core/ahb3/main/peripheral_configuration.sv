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

import peripheral_package::*;

class peripheral_configuration #(
  parameter HADDR_SIZE = 32
) extends peripheral_base_configuration;
  int                    nMasters,                                                                                                                  nSlaves;  //number of master and slave ports

  int                    MinTransactions                                                   = 100_000;  //Minimum number of transactions per master
  int                    MaxTransactions                                                   = 1000_000;  //Maximum number of transactions per master
  int                    nTransactions     [];  //Actual number of transactions per master

  logic [           2:0] master_priority   [];  //TODO
  logic [HADDR_SIZE-1:0] slave_address_base[],                                                                                                      slave_address_mask                          [];

  extern function new(input int nmasters, nslaves, input logic [2:0] master_priority[],  //TODO
                      input logic [HADDR_SIZE-1:0] slave_address_base[], slave_address_mask[]);
  extern function void random();
  //  extern virtual function void wrap_up();
  extern virtual function void display(string prefix = "");
endclass : peripheral_configuration

///////////////////////////////////////////////////////////////////////////////////////////////
//
// Class Methods
//

//Construct peripheral_configuration object
function peripheral_configuration::new(input int nmasters, nslaves, input logic [2:0] master_priority[], input logic [HADDR_SIZE-1:0] slave_address_base[], slave_address_mask[]);
  this.nMasters           = nmasters;
  this.nSlaves            = nslaves;
  this.master_priority    = master_priority;
  this.slave_address_base = slave_address_base;
  this.slave_address_mask = slave_address_mask;

  //create space for the number of transactions per master
  nTransactions           = new[nMasters];
endfunction : new

//Randomize configuration
function void peripheral_configuration::random();
  foreach (nTransactions[i]) nTransactions[i] = $urandom_range(MinTransactions, MaxTransactions);
endfunction : random

//Pretty print
function void peripheral_configuration::display(string prefix = "");
  $display("%sTest configuration:", prefix);

  $display("--- Transactions per master --------");
  foreach (nTransactions[i]) $display(" Port%0d: %5d", i, nTransactions[i]);

  $display("\n\n");
endfunction : display
