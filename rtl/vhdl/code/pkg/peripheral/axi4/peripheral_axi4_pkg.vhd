--------------------------------------------------------------------------------
--                                            __ _      _     _               --
--                                           / _(_)    | |   | |              --
--                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              --
--               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              --
--              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              --
--               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              --
--                  | |                                                       --
--                  |_|                                                       --
--                                                                            --
--                                                                            --
--              MPSoC-RISCV CPU                                               --
--              RISC-V Package                                                --
--              AMBA4 AXI-Lite Bus Interface                                  --
--                                                                            --
--------------------------------------------------------------------------------

-- Copyright (c) 2017-2018 by the author(s)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
--------------------------------------------------------------------------------
-- Author(s):
--   Paco Reina Campo <pacoreinacampo@queenfield.tech>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package peripheral_axi4_pkg is

  constant AXI_ID_WIDTH   : integer := 10;
  constant AXI_ADDR_WIDTH : integer := 64;
  constant AXI_DATA_WIDTH : integer := 64;
  constant AXI_STRB_WIDTH : integer := 8;
  constant AXI_USER_WIDTH : integer := 10;

  -- Burst length specifies the number of data transfers that occur within each burst
  constant AXI_BURST_LENGTH_1  : std_logic_vector(3 downto 0) := X"0";
  constant AXI_BURST_LENGTH_2  : std_logic_vector(3 downto 0) := X"1";
  constant AXI_BURST_LENGTH_3  : std_logic_vector(3 downto 0) := X"2";
  constant AXI_BURST_LENGTH_4  : std_logic_vector(3 downto 0) := X"3";
  constant AXI_BURST_LENGTH_5  : std_logic_vector(3 downto 0) := X"4";
  constant AXI_BURST_LENGTH_6  : std_logic_vector(3 downto 0) := X"5";
  constant AXI_BURST_LENGTH_7  : std_logic_vector(3 downto 0) := X"6";
  constant AXI_BURST_LENGTH_8  : std_logic_vector(3 downto 0) := X"7";
  constant AXI_BURST_LENGTH_9  : std_logic_vector(3 downto 0) := X"8";
  constant AXI_BURST_LENGTH_10 : std_logic_vector(3 downto 0) := X"9";
  constant AXI_BURST_LENGTH_11 : std_logic_vector(3 downto 0) := X"A";
  constant AXI_BURST_LENGTH_12 : std_logic_vector(3 downto 0) := X"B";
  constant AXI_BURST_LENGTH_13 : std_logic_vector(3 downto 0) := X"C";
  constant AXI_BURST_LENGTH_14 : std_logic_vector(3 downto 0) := X"D";
  constant AXI_BURST_LENGTH_15 : std_logic_vector(3 downto 0) := X"e";
  constant AXI_BURST_LENGTH_16 : std_logic_vector(3 downto 0) := X"F";

  -- Burst Size specifies the maximum number of data bytes to transfer in each beat, or data transfer, within a burst
  constant AXI_BURST_SIZE_BYTE      : std_logic_vector(2 downto 0) := "000";
  constant AXI_BURST_SIZE_HALF      : std_logic_vector(2 downto 0) := "001";
  constant AXI_BURST_SIZE_WORD      : std_logic_vector(2 downto 0) := "010";
  constant AXI_BURST_SIZE_LONG_WORD : std_logic_vector(2 downto 0) := "011";
  constant AXI_BURST_SIZE_16BYTES   : std_logic_vector(2 downto 0) := "100";
  constant AXI_BURST_SIZE_32BYTES   : std_logic_vector(2 downto 0) := "101";
  constant AXI_BURST_SIZE_64BYTES   : std_logic_vector(2 downto 0) := "110";
  constant AXI_BURST_SIZE_128BYTES  : std_logic_vector(2 downto 0) := "111";

  -- Burst Type
  constant AXI_BURST_TYPE_FIXED : std_logic_vector(1 downto 0) := "00";
  constant AXI_BURST_TYPE_INCR  : std_logic_vector(1 downto 0) := "01";
  constant AXI_BURST_TYPE_WRAP  : std_logic_vector(1 downto 0) := "10";
  constant AXI_BURST_TYPE_RSRV  : std_logic_vector(1 downto 0) := "11";

  -- Lock Type
  constant AXI_LOCK_NORMAL    : std_logic_vector(1 downto 0) := "00";
  constant AXI_LOCK_EXCLUSIVE : std_logic_vector(1 downto 0) := "01";
  constant AXI_LOCK_LOCKED    : std_logic_vector(1 downto 0) := "10";
  constant AXI_LOCK__RESERVED : std_logic_vector(1 downto 0) := "11";

  -- Protection Type
  constant AXI_PROTECTION_NORMAL      : std_logic_vector(2 downto 0) := "000";
  constant AXI_PROTECTION_PRIVILEGED  : std_logic_vector(2 downto 0) := "001";
  constant AXI_PROTECTION_SECURE      : std_logic_vector(2 downto 0) := "000";
  constant AXI_PROTECTION_NONSECURE   : std_logic_vector(2 downto 0) := "010";
  constant AXI_PROTECTION_INSTRUCTION : std_logic_vector(2 downto 0) := "100";
  constant AXI_PROTECTION_DATA        : std_logic_vector(2 downto 0) := "000";

  -- Response Type
  constant AXI_RESPONSE_OKAY         : std_logic_vector(1 downto 0) := "00";
  constant AXI_RESPONSE_EXOKAY       : std_logic_vector(1 downto 0) := "01";
  constant AXI_RESPONSE_SLAVE_ERROR  : std_logic_vector(1 downto 0) := "10";
  constant AXI_RESPONSE_DECODE_ERROR : std_logic_vector(1 downto 0) := "10";

  -- Address Test
  constant AXI_ADDRESS_TEST : std_logic_vector(31 downto 0) := = X"000F";

end peripheral_axi4_pkg;
