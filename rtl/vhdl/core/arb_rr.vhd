-- Converted from rtl/verilog/core/arb_rr.sv
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
--              Direct Access Memory Interface                                //
--              AMBA3 AHB-Lite Bus Interface                                  //
--              WishBone Bus Interface                                        //
--                                                                            //
--//////////////////////////////////////////////////////////////////////////////

-- Copyright (c) 2018-2019 by the author(s)
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

entity arb_rr is
  generic (
    N : integer := 2
    );
  port (
    req     : in  std_logic_vector(N-1 downto 0);
    gnt     : in  std_logic_vector(N-1 downto 0);
    nxt_gnt : out std_logic_vector(N-1 downto 0)
    );
end arb_rr;

architecture RTL of arb_rr is
  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --
  type M_N_N is array (N-1 downto 0) of std_logic_vector(N-1 downto 0);

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --

  -- Mask net
  signal mask : M_N_N;

  --//////////////////////////////////////////////////////////////
  --
  -- Functions
  --
  function reduce_nor (
    reduce_nor_in : std_logic_vector
  ) return std_logic is
    variable reduce_nor_out : std_logic := '0';
  begin
    for i in reduce_nor_in'range loop
      reduce_nor_out := reduce_nor_out nor reduce_nor_in(i);
    end loop;
    return reduce_nor_out;
  end reduce_nor;

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module body
  --
  processing_0 : process (gnt)
  begin
    for i in 0 to N - 1 loop
      -- Initialize mask as 0
      mask(i) <= (others => '0');
      if (i > 0) then
        -- For i=N:1 the next right is i-1
        mask(i)(i-1) <= not gnt(i-1);
      else
        -- For i=0 the next right is N-1
        mask(i)(N-1) <= not gnt(N-1);
      end if;
      for j in 2 to N - 1 loop
        if (i-j >= 0) then
          mask(i)(i-j) <= mask(i)(i-j+1) and not gnt(i-j);
        elsif (i-j+1 >= 0) then
          mask(i)(i-j+N) <= mask(i)(i-j+1) and not gnt(i-j+N);
        else
          mask(i)(i-j+N) <= mask(i)(i-j+N+1) and not gnt(i-j+N);
        end if;
      end loop;
    end loop;
  end process;

  -- Calculate the nxt_gnt
  generating_0 : for k in 0 to N - 1 generate
    nxt_gnt(k) <= (reduce_nor(mask(k) and req) and req(k)) or (reduce_nor(req) and gnt(k));
  end generate;
end RTL;
