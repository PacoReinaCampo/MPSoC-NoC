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
import peripheral_ahb3_pkg::*;

class peripheral_monitor_ahb3 extends peripheral_base_monitor;
  virtual peripheral_interface.slave slave;  //Virtual IF, Slave Port
  peripheral_scoreboard              scoreboard;  //peripheral_scoreboard
  peripheral_bus_transaction_ahb3    transaction;  //current transfer

  function new(input int PortId, input peripheral_scoreboard scoreboard, input virtual peripheral_interface.slave slave);

    super.new(PortId);
    this.scoreboard = scoreboard;
    this.slave      = slave;
  endfunction : new

  extern virtual task run();
  extern task initialize();
  extern task wait4transfer();
  extern task wait4hready();
  extern task ahb3_hreadyout();
  extern task ahb3_setup(input peripheral_bus_transaction_ahb3 transaction);
  extern task ahb3_next(input peripheral_bus_transaction_ahb3 transaction);
  extern task ahb3_data(input peripheral_bus_transaction_ahb3 transaction);

  extern function byte_array_t getHADDR(ref byte_array_t arg);
  extern function int unsigned HSIZE2BytesPerTransfer(input logic [2:0] HSIZE);
  extern function int unsigned HBURST2TransferSize(input logic [2:0] HBURST);
endclass : peripheral_monitor_ahb3

////////////////////////////////////////////////////////////////////////////////
//
// Class Methods
//

//Reset Response
task peripheral_monitor_ahb3::initialize();
  slave.HREADYOUT <= 1'b1;
  slave.HRESP     <= HRESP_OKAY;

  //wait for reset to negate
  @(posedge slave.HRESETn);
endtask : initialize

//AHB3-Lite response
//Get transactions from AHB slave signals and respond
task peripheral_monitor_ahb3::run();

  forever begin
    if (!slave.HRESETn) initialize();

    //wait for a new transfer 
    wait4transfer();

    //generate new transaction (stores received signals and data)
    transaction = new(slave.HADDR_SIZE, slave.HDATA_SIZE);
    ahb3_setup(transaction);

    fork
      ahb3_next(transaction);
      ahb3_data(transaction);
    join_any
  end
endtask : run

//Check if slave is addressed
task peripheral_monitor_ahb3::wait4transfer();
  while (!slave.cb_slave.HREADY || !slave.cb_slave.HSEL || slave.cb_slave.HTRANS == HTRANS_IDLE) begin
    @(slave.cb_slave);
    slave.HREADYOUT <= 1'b1;
  end
endtask : wait4transfer

//Wait for HREADY to assert
task peripheral_monitor_ahb3::wait4hready();
  while (slave.cb_slave.HREADY !== 1'b1 || slave.cb_slave.HTRANS == HTRANS_BUSY) @(slave.cb_slave);
endtask : wait4hready

//Create new peripheral_bus_transactionansaction (receive side)
//
//When we get here, the previous transaction completed (HREADY='1')
task peripheral_monitor_ahb3::ahb3_setup(input peripheral_bus_transaction_ahb3 transaction);
  byte address[];

  //Get AHB Setup cycle signals
  address = new[(transaction.AddressSize + 7) / 8];
  getHADDR(address);
  transaction.AddressQueue.push_back(address);

  transaction.BytesPerTransfer = HSIZE2BytesPerTransfer(slave.cb_slave.HSIZE);
  transaction.TransferSize     = 1;  //set to 1. Actually count transfers per burst
  transaction.Write            = slave.cb_slave.HWRITE;
endtask : ahb3_setup

//Get next transfer
//
//When we get here, we only stored the data of the 1st cycle of the transaction
//and we're still in the 1st cycle
task peripheral_monitor_ahb3::ahb3_next(input peripheral_bus_transaction_ahb3 transaction);
  byte address[];

  //progress bus cycle (2nd cycle of burst)
  //HREADY='1' (from 'wait4transfer'), so proceed 1 cycle
  @(slave.cb_slave);

  //$display ("%0t %0d %0d %0d %0d", $time, PortId, slave.cb_slave.HSEL, slave.cb_slave.HTRANS, slave.cb_slave.HREADY);

  while (slave.cb_slave.HSEL == 1'b1 && (slave.cb_slave.HTRANS == HTRANS_SEQ || slave.cb_slave.HTRANS == HTRANS_BUSY || slave.cb_slave.HREADY !== 1'b1)) begin
    //$display ("%0t %0d %0d %0d", $time, PortId, slave.cb_slave.HREADY, slave.cb_slave.HTRANS);
    if (slave.cb_slave.HREADY && slave.cb_slave.HTRANS == HTRANS_SEQ) begin
      address = new[(transaction.AddressSize + 7) / 8];
      getHADDR(address);
      transaction.AddressQueue.push_back(address);

      //one more cycle in this burst. Increase TransferSize, force another datacycle
      transaction.TransferSize++;
    end

    @(slave.cb_slave);
  end
endtask : ahb3_next

//AHB Data task
//
//When we get here, we only stored the metadata of the 1st cycle of the transaction
//and we're still in the 1st cycle
//We're in control of HREADY (actually HREADYOUT)
task peripheral_monitor_ahb3::ahb3_data(input peripheral_bus_transaction_ahb3 transaction);
  byte data[], address[];
  byte data_queue[$];
  int unsigned data_offset, counter;

  //what's the start address?
  address     = transaction.AddressQueue[0];

  //what's the offset in the databus?
  data_offset = address[0] & 'hff;  //get address LSB in UNSIGNED format
  data_offset %= ((transaction.DataSize + 7) / 8);

  counter = 0;
  //$display ("%0t %0d transaction=%0d", $time, PortId, transaction.TransferSize);
  while (counter !== transaction.TransferSize) begin
    //increase transfer counter
    counter++;
    //$display ("%0t %0d transaction=%0d counter=%0d", $time, PortId, transaction.TransferSize, counter);

    //generate new 'data' object
    data = new[transaction.BytesPerTransfer];

    //send/receive actual data
    if (transaction.Write) begin
      //This is a write cycle

      //generate HREADYOUT (delay)
      ahb3_hreadyout();

      //proceed to next cycle of burst (this drives HREADYOUT high)
      @(slave.cb_slave);

      //and read data from HWDATA (while HREADYOUT is high)
      foreach (data[i]) data[i] = slave.cb_slave.HWDATA[(i+data_offset)*8+:8];
    end else begin
      //This is a read cycle

      //generate HREADYOUT (delay)
      ahb3_hreadyout();

      //Provide data on HRDATA
      foreach (data[i]) begin
        data[i] = $random;
        slave.cb_slave.HRDATA[(i+data_offset)*8+:8] <= data[i];
      end

      //and proceed to next cycle of burst
      //This drives HREADYOUT high and drives the data
      @(slave.cb_slave);
    end

    //push handle into the queue
    transaction.DataQueue.push_back(data);

    data_offset = (data_offset + transaction.BytesPerTransfer) % ((transaction.DataSize + 7) / 8);
  end

  //check transaction
  scoreboard.check_actual(transaction, PortId);

`ifdef DEBUG
  //Execute here to ensure last data cycle completes before display
  //and 'transaction' doesn't get mixed up with new transaction
  transaction.display($sformatf("@%0t Mon%0d: ", $time, PortId));
`endif
endtask : ahb3_data

//Generate HREADYOUT
//Generate useful HREADYOUT delays
task peripheral_monitor_ahb3::ahb3_hreadyout();
  //useful delays;
  // no delay    : 0
  // some delay  : 1, 2, 
  // burst delay : 4, 8, 16 (check for buffer overrun)

  int delay_opt, delay, counter;

  //generate HREADYOUT
  delay_opt = $urandom_range(0, 5);  //pick a number between 0 and 5

  case (delay_opt)
    0: delay = 0;
    1: delay = 1;
    2: delay = 2;
    3: delay = 4;
    4: delay = 8;
    5: delay = 16;
  endcase

  //drive HREADYOUT low for the duration of the delay
  for (int n = 1; n < delay; n++) begin
    slave.cb_slave.HREADYOUT <= 1'b0;
    @(slave.cb_slave);
  end

  //drive HREADYOUT high
  slave.cb_slave.HREADYOUT <= 1'b1;
endtask : ahb3_hreadyout

//Gets current HADDR
function byte_array_t peripheral_monitor_ahb3::getHADDR(ref byte_array_t arg);
  foreach (arg[i]) arg[i] = slave.cb_slave.HADDR[i*8+:8];

  return arg;
endfunction : getHADDR

//Convert HSIZE to Bytes-per-Transfer
function int unsigned peripheral_monitor_ahb3::HSIZE2BytesPerTransfer(input logic [2:0] HSIZE);
  case (HSIZE)
    HSIZE_BYTE:  return 1;
    HSIZE_HWORD: return 2;
    HSIZE_WORD:  return 4;
    HSIZE_DWORD: return 8;
    default:     $error("@%0t: Unsupported HSIZE(%3b)", $time, HSIZE);
  endcase
endfunction : HSIZE2BytesPerTransfer

//Convert HBURST to TransferSize
function int unsigned peripheral_monitor_ahb3::HBURST2TransferSize(input logic [2:0] HBURST);
  int unsigned TransferSize;

  case (HBURST)
    HBURST_SINGLE: return 1;
    HBURST_INCR4:  return 4;
    HBURST_INCR8:  return 8;
    HBURST_INCR16: return 16;
    HBURST_INCR:   return 0;
    default: begin
      $error("@%0t: Unsupported HBURST(%3b)", $time, HBURST);
      TransferSize = 0;
    end
  endcase
endfunction : HBURST2TransferSize

`ifdef DEBUG
`undef DEBUG
`endif
