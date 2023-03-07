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

program automatic peripheral_test
#(
  parameter int MASTERS    = 3,
  parameter int SLAVES     = 5,
  parameter int HADDR_SIZE = 32,
  parameter int HDATA_SIZE = 32
)
(
);

virtual peripheral_interface.master #(HADDR_SIZE,HDATA_SIZE) master[MASTERS];
virtual peripheral_interface.slave  #(HADDR_SIZE,HDATA_SIZE) slave [SLAVES ];

logic [$clog2(MASTERS+1)-1:0] master_priority [MASTERS];
logic [HADDR_SIZE       -1:0] address_base    [SLAVES ],
                              address_mask    [SLAVES ];

peripheral_environment enviroment;

initial begin
  foreach (master_priority[i]) master_priority[i] = $urandom_range(MASTERS-1,0);
  $root.peripheral_testbench.master_priority <= master_priority;

  master = $root.peripheral_testbench.ahb3_master;
  slave  = $root.peripheral_testbench.ahb3_slave;

  enviroment = new(master,slave,master_priority,address_base,address_mask);
  enviroment.generation_cfg();
  enviroment.build();
  enviroment.run();
  enviroment.wrap_up();
end

endprogram : peripheral_test
