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
--              Peripheral-NoC for MPSoC                                      --
--              Network on Chip for MPSoC                                     --
--                                                                            --
--------------------------------------------------------------------------------

-- Copyright (c) 2018-2019 by the author(s)
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
--   Stefan Wallentowitz <stefan@wallentowitz.de>
--   Paco Reina Campo <pacoreinacampo@queenfield.tech>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vhdl_pkg.all;

entity peripheral_arbiter_rr is
  generic (
    N : integer := 2
    );
  port (
    req     : in  std_logic_vector(N-1 downto 0);
    en      : in  std_logic;
    gnt     : in  std_logic_vector(N-1 downto 0);
    nxt_gnt : out std_logic_vector(N-1 downto 0)
    );
end peripheral_arbiter_rr;

architecture rtl of peripheral_arbiter_rr is
  ------------------------------------------------------------------------------
  -- Variables
  ------------------------------------------------------------------------------

  -- Mask net
  signal mask : std_logic_matrix(N-1 downto 0)(N-1 downto 0);

begin
  ------------------------------------------------------------------------------
  -- Module Body
  ------------------------------------------------------------------------------
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
    nxt_gnt(k) <= (reduce_nor(mask(k) and req) and req(k)) or (reduce_nor(req) and gnt(k)) when en = '1' else gnt(k);
  end generate;
end rtl;
