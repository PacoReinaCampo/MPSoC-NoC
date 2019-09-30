-- Converted from rtl/verilog/router/riscv_noc_router_lookup.sv
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
--              Network on Chip Router Lookup                                 //
--              Mesh Topology                                                 //
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

use work.riscv_mpsoc_pkg.all;
use work.riscv_noc_pkg.all;

entity riscv_noc_router_lookup is
  generic (
    PLEN    : integer := 64;
    OUTPUTS : integer := 7;

    ROUTES : std_ulogic_vector(8*7-1 downto 0) := (others => '0')
  );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    in_flit  : in  std_ulogic_vector(PLEN-1 downto 0);
    in_last  : in  std_ulogic;
    in_valid : in  std_ulogic;
    in_ready : out std_ulogic;

    out_valid : out std_ulogic_vector(OUTPUTS-1 downto 0);
    out_last  : out std_ulogic;
    out_flit  : out std_ulogic_vector(PLEN-1 downto 0);
    out_ready : in  std_ulogic_vector(OUTPUTS-1 downto 0)
  );
end riscv_noc_router_lookup;

architecture RTL of riscv_noc_router_lookup is
  component riscv_noc_router_lookup_slice
    generic (
      PLEN    : integer := 64;
      OUTPUTS : integer := 7
    );
    port (
      clk : in std_ulogic;
      rst : in std_ulogic;

      in_flit  : in  std_ulogic_vector(PLEN-1 downto 0);
      in_last  : in  std_ulogic;
      in_valid : in  std_ulogic_vector(OUTPUTS-1 downto 0);
      in_ready : out std_ulogic;

      out_valid : out std_ulogic_vector(OUTPUTS-1 downto 0);
      out_last  : out std_ulogic;
      out_flit  : out std_ulogic_vector(PLEN-1 downto 0);
      out_ready : in  std_ulogic_vector(OUTPUTS-1 downto 0)
    );
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Functions
  --
  function reduce_or (
    reduce_or_in : std_ulogic_vector
    ) return std_ulogic is
    variable reduce_or_out : std_ulogic := '0';
  begin
    for i in reduce_or_in'range loop
      reduce_or_out := reduce_or_out or reduce_or_in(i);
    end loop;
    return reduce_or_out;
  end reduce_or;

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --

  -- We need to track worms and directly encode the output of the
  -- current worm.
  signal worm     : std_ulogic_vector(OUTPUTS-1 downto 0);
  signal nxt_worm : std_ulogic_vector(OUTPUTS-1 downto 0);
  -- This is high if we are in a worm
  signal wormhole : std_ulogic;

  -- Extract destination from flit
  signal dest : std_ulogic_vector(OUTPUTS-1 downto 0);

  -- This is the selection signal of the slave, one hot so that it
  -- directly serves as flow control valid
  signal valid : std_ulogic_vector(OUTPUTS-1 downto 0);

  signal in_ready_sgnl : std_ulogic;

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  -- We need to track worms and directly encode the output of the
  -- This is high if we are in a worm
  wormhole <= reduce_or(worm);

  -- Extract destination from flit
  dest <= in_flit(OUTPUTS-1 downto 0);

  -- Register slice at the output.
  noc_router_lookup_slice : riscv_noc_router_lookup_slice
    generic map (
      PLEN    => PLEN,
      OUTPUTS => OUTPUTS
    )
    port map (
      clk => clk,
      rst => rst,

      in_flit  => in_flit,
      in_last  => in_last,
      in_valid => valid,
      in_ready => in_ready_sgnl,

      out_valid => out_valid,
      out_last  => out_last,
      out_flit  => out_flit,
      out_ready => out_ready
    );

  processing_0 : process (dest, in_last, in_ready_sgnl, in_valid, worm, wormhole)
  begin
    nxt_worm <= worm;
    valid    <= (others => '0');

    if (wormhole = '1') then
      -- We are waiting for a flit
      if (in_valid = '1') then
        -- This is a header. Lookup output
        valid <= ROUTES((to_integer(unsigned(dest))+1)*OUTPUTS-1 downto to_integer(unsigned(dest))*OUTPUTS);
        if (in_ready_sgnl = '1' and in_last = '0') then
          -- If we can push it further and it is not the only
          -- flit, enter a worm and store the output
          nxt_worm <= ROUTES((to_integer(unsigned(dest))+1)*OUTPUTS-1 downto to_integer(unsigned(dest))*OUTPUTS);
        end if;
      end if;
    else                                -- if (!wormhole)
      -- We are in a worm
      -- The valid is set on the currently select output
      valid <= worm and (valid'range => in_valid);
      if (in_ready_sgnl = '1' and in_last = '1') then
        -- End of worm
        nxt_worm <= (others => '0');
      end if;
    end if;
  end process;

  processing_1 : process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        worm <= (others => '0');
      else
        worm <= nxt_worm;
      end if;
    end if;
  end process;

  in_ready <= in_ready_sgnl;
end RTL;
