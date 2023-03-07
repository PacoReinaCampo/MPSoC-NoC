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

import peripheral_package::*;

// Bus Class
// Generates/Holds parameters for 1 transaction
class peripheral_bus_transaction extends peripheral_base_transaction;
  int
      AddressSize,  //# of address BITS
      DataSize;  //# of data BITS
  bit Write;  //read/write
  int TransferSize;  //# of transfers/transfer-cycles
  int BytesPerTransfer;  //Bytes per transfer
  byte_array_t AddressQueue[$];  //Addresses
  byte_array_t DataQueue[$];  //Data
  bit Error;  //Error during transaction

  extern function new(input int unsigned AddressSize, DataSize);
  extern virtual function bit compare(input peripheral_base_transaction to);
  extern virtual function peripheral_base_transaction copy(input peripheral_base_transaction to = null);
  extern virtual function void display(input string prefix = "");
  extern virtual function void randomize_bus;
endclass : peripheral_bus_transaction

////////////////////////////////////////////////////////////////////////////////
//
// Class Methods
//

//Constructor
function peripheral_bus_transaction::new(input int unsigned AddressSize, DataSize);
  //call higher level
  super.new();

  //set data/addressbus sizes
  this.AddressSize = AddressSize;
  this.DataSize    = DataSize;
  this.Error       = 0;
endfunction : new

//compare two Bus objects
function bit peripheral_bus_transaction::compare(input peripheral_base_transaction to);
  peripheral_bus_transaction b;
  bit cmp_flags, cmp_address, cmp_data;

`ifdef DEBUG
  $display("peripheral_bus_transaction::compare");
`endif

  $cast(b, to);

  //compare basic variables
  cmp_flags = (this.AddressSize      == b.AddressSize     ) &
              (this.DataSize         == b.DataSize        ) &
              (this.Write            == b.Write           ) &
              (this.TransferSize     == b.TransferSize    ) &
              (this.BytesPerTransfer == b.BytesPerTransfer) &
              (this.Error            == b.Error           );

  //compare addresses
  cmp_address = this.AddressQueue.size() == b.AddressQueue.size();
  if (cmp_address)
    foreach (this.AddressQueue[i]) begin
      byte address_a[], address_b[];

      address_a = this.AddressQueue[i];
      address_b = b.AddressQueue[i];

      cmp_address &= (address_a.size() == address_b.size());

      if (cmp_address) foreach (address_a[j]) cmp_address &= (address_a[j] == address_b[j]);
    end

  //compare data
  cmp_data = this.DataQueue.size() == b.DataQueue.size();
  if (cmp_data)
    foreach (this.DataQueue[i]) begin
      byte data_a[], data_b[];

      data_a = this.DataQueue[i];
      data_b = b.DataQueue[i];

      cmp_data &= (data_a.size() == data_b.size());

      if (cmp_data) foreach (data_a[j]) cmp_data &= (data_a[j] == data_b[j]);
    end

  //return result
  return cmp_flags & cmp_address & cmp_data;
endfunction : compare

//Make a copy of this object
function peripheral_base_transaction peripheral_bus_transaction::copy(input peripheral_base_transaction to = null);
  peripheral_bus_transaction cp;
  byte address[], cp_address[], data[], cp_data[];

`ifdef DEBUG
  $display("peripheral_bus_transaction::copy");
`endif

  if (to == null) cp = new(AddressSize, DataSize);
  else $cast(cp, to);

  cp.AddressSize      = this.AddressSize;
  cp.DataSize         = this.DataSize;
  cp.Write            = this.Write;
  cp.TransferSize     = this.TransferSize;
  cp.BytesPerTransfer = this.BytesPerTransfer;
  cp.Error            = this.Error;

  foreach (this.AddressQueue[i]) begin
    address    = AddressQueue[i];
    cp_address = {address};  //copy address elements
    cp.AddressQueue.push_back(cp_address);
  end

  foreach (this.DataQueue[i]) begin
    data    = DataQueue[i];
    cp_data = {data};  //copy data elements
    cp.DataQueue.push_back(cp_data);
  end

  return cp;
endfunction : copy

//Pretty print
function void peripheral_bus_transaction::display(input string prefix = "");
  int i;
  byte address[], data[];

  $display(
      "%sTr-id:%0d, AddressSize=%0d DataSize=%0d %0s TransferSize=%0d BytesPerTransfer=%0d Error=%0d",
      prefix, id, AddressSize, DataSize, Write ? "Write" : "Read", TransferSize, BytesPerTransfer,
      Error);

  $write(" Address=");
  foreach (AddressQueue[j]) begin
    address = AddressQueue[j];
    for (i = address.size() - 1; i >= 0; i--) $write("%x", address[i]);

    $write(",");
  end
  $display();

  $write(" Data=");
  foreach (DataQueue[j]) begin
    data = DataQueue[j];
    for (i = data.size() - 1; i >= 0; i--) $write("%x", data[i]);

    $write(",");
  end
  $display("");
endfunction : display

//Randomize class variables
function void peripheral_bus_transaction::randomize_bus();
  byte address[], data[];

  Write            = $random();
  TransferSize     = $urandom(8);  //some sane number. Keep Data array in bounds
  BytesPerTransfer = $urandom((DataSize + 7) / 8);

  AddressQueue.delete();  //address object should be deleted by SV automatically
  DataQueue.delete();  //data objects should be deleted by SV automatically

  for (int j = 0; j < TransferSize; j++) begin
    address = new[(AddressSize + 7) / 8];
    foreach (address[i]) address[i] = $random();
    AddressQueue.push_back(address);

    if (Write) begin
      data = new[BytesPerTransfer];
      foreach (data[i]) data[i] = $random;
      DataQueue.push_back(data);
    end
  end
endfunction : randomize_bus

`ifdef DEBUG
`undef DEBUG
`endif
