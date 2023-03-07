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

`define DEBUG

import peripheral_package::*;

class peripheral_environment #(
    parameter HADDR_SIZE = 32
);
  peripheral_configuration #(HADDR_SIZE) configuration;  //Test configuration
  peripheral_bus_generator #(peripheral_bus_transaction_ahb3) generation[];  //Transaction generator
  peripheral_driver_ahb3 driver[];  //Bus driver
  peripheral_monitor_ahb3 monitor[];  //Bus monitor
  peripheral_scoreboard scoreboard;  //Score Board

  mailbox generation2driver[];
  event driver2generation[];

  int
      nmasters,  //number of masters
      nslaves;  //number of slaves
  virtual peripheral_interface.master masters[];  //master interfaces
  virtual peripheral_interface.slave slaves[];  //slave interfaces

  extern function new(input virtual peripheral_interface.master masters[],
                      input virtual peripheral_interface.slave slaves[],
                      input logic [2:0] master_priority[],  //TODO
                      input logic [HADDR_SIZE-1:0] slave_address_base[], slave_address_mask[]);
  extern virtual function void generation_cfg();
  extern virtual function void build();
  extern task run();
  extern virtual function void wrap_up();
endclass : peripheral_environment

////////////////////////////////////////////////////////////////////////////////
//
// Class Methods
//

// Construct peripheral_environment object
function peripheral_environment::new(input virtual peripheral_interface.master masters[],
                          input virtual peripheral_interface.slave slaves[],
                          input logic [2:0] master_priority[],
                          input logic [HADDR_SIZE-1:0] slave_address_base[], slave_address_mask[]);
  //create and hookup masters
  this.nmasters = masters.size();
  this.masters  = new[nmasters];
  foreach (masters[i]) this.masters[i] = masters[i];

  //create and hookup slaves
  this.nslaves = slaves.size();
  this.slaves  = new[nslaves];
  foreach (slaves[i]) this.slaves[i] = slaves[i];

  //create the configuration
  this.configuration = new(this.nmasters, this.nslaves, master_priority, slave_address_base, slave_address_mask);
endfunction : new

// Build the configuration
function void peripheral_environment::generation_cfg();
  configuration.random();
  configuration.display();
endfunction : generation_cfg

// Build the environment objects
function void peripheral_environment::build();
`ifdef DEBUG
  $display("peripheral_environment::Build #masters=%0d, #slaves=%0d", nmasters, nslaves);
`endif
  generation = new[nmasters];
  driver     = new[nmasters];
  monitor    = new[nslaves];

  generation2driver = new[nmasters];
  driver2generation = new[nmasters];

  scoreboard = new(configuration);

  //Build generators
  foreach (generation[i]) begin
    generation2driver[i] = new();
    generation[i] = new(generation2driver[i], driver2generation[i], i, masters[i].HADDR_SIZE, masters[i].HDATA_SIZE);
    driver[i] = new(generation2driver[i], driver2generation[i], i, scoreboard, masters[i]);
  end

  //Build monitors
  foreach (monitor[i]) monitor[i] = new(i, scoreboard, slaves[i]);
endfunction : build

// Start environment
task peripheral_environment::run();
  bit done;

`ifdef DEBUG
  $display("peripheral_environment::run");
`endif

  // For each master, start generator and driver
  foreach (generation[i]) begin
    int j = i;
    fork
      generation[j].run(configuration.nTransactions[j]);
      driver[j].run();
    join_none
  end

  //for each slave, start monitor
  foreach (monitor[i]) begin
    int j = i;
    fork
      monitor[j].run();
    join_none
  end

  //wait for drivers, monitors, and scoreboards to complete
  do begin
    done = 1;
    foreach (generation[i]) done &= generation[i].done;
    @(masters[0].cb_master);
  end while (!done);

  repeat (1000) @(masters[0].cb_master);
endtask : run

// Wrap-up, cleanup, reporting
function void peripheral_environment::wrap_up();
  $display("\n\n------------------------------------------------------------------------------------------------------");
  $display ("---------------------------------------------------------------------------------------------------------");
  $display ("                                                                                                         ");
  $display ("                                                                                                         ");
  $display ("                                                              ***                     ***          **    ");
  $display ("                                                            ** ***    *                ***          **   ");
  $display ("                                                           **   ***  ***                **          **   ");
  $display ("                                                           **         *                 **          **   ");
  $display ("    ****    **   ****                                      **                           **          **   ");
  $display ("   * ***  *  **    ***  *    ***       ***    ***  ****    ******   ***        ***      **      *** **   ");
  $display ("  *   ****   **     ****    * ***     * ***    **** **** * *****     ***      * ***     **     ********* ");
  $display (" **    **    **      **    *   ***   *   ***    **   ****  **         **     *   ***    **    **   ****  ");
  $display (" **    **    **      **   **    *** **    ***   **    **   **         **    **    ***   **    **    **   ");
  $display (" **    **    **      **   ********  ********    **    **   **         **    ********    **    **    **   ");
  $display (" **    **    **      **   *******   *******     **    **   **         **    *******     **    **    **   ");
  $display (" **    **    **      **   **        **          **    **   **         **    **          **    **    **   ");
  $display ("  *******     ******* **  ****    * ****    *   **    **   **         **    ****    *   **    **    **   ");
  $display ("   ******      *****   **  *******   *******    ***   ***  **         *** *  *******    *** *  *****     ");
  $display ("       **                   *****     *****      ***   ***  **         ***    *****      ***    ***      ");
  $display ("       **                                                                                                ");
  $display ("       **                                                                                                ");
  $display ("        **                                                                                               ");
  $display (" Simulation Ended                                                                                        ");
  $display ("---------------------------------------------------------------------------------------------------------");

  //Call scoreboard wrap-up function for actual reports
  scoreboard.wrap_up();

  $display("-------------------------------------------------------------\n\n");
endfunction : wrap_up

`ifdef DEBUG
`undef DEBUG
`endif
