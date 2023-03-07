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

interface peripheral_interface #(
  parameter HADDR_SIZE = 32,
  parameter HDATA_SIZE = 32
)
  (
    input logic HCLK:
    input logic HRESETn
  );

  //declare interface signals
  logic                   HSEL;
  logic [HADDR_SIZE -1:0] HADDR;
  logic [HDATA_SIZE -1:0] HWDATA;
  logic [HDATA_SIZE -1:0] HRDATA;
  logic                   HWRITE;
  logic [            2:0] HSIZE;
  logic [            2:0] HBURST;
  logic [            3:0] HPROT;
  logic [            1:0] HTRANS;
  logic                   HMASTLOCK;
  logic                   HREADY;
  logic                   HREADYOUT;
  logic                   HRESP;

  // Master Interface Definitions
  clocking cb_master @(posedge HCLK);
    output HSEL;
    output HADDR;
    output HWDATA;
    input HRDATA;
    output HWRITE;
    output HSIZE;
    output HBURST;
    output HPROT;
    output HTRANS;
    output HMASTLOCK;
    input HREADY;
    input HRESP;
  endclocking

  modport master(
    //synchronous signals
    clocking cb_master,
      //asynchronous reset signals
      input HRESETn,
      output HSEL,
      output HTRANS
  );

  // Slave Interface Definitions
  clocking cb_slave @(posedge HCLK);
    input HSEL;
    input HADDR;
    input HWDATA;
    output HRDATA;
    input HWRITE;
    input HSIZE;
    input HBURST;
    input HPROT;
    input HTRANS;
    input HMASTLOCK;
    input HREADY;
    output HREADYOUT;
    output HRESP;
  endclocking

  modport slave(
    //synchronous signals
    clocking cb_slave,
      //asynchronous reset signals
      input HRESETn,
      output HREADYOUT,
      output HRESP
  );
endinterface : peripheral_interface

typedef virtual peripheral_interface v_ahb3lite;
typedef virtual peripheral_interface.master v_ahb3lite_master;
typedef virtual peripheral_interface.slave v_ahb3lite_slave;
