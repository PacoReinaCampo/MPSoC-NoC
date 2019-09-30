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
//              MPSoC-RISCV CPU                                               //
//              Network on Chip Package                                       //
//              Mesh Topology                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2019-2020 by the author(s)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * =============================================================================
 * Author(s):
 *   Francisco Javier Reina Campo <frareicam@gmail.com>
 */

  `define BUFFER_SIZE_IN  4
  `define BUFFER_SIZE_OUT 4

  `define INPUTS  7
  `define OUTPUTS 7

  // Those are indexes into the wiring arrays
  `define LOCAL 0
  `define UP    1
  `define NORTH 2
  `define EAST  3
  `define DOWN  4
  `define SOUTH 5
  `define WEST  6

  // Those are direction codings that match the wiring indices
  // above. The router is configured to use those to select the
  // proper output port.
  `define DIR_LOCAL 7'b0000001
  `define DIR_UP    7'b0000010
  `define DIR_NORTH 7'b0000100
  `define DIR_EAST  7'b0001000
  `define DIR_DOWN  7'b0010000
  `define DIR_SOUTH 7'b0100000
  `define DIR_WEST  7'b1000000

  // Maximum packet length
  `define NOC_MAX_LEN 32

  // NoC packet header
  // Mandatory fields
  `define NOC_DEST_MSB  31
  `define NOC_DEST_LSB  27
  `define NOC_CLASS_MSB 26
  `define NOC_CLASS_LSB 24
  `define NOC_SRC_MSB   23
  `define NOC_SRC_LSB   19

  // Classes
  `define NOC_CLASS_LSU 3'h2

  // NoC LSU
  `define NOC_LSU_MSGTYPE_MSB     18
  `define NOC_LSU_MSGTYPE_LSB     16
  `define NOC_LSU_MSGTYPE_READREQ 3'h0
  `define NOC_LSU_SIZE_IDX        15
  `define NOC_LSU_SIZE_SINGLE     0
  `define NOC_LSU_SIZE_BURST      1
