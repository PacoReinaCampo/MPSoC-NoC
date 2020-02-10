-- Converted from rtl/verilog/router/mpsoc_noc_router_lookup.sv
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

entity mpsoc_noc_router_lookup is
  generic (
    FLIT_WIDTH : integer := 32;
    NODES      : integer := 8;
    OUTPUTS    : integer := 7
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    routes : in M_NODES_OUTPUTS;

    in_flit  : in  std_logic_vector(FLIT_WIDTH-1 downto 0);
    in_last  : in  std_logic;
    in_valid : in  std_logic;
    in_ready : out std_logic;

    out_valid : out std_logic_vector(OUTPUTS-1 downto 0);
    out_last  : out std_logic;
    out_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
    out_ready : in  std_logic_vector(OUTPUTS-1 downto 0)
  );
end mpsoc_noc_router_lookup;

architecture RTL of mpsoc_noc_router_lookup is
  component mpsoc_noc_router_lookup_slice
    generic (
      FLIT_WIDTH : integer := 32;
      OUTPUTS    : integer := 7
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      in_flit  : in  std_logic_vector(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic;
      in_valid : in  std_logic_vector(OUTPUTS-1 downto 0);
      in_ready : out std_logic;

      out_valid : out std_logic_vector(OUTPUTS-1 downto 0);
      out_last  : out std_logic;
      out_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
      out_ready : in  std_logic_vector(OUTPUTS-1 downto 0)
    );
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Functions
  --
  function reduce_or (
    reduce_or_in : std_logic_vector
    ) return std_logic is
    variable reduce_or_out : std_logic := '0';
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
  signal worm     : std_logic_vector(OUTPUTS-1 downto 0);
  signal nxt_worm : std_logic_vector(OUTPUTS-1 downto 0);

  -- This is high if we are in a worm
  signal wormhole : std_logic;

  -- Extract destination from flit
  signal dest : std_logic_vector(OUTPUTS-1 downto 0);

  -- This is the selection signal of the slave, one hot so that it
  -- directly serves as flow control valid
  signal valid : std_logic_vector(OUTPUTS-1 downto 0);

  signal in_ready_sgn : std_logic;

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  -- This is high if we are in a worm
  wormhole <= reduce_or(worm);

  -- Extract destination from flit
  dest <= in_flit(FLIT_WIDTH-1 downto FLIT_WIDTH-OUTPUTS);

  -- Register slice at the output.
  router_lookup_slice : mpsoc_noc_router_lookup_slice
    generic map (
      FLIT_WIDTH => FLIT_WIDTH,
      OUTPUTS    => OUTPUTS
    )
    port map (
      clk => clk,
      rst => rst,

      in_flit  => in_flit,
      in_last  => in_last,
      in_valid => valid,
      in_ready => in_ready_sgn,

      out_valid => out_valid,
      out_last  => out_last,
      out_flit  => out_flit,
      out_ready => out_ready
    );

  processing_0 : process (dest, in_last, in_ready_sgn, in_valid, worm, wormhole)
  begin
    nxt_worm <= worm;
    valid    <= (others => '0');

    if (wormhole = '1') then
      -- We are waiting for a flit
      if (in_valid = '1') then
        -- This is a header. Lookup output
        valid <= routes(to_integer(unsigned(dest)));
        if (in_ready_sgn = '1' and in_last = '0') then
          -- If we can push it further and it is not the only
          -- flit, enter a worm and store the output
          nxt_worm <= routes(to_integer(unsigned(dest)));
        end if;
      end if;
    else  -- if (!wormhole)
      -- We are in a worm
      -- The valid is set on the currently select output
      valid <= worm and (valid'range => in_valid);
      if (in_ready_sgn = '1' and in_last = '1') then
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

  in_ready <= in_ready_sgn;
end RTL;
