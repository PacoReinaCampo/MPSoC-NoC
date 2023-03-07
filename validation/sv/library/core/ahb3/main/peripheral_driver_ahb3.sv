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
import peripheral_ahb3_pkg::*;

class peripheral_driver_ahb3 extends peripheral_base_driver;
  virtual peripheral_interface.master master;  //Virtual interface; master
  peripheral_scoreboard scoreboard;  //peripheral_scoreboard

  function new(input mailbox generation2driver, input event driver2generation, input int PortId, input peripheral_scoreboard scoreboard, input virtual peripheral_interface.master master);

    super.new(generation2driver, driver2generation, PortId);
    this.scoreboard = scoreboard;
    this.master     = master;
  endfunction : new

  extern virtual task run();
  extern task initialize();
  extern task wait4hready(input exit_on_hresp_error);
  extern task ahb3_cmd(input peripheral_bus_transaction_ahb3 transaction);
  extern task ahb3_data(input peripheral_bus_transaction_ahb3 transaction);

  extern function bit [2:0] BytesPerTransfer2HSIZE(input int unsigned BytesPerTransfer);
  extern function bit [2:0] TransferSize2HBURST(input int unsigned TransferSize);
endclass : peripheral_driver_ahb3

////////////////////////////////////////////////////////////////////////////////
//
// Class Methods
//

//Put AHB3-Lite bus in initial state
task peripheral_driver_ahb3::initialize();
  master.HTRANS <= HTRANS_IDLE;

  //wait for reset to negate
  @(posedge master.HRESETn);
endtask : initialize

//Wait for HREADY to assert
task peripheral_driver_ahb3::wait4hready(input exit_on_hresp_error);
  if (exit_on_hresp_error)
    do
      @(master.cb_master);
    while (master.cb_master.HREADY !== 1'b1 && master.cb_master.HRESP !== HRESP_ERROR);
  else do @(master.cb_master); while (master.cb_master.HREADY !== 1'b1);
endtask : wait4hready

//Drive AHB3-Lite bus
//Get transactions from mailbox and translate them into AHB3Lite signals
task peripheral_driver_ahb3::run();
  peripheral_bus_transaction_ahb3 transaction;

  forever begin
    if (!master.HRESETn) initialize();

    //read new transaction
    generation2driver.get(transaction);

    //generate transfers
    /*!! transaction.TransferSize==0 means an IDLE transfer; no data !!*/
    fork
      ahb3_cmd(transaction);
      ahb3_data(transaction);
    join_any

    //signal transfer-complete to driver
    ->driver2generation;
  end
endtask : run

//AHB command signals
task peripheral_driver_ahb3::ahb3_cmd(input peripheral_bus_transaction_ahb3 transaction);
  byte address[];
  int  counter;

  wait4hready(1);
  //Check HRESP
  if (master.cb_master.HRESP == HRESP_ERROR && master.cb_master.HREADY != 1'b1) begin
    //We are in the 1st error cycle. Next cycle must be IDLE
    master.cb_master.HTRANS <= HTRANS_IDLE;
    //wait for HREADY
    wait4hready(0);
  end

  //first cycle of a (potential) burst
  master.cb_master.HSEL      <= 1'b1;
  master.cb_master.HTRANS    <= transaction.TransferSize > 0 ? HTRANS_NONSEQ : HTRANS_IDLE;
  master.cb_master.HWRITE    <= transaction.Write;
  master.cb_master.HBURST    <= TransferSize2HBURST(transaction.TransferSize);
  master.cb_master.HSIZE     <= BytesPerTransfer2HSIZE(transaction.BytesPerTransfer);
  master.cb_master.HMASTLOCK <= 1'b0;  //TODO: peripheral_test

  if (transaction.TransferSize > 0) begin
    address = transaction.AddressQueue[0];
    foreach (address[i]) master.cb_master.HADDR[i*8+:8] <= address[i];

    //Next cycles (optional)
    counter = 1;
    repeat (transaction.TransferSize - 1) begin
      //wait for HREADY
      wait4hready(1);

      //Check HRESP
      if (master.cb_master.HRESP == HRESP_ERROR) begin
        //error response. Next cycle must be IDLE. Exit current transaction
        master.cb_master.HTRANS <= HTRANS_IDLE;
        return;
      end

      master.cb_master.HTRANS <= HTRANS_SEQ;

      address = transaction.AddressQueue[counter++];
      foreach (address[i]) master.cb_master.HADDR[i*8+:8] <= address[i];
    end
  end else master.cb_master.HADDR <= 'hx;

endtask : ahb3_cmd

//Transfer AHB data
task peripheral_driver_ahb3::ahb3_data(input peripheral_bus_transaction_ahb3 transaction);
  byte address[], data[];
  int unsigned data_offset, counter;

  wait4hready(1);
  if (master.cb_master.HRESP == HRESP_ERROR && master.cb_master.HREADY != 1'b1) begin
    //We are in the 1st error cycle. Wait for error transaction to complete
    wait4hready(0);
  end

  if (transaction.TransferSize > 0) begin
    //First data from queue (for write cycle)
    counter         = 0;

    //where to start?
    address     = transaction.AddressQueue[0];  //Get first address of burst
    data_offset = address[0] & 'hff;  //Get start address's LSB in UNSIGNED format
    data_offset %= ((transaction.DataSize + 7) / 8);

    if (!transaction.Write) begin
      //Extra cycle for reading (read at the end of the cycle)
      wait4hready(0);

      //Check HRESP
      if (master.cb_master.HRESP == HRESP_ERROR) transaction.Error = 1;

      //set HWDATA='xxxx'
      master.cb_master.HWDATA <= 'hx;
    end

    //transfer bytes
    repeat (transaction.TransferSize) begin
      //wait for HREADY
      wait4hready(0);

      //Check HRESP
      if (master.cb_master.HRESP == HRESP_ERROR) begin
        transaction.Error = 1;
        break;
      end

      if (transaction.Write) begin
        //write data
        data = transaction.DataQueue[counter++];

        foreach (data[i]) master.cb_master.HWDATA[(i+data_offset)*8+:8] <= data[i];

        //check error response of last transfer
        if (counter == transaction.TransferSize) begin
          @(master.cb_master);

          if (master.cb_master.HRESP == HRESP_ERROR) begin
            transaction.Error = 1;
            break;
          end
        end
      end else begin
        //This is a read cycle. Read data from HRDATA
        data = new[transaction.BytesPerTransfer];

        foreach (data[i]) data[i] = master.cb_master.HRDATA[(i+data_offset)*8+:8];

        transaction.DataQueue.push_back(data);
      end

      data_offset = (data_offset + transaction.BytesPerTransfer) % ((transaction.DataSize + 7) / 8);
    end
  end

  //Done transmit; send transaction to scoreboard
  scoreboard.save_expected(transaction);

  //  transaction.display($sformatf("@%0t: Drv%0d: ", $time, PortId));
endtask : ahb3_data

//calculate HSIZE
function bit [2:0] peripheral_driver_ahb3::BytesPerTransfer2HSIZE(input int unsigned BytesPerTransfer);
  case (BytesPerTransfer)
    0: return 0;
    1: return HSIZE_BYTE;
    2: return HSIZE_HWORD;
    4: return HSIZE_WORD;
    8: return HSIZE_DWORD;
    default: $error("Unsupported number of bytes per transfer %0d", BytesPerTransfer);
  endcase
endfunction : BytesPerTransfer2HSIZE

//Generate HBURST
function bit [2:0] peripheral_driver_ahb3::TransferSize2HBURST(input int unsigned TransferSize);
  case (TransferSize)
    1:       return HBURST_SINGLE;
    4:       return HBURST_INCR4;
    8:       return HBURST_INCR8;
    16:      return HBURST_INCR16;
    default: return HBURST_INCR;
  endcase
endfunction : TransferSize2HBURST
