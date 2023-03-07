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

// peripheral_bus_generator Class
// Generates bus transactions
class peripheral_bus_generator #(
    type T = peripheral_base_transaction
);
  T       blueprint;  //BluePrint for generator
  mailbox generation2driver;  //mailbox from generator to driver
  event   driver2generation;  //trigger from driver to generator
  int     MasterId;  //Which master port are we connected to
  bit     done;  //Are we done??

  function new(input mailbox generation2driver, input event driver2generation, input int unsigned MasterId, AddressSize, DataSize);
    this.done               = 0;
    this.generation2driver  = generation2driver;
    this.driver2generation  = driver2generation;
    this.MasterId           = MasterId;
    blueprint               = new(AddressSize, DataSize);

`ifdef DEBUG
    $display("peripheral_bus_generator::new id=%0d", MasterId);
`endif
  endfunction : new

  task run(input int unsigned nTransactions);
    T transaction;

    repeat (nTransactions) begin
      //randomize transfer
      blueprint.randomize_bus();

      //send copy of transfer to driver
      $cast(transaction, blueprint.copy());
      transaction.display($sformatf("@%0t Master%0d ", $time, MasterId));
      generation2driver.put(transaction);

      //wait for driver to finish the transfer
      @driver2generation;
    end

    //idle bus
    idle();
  endtask : run

  task idle();
    $display("@%0t: Master%0d going idle", $time, MasterId);

    //signal 'done'
    done = 1;

    //put bus in IDLE
    blueprint.idle();

    //send transaction to driver
    generation2driver.put(blueprint);

    //wait for driver to finish transfer
    @driver2generation;
  endtask : idle

endclass : peripheral_bus_generator

`ifdef DEBUG
`undef DEBUG
`endif
