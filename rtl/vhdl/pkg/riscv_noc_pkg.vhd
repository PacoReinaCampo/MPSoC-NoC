-- Converted from rtl/verilog/arbiter/riscv_arb_rr.sv
-- by verilog2vhdl - QueenField

--//////////////////////////////////////////////////////////////////////////////
--                                            __ _      _     _               //
--                                           / _(_)    | |   | |              //
--                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
--               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
--              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
--               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
--                  | |                                                       //
--                  |_|                                                       //
--                                                                            //
--                                                                            //
--              MPSoC-RISCV CPU                                               //
--              Network on Chip Package                                       //
--              Mesh Topology                                                 //
--                                                                            //
--//////////////////////////////////////////////////////////////////////////////

-- Copyright (c) 2019-2020 by the author(s)
-- *
-- * Permission is hereby granted, free of charge, to any person obtaining a copy
-- * of this software and associated documentation files (the "Software"), to deal
-- * in the Software without restriction, including without limitation the rights
-- * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- * copies of the Software, and to permit persons to whom the Software is
-- * furnished to do so, subject to the following conditions:
-- *
-- * The above copyright notice and this permission notice shall be included in
-- * all copies or substantial portions of the Software.
-- *
-- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- * THE SOFTWARE.
-- *
-- * =============================================================================
-- * Author(s):
-- *   Francisco Javier Reina Campo <frareicam@gmail.com>
-- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package riscv_noc_pkg is

  constant BUFFER_SIZE_IN  : integer := 4;
  constant BUFFER_SIZE_OUT : integer := 4;

  constant FULLPACKET : integer := 0;

  -- Those are indexes into the wiring arrays
  constant LOCAL : integer := 0;
  constant UP    : integer := 1;
  constant NORTH : integer := 2;
  constant EAST  : integer := 3;
  constant DOWN  : integer := 4;
  constant SOUTH : integer := 5;
  constant WEST  : integer := 6;

  -- Those are direction codings that match the wiring indices
  -- above. The router is configured to use those to select the
  -- proper output port.
  constant DIR_LOCAL : std_ulogic_vector(6 downto 0) := "0000001";
  constant DIR_UP    : std_ulogic_vector(6 downto 0) := "0000010";
  constant DIR_NORTH : std_ulogic_vector(6 downto 0) := "0000100";
  constant DIR_EAST  : std_ulogic_vector(6 downto 0) := "0001000";
  constant DIR_DOWN  : std_ulogic_vector(6 downto 0) := "0010000";
  constant DIR_SOUTH : std_ulogic_vector(6 downto 0) := "0100000";
  constant DIR_WEST  : std_ulogic_vector(6 downto 0) := "1000000";

  -- Maximum packet length
  constant NOC_MAX_LEN : integer := 32;

  -- NoC packet header
  -- Mandatory fields
  constant NOC_DEST_MSB  : integer := 31;
  constant NOC_DEST_LSB  : integer := 27;
  constant NOC_CLASS_MSB : integer := 26;
  constant NOC_CLASS_LSB : integer := 24;
  constant NOC_SRC_MSB   : integer := 23;
  constant NOC_SRC_LSB   : integer := 19;

  -- Classes
  constant NOC_CLASS_LSU : std_ulogic_vector(2 downto 0) := "010";

  -- NoC LSU
  constant NOC_LSU_MSGTYPE_READREQ : std_ulogic_vector(2 downto 0) := "000";

  constant NOC_LSU_MSGTYPE_MSB : integer := 18;
  constant NOC_LSU_MSGTYPE_LSB : integer := 16;
  constant NOC_LSU_SIZE_IDX    : integer := 15;
  constant NOC_LSU_SIZE_BURST  : integer := 1;
  constant NOC_LSU_SIZE_SINGLE : integer := 0;

end riscv_noc_pkg;
