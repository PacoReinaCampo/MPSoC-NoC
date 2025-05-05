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
--              Package                                                       --
--              Bus Functional Model                                          --
--              AMBA4 AHB-Lite Bus Interface                                  --
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

package peripheral_biu_pkg is

  constant HADDR_SIZE : integer := 64;
  constant HDATA_SIZE : integer := 64;

  -- HTRANS
  constant HTRANS_IDLE   : std_logic_vector(1 downto 0) := "00";
  constant HTRANS_BUSY   : std_logic_vector(1 downto 0) := "01";
  constant HTRANS_NONSEQ : std_logic_vector(1 downto 0) := "10";
  constant HTRANS_SEQ    : std_logic_vector(1 downto 0) := "11";

  -- HSIZE
  constant HSIZE_B8    : std_logic_vector(2 downto 0) := "000";
  constant HSIZE_B16   : std_logic_vector(2 downto 0) := "001";
  constant HSIZE_B32   : std_logic_vector(2 downto 0) := "010";
  constant HSIZE_B64   : std_logic_vector(2 downto 0) := "011";
  constant HSIZE_B128  : std_logic_vector(2 downto 0) := "100";  -- 4-word line
  constant HSIZE_B256  : std_logic_vector(2 downto 0) := "101";  -- 8-word line
  constant HSIZE_B512  : std_logic_vector(2 downto 0) := "110";
  constant HSIZE_B1024 : std_logic_vector(2 downto 0) := "111";
  constant HSIZE_BYTE  : std_logic_vector(2 downto 0) := HSIZE_B8;
  constant HSIZE_HWORD : std_logic_vector(2 downto 0) := HSIZE_B16;
  constant HSIZE_WORD  : std_logic_vector(2 downto 0) := HSIZE_B32;
  constant HSIZE_DWORD : std_logic_vector(2 downto 0) := HSIZE_B64;

  -- HBURST
  constant HBURST_SINGLE : std_logic_vector(2 downto 0) := "000";
  constant HBURST_INCR   : std_logic_vector(2 downto 0) := "001";
  constant HBURST_WRAP4  : std_logic_vector(2 downto 0) := "010";
  constant HBURST_INCR4  : std_logic_vector(2 downto 0) := "011";
  constant HBURST_WRAP8  : std_logic_vector(2 downto 0) := "100";
  constant HBURST_INCR8  : std_logic_vector(2 downto 0) := "101";
  constant HBURST_WRAP16 : std_logic_vector(2 downto 0) := "110";
  constant HBURST_INCR16 : std_logic_vector(2 downto 0) := "111";

  -- HPROT
  constant HPROT_OPCODE         : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_DATA           : std_logic_vector(3 downto 0) := "0001";
  constant HPROT_USER           : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_PRIVILEGED     : std_logic_vector(3 downto 0) := "0010";
  constant HPROT_NON_BUFFERABLE : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_BUFFERABLE     : std_logic_vector(3 downto 0) := "0100";
  constant HPROT_NON_CACHEABLE  : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_CACHEABLE      : std_logic_vector(3 downto 0) := "1000";

  -- HRESP
  constant HRESP_OKAY  : std_logic := '0';
  constant HRESP_ERROR : std_logic := '1';

end peripheral_biu_pkg;
