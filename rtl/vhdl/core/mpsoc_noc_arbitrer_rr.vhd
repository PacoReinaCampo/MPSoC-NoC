-- Converted from rtl/verilog/core/mpsoc_noc_arbitrer_rr.sv
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
--              Network on Chip                                               //
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

use work.mpsoc_noc_pkg.all;

entity mpsoc_noc_arbitrer_rr is
  generic (
    N : integer := 2
  );
  port (
    req     : in  std_logic_vector(N-1 downto 0);
    en      : in  std_logic;
    gnt     : in  std_logic_vector(N-1 downto 0);
    nxt_gnt : out std_logic_vector(N-1 downto 0)
  );
end mpsoc_noc_arbitrer_rr;

architecture RTL of mpsoc_noc_arbitrer_rr is
  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --
  signal mask : std_logic_matrix(N-1 downto 0)(N-1 downto 0);

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  -- Calculate the mask
  generating_0 : for i in 0 to N - 1 generate
    -- Initialize mask as 0

    -- All participants to the "right" up to the current grant
    -- holder have precendence and therefore a 1 in the mask.
    -- First check if the next right from us has the grant.
    -- Afterwards the mask is calculated iteratively based on
    -- this.
    generating_1 : if (i > 0) generate
      -- For i=N:1 the next right is i-1
      mask(i)(i-1) <= not gnt(i-1);
    elsif (i <= 0) generate
      -- For i=0 the next right is N-1
      mask(i)(N-1) <= not gnt(N-1);
    end generate;
    -- Now the mask contains a 1 when the next right to us is not
    -- the grant holder. If it is the grant holder that means,
    -- that we are the next served (if necessary) as no other has
    -- higher precendence, which is then calculated in the
    -- following by filling up 1s up to the grant holder. To stop
    -- filling up there and not fill up any after this is
    -- iterative by always checking if the one before was not
    -- before the grant holder.
    generating_3 : for j in 2 to N - 1 generate
      generating_4 : if (i-j >= 0) generate
        mask(i)(i-j) <= mask(i)(i-j+1) and not gnt(i-j);
      elsif (i-j+1 >= 0) generate
        mask(i)(i-j+N) <= mask(i)(i-j+1)   and not gnt(i-j+N);
      elsif (i-j+2 >= 0) generate
        mask(i)(i-j+N) <= mask(i)(i-j+N+1) and not gnt(i-j+N);
      end generate;
    end generate;
  end generate;

  -- Calculate the nxt_gnt
  generating_5 : for k in 0 to N - 1 generate
    -- Finally, we only arbitrate when enable is set.         
    nxt_gnt(k) <= (reduce_nor(mask(k) and req) and req(k)) or (reduce_nor(req) and gnt(k))
                  when en = '1' else gnt(k);
  end generate;
end RTL;
