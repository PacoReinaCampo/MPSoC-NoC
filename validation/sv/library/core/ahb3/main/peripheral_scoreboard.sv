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

class peripheral_scoreboard #(
    type T = peripheral_bus_transaction_ahb3
) extends peripheral_base_scoreboard;
  T TrQueue[$], MismatchTrQueue[$];

  int matched_transaction, mismatched_transaction, idle_transaction, error_transaction;

  extern function new(peripheral_base_configuration configuration);
  extern virtual function void wrap_up();
  extern function void save_expected(T transaction);
  extern function void check_actual(T transaction, int PortId);
  extern function void display(string prefix = "");
endclass : peripheral_scoreboard

////////////////////////////////////////////////////////////////////////////////
//
// Class Methods
//

//Construct peripheral_scoreboard object
function peripheral_scoreboard::new(peripheral_base_configuration configuration);
  super.new(configuration);

  matched_transaction = 0;
  mismatched_transaction = 0;
  error_transaction = 0;
endfunction : new

//Wrap up ...
//Check if any transactions are remaining
function void peripheral_scoreboard::wrap_up();
  int total_transactions;
  peripheral_configuration my_cfg;

  $cast(my_cfg, configuration);

  total_transactions = 0;
  foreach (my_cfg.nTransactions[i]) total_transactions += my_cfg.nTransactions[i];

  $display("-- Scoreboard Summary -----");
  $display("  Total transactions: %0d", total_transactions);
  $display("  Matched transaction: %0d", matched_transaction);
  $display("  Mis-matched transactions: %0d", mismatched_transaction);
  $display("  Idle transactions: %0d", idle_transaction);
  $display("  Error transactions: %0d", error_transaction);
  $display("  Queue still contains %0d transactions", TrQueue.size());

  if (TrQueue.size()) begin
    $display("\n -- Remaining transactions -----");
    foreach (TrQueue[i]) TrQueue[i].display();
  end

  if (MismatchTrQueue.size()) begin
    $display("\n -- Mismatched transactions -----");
    foreach (MismatchTrQueue[i]) MismatchTrQueue[i].display();
  end
endfunction : wrap_up

//Push transaction into transaction queue
function void peripheral_scoreboard::save_expected(T transaction);
  transaction.display($sformatf("@%0t Scb-save ", $time));

  if (transaction.Error) error_transaction++;
  else if (transaction.TransferSize == 0) idle_transaction++;
  else TrQueue.push_back(transaction);  //not an Idle transfer; push into transfer-queue
endfunction : save_expected

//Find transaction in transaction queue
//and compare/check
function void peripheral_scoreboard::check_actual(T transaction, int PortId);
  transaction.display($sformatf("@%0t Scb-check ", $time));

  foreach (TrQueue[i])
    if (TrQueue[i].compare(transaction)) begin
      $display("@%0t: Match found", $time);
      matched_transaction++;
      TrQueue.delete(i);
      return;
    end

  $display("@%0t: Match failed", $time);
  mismatched_transaction++;
  MismatchTrQueue.push_back(transaction);
endfunction : check_actual

//Pretty print
function void peripheral_scoreboard::display(string prefix = "");
endfunction : display
