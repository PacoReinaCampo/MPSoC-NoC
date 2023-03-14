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

module peripheral_testbench;
  parameter MASTERS = 3;  //Number of master ports
  parameter SLAVES = 4;  //Number of slave ports

  parameter HADDR_SIZE = 16;
  parameter HDATA_SIZE = 32;

  //////////////////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  genvar m, s;

  logic [$clog2(MASTERS+1)-1:0] master_priority   [MASTERS];
  logic [HADDR_SIZE       -1:0] slave_address_mask[ SLAVES];
  logic [HADDR_SIZE       -1:0] slave_address_base[ SLAVES];

  logic master_HSEL[MASTERS], slave_HSEL[SLAVES];
  logic [HADDR_SIZE       -1:0] master_HADDR[MASTERS], slave_HADDR[SLAVES];
  logic [HDATA_SIZE       -1:0] master_HWDATA[MASTERS], slave_HWDATA[SLAVES];
  logic [HDATA_SIZE       -1:0] master_HRDATA[MASTERS], slave_HRDATA[SLAVES];
  logic master_HWRITE[MASTERS], slave_HWRITE[SLAVES];
  logic [2:0] master_HSIZE[MASTERS], slave_HSIZE[SLAVES];
  logic [2:0] master_HBURST[MASTERS], slave_HBURST[SLAVES];
  logic [3:0] master_HPROT[MASTERS], slave_HPROT[SLAVES];
  logic [1:0] master_HTRANS[MASTERS], slave_HTRANS[SLAVES];
  logic master_HMASTLOCK[MASTERS], slave_HMASTLOCK[SLAVES];
  logic master_HREADY[MASTERS], slave_HREADY[SLAVES];
  logic master_HREADYOUT[MASTERS], slave_HREADYOUT[SLAVES];
  logic master_HRESP[MASTERS], slave_HRESP[SLAVES];

  //////////////////////////////////////////////////////////////////////////////
  //
  // Clock & Reset
  //
  bit HCLK, HRESETn;
  initial begin : generation_HCLK
    HCLK <= 1'b0;
    forever #10 HCLK = ~HCLK;
  end : generation_HCLK

  initial begin : generation_HRESETn
    ;
    HRESETn <= 1'b0;
    #32;
    HRESETn <= 1'b1;
  end : generation_HRESETn
  ;

  //////////////////////////////////////////////////////////////////////////////
  //
  // Master & Slave Model ports
  //
  peripheral_interface #(HADDR_SIZE, HDATA_SIZE) ahb3_master[MASTERS] (
    HCLK,
    HRESETn
  );
  peripheral_interface #(HADDR_SIZE, HDATA_SIZE) ahb3_slave[SLAVES] (
    HCLK,
    HRESETn
  );

  //////////////////////////////////////////////////////////////////////////////
  //
  // Master->Slave mapping
  //
  //TODO: Move into tb()
  assign slave_address_base[0] = 'h0000;
  assign slave_address_base[1] = 'h2000;
  assign slave_address_base[2] = 'h3000;
  assign slave_address_base[3] = 'h4000;
  assign slave_address_base[4] = 'h8000;

  assign slave_address_mask[0] = 'he000;
  assign slave_address_mask[1] = 'hf000;
  assign slave_address_mask[2] = 'hf000;
  assign slave_address_mask[3] = 'hc000;
  assign slave_address_mask[4] = 'h8000;

  //////////////////////////////////////////////////////////////////////////////
  //
  // Map SystemVerilog Interface to ports
  //
  generate
    for (m = 0; m < MASTERS; m++) begin
      assign master_HSEL[m]        = ahb3_master[m].HSEL;
      assign master_HADDR[m]       = ahb3_master[m].HADDR;
      assign master_HWDATA[m]      = ahb3_master[m].HWDATA;
      assign master_HWRITE[m]      = ahb3_master[m].HWRITE;
      assign master_HSIZE[m]       = ahb3_master[m].HSIZE;
      assign master_HBURST[m]      = ahb3_master[m].HBURST;
      assign master_HPROT[m]       = ahb3_master[m].HPROT;
      assign master_HTRANS[m]      = ahb3_master[m].HTRANS;
      assign master_HMASTLOCK[m]   = ahb3_master[m].HMASTLOCK;

      //HREADY-OUT -> HREADY logic (only 1 master/slave connection)
      assign master_HREADY[m]      = master_HREADYOUT[m];

      assign ahb3_master[m].HRDATA = master_HRDATA[m];
      assign ahb3_master[m].HREADY = master_HREADY[m];
      assign ahb3_master[m].HRESP  = master_HRESP[m];
    end

    for (s = 0; s < SLAVES; s++) begin
      assign ahb3_slave[s].HSEL      = slave_HSEL[s];
      assign ahb3_slave[s].HADDR     = slave_HADDR[s];
      assign ahb3_slave[s].HWDATA    = slave_HWDATA[s];
      assign ahb3_slave[s].HWRITE    = slave_HWRITE[s];
      assign ahb3_slave[s].HSIZE     = slave_HSIZE[s];
      assign ahb3_slave[s].HBURST    = slave_HBURST[s];
      assign ahb3_slave[s].HPROT     = slave_HPROT[s];
      assign ahb3_slave[s].HTRANS    = slave_HTRANS[s];
      assign ahb3_slave[s].HMASTLOCK = slave_HMASTLOCK[s];
      assign ahb3_slave[s].HREADY    = slave_HREADYOUT[s];  //no decoder on slave bus. Interconnect's HREADYOUT drives single slave's HREADY input

      assign slave_HRDATA[s]         = ahb3_slave[s].HRDATA;
      assign slave_HREADY[s]         = ahb3_slave[s].HREADYOUT;  //no decoder on slave bus. Interconnect's HREADY is driven by single slave's HREADYOUT
      assign slave_HRESP[s]          = ahb3_slave[s].HRESP;
    end
  endgenerate

  //////////////////////////////////////////////////////////////////////////////
  //
  // Instantiate the TB and DUT
  //
  peripheral_test #(
    .MASTERS   (MASTERS),
    .SLAVES    (SLAVES),
    .HADDR_SIZE(HADDR_SIZE),
    .HDATA_SIZE(HDATA_SIZE)
  ) tb ();

  peripheral_msi_ahb3 #(
    .MASTERS          (MASTERS),
    .SLAVES           (SLAVES),
    .HADDR_SIZE       (HADDR_SIZE),
    .HDATA_SIZE       (HDATA_SIZE),
    .SLAVE_MASK       ('{MASTERS{4'b1011}}),
    .ERROR_ON_NO_SLAVE('{MASTERS{1'b1}})
  ) dut (
    .*
  );

endmodule : peripheral_testbench
