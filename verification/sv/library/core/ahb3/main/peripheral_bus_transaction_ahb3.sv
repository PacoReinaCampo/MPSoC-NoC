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

//`define DEBUG

// AHB Bus Class
// Specialisation for AHB, from Bus-class

//typedef enum {byte='b000, hword='b001, word='b010, dword='b011} tHSIZE;
//typedef enum {single='b000, increase='b001, incr4='b011, incr8='b101, incr16='b111} tHBURST;

import peripheral_package::*;

class peripheral_bus_transaction_ahb3 extends peripheral_bus_transaction;
  extern function new(input int unsigned AddressSize, DataSize);
  extern virtual function peripheral_base_transaction copy(input peripheral_base_transaction to = null);
  extern virtual function void randomize_bus;
  extern function void idle;
  extern function byte_array_t NextAddress(byte_array_t address);

endclass : peripheral_bus_transaction_ahb3

////////////////////////////////////////////////////////////////////////////////
//
// Class Methods
//

//Constructor
function peripheral_bus_transaction_ahb3::new(input int unsigned AddressSize, DataSize);
  super.new(AddressSize, DataSize);

`ifdef DEBUG
  $display("peripheral_bus_transaction_ahb3::new");
`endif
endfunction : new

//Make a copy of this object
//Keep $cast happy
function peripheral_base_transaction peripheral_bus_transaction_ahb3::copy(input peripheral_base_transaction to = null);
  peripheral_bus_transaction_ahb3 cp;
  cp = new(AddressSize, DataSize);

  return super.copy(cp);
endfunction : copy

//Randomize class variables
function void peripheral_bus_transaction_ahb3::randomize_bus();
  byte address[], data[];
  int unsigned address_check;

  //write or read?
  //Translates directly to HWRITE
  Write            = $urandom_range(1);

  //Bytes-per-Transfer
  //Translates directly to HSIZE
  BytesPerTransfer = 1 << $urandom_range($clog2((DataSize + 7) / 8));

  //number of bytes to transfers
  //Translates to HBURST (and HTRANS)
  TransferSize     = $urandom_range(5);  //This encodes HBURST
  case (TransferSize)
    0: TransferSize = 0;  //IDLE
    1: TransferSize = 1;  //Single
    2: TransferSize = $urandom_range(31);  //INCR burst
    3: TransferSize = 4;  //INCR4
    4: TransferSize = 8;  //INCR8
    5: TransferSize = 16;  //INCR16
  endcase

  //Start Address
  //Translates to HADDR
  //TODO: AHB specifications say Address-burst must not cross 1KB boundary
  AddressQueue.delete();

  //chose a start address
  address = new[(AddressSize + 7) / 8];
  foreach (address[i]) address[i] = $urandom();

  //Ensure burst doesn't cross 1K boundary (as specified by AMBA specs)
  if (AddressSize > 10) begin
    //get Address[9:0]
    address_check[7 : 0]  = address[0];
    address_check[15 : 8] = address[1];
    //$display("Check address boundary %02x%02x %4x", address[1],address[0], address_check);
    //$display("%x, %0d, %0d -> %0x", address_check[9:0], TransferSize, BytesPerTransfer, address_check[9:0] + (TransferSize * BytesPerTransfer) );

    //Now check if the total address crosses the 1K boundary
    if (address_check[9:0] + (TransferSize * BytesPerTransfer) > 2 ** 10) begin
      //$display("Address crosses 1k boundary: %x", address);
      //start at 1K boundary
      address[0] = 0;
      address[1] &= 'hc0;
      address[1] += 'h40;
    end
  end

  //clear LSBs based on BytesPerTransfer
  address[0] = address[0] & (8'hFF << $clog2(BytesPerTransfer));
  AddressQueue.push_back(address);

  for (int i = 0; i < TransferSize - 1; i++) begin
    address = NextAddress(address);
    AddressQueue.push_back(address);
  end

  //Create write-data
  //Translates to HWDATA
  DataQueue.delete();
  if (Write)
    for (int i = 0; i < TransferSize; i++) begin
      data = new[BytesPerTransfer];
      foreach (data[i]) data[i] = $urandom;
      DataQueue.push_back(data);
    end
endfunction : randomize_bus

//Calculate next AHB bus for transfer
function byte_array_t peripheral_bus_transaction_ahb3::NextAddress(byte_array_t address);
  bit [15:0] counter;
  int unsigned increase;

  increase = BytesPerTransfer;

  //create new Address array
  NextAddress = new[address.size()];

  foreach (address[i]) begin
    counter        = address[i] + increase;
    NextAddress[i] = counter[7:0];
    increase       = counter[15:8];
  end
endfunction : NextAddress

//IDLE bus
function void peripheral_bus_transaction_ahb3::idle();
  Write            = 'bx;  //don't care, but ensure no HWDATA is generated
  BytesPerTransfer = 'hx;  //don't care
  TransferSize     = 0;  //don't care, but set HTRANS=IDLE

  AddressQueue.delete();
  DataQueue.delete();
endfunction : idle

`ifdef DEBUG
`undef DEBUG
`endif
