-- Converted from rtl/verilog/blocks/riscv_noc_inputs_mux.sv
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
--              Network on Chip Multiplexer                                   //
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

entity riscv_noc_inputs_mux is
  generic (
    PLEN   : integer := 64;
    INPUTS : integer := 7
  );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    in_flit  : in  M_INPUTS_PLEN;
    in_last  : in  std_ulogic_vector(INPUTS-1 downto 0);
    in_valid : in  std_ulogic_vector(INPUTS-1 downto 0);
    in_ready : out std_ulogic_vector(INPUTS-1 downto 0);

    out_flit  : out std_ulogic_vector(PLEN-1 downto 0);
    out_last  : out std_ulogic;
    out_valid : out std_ulogic;
    out_ready : in  std_ulogic
  );
end riscv_noc_inputs_mux;

architecture RTL of riscv_noc_inputs_mux is
  component riscv_arb_rr
    generic (
      N : integer := 2
    );
    port (
      req     : in  std_ulogic_vector(N-1 downto 0);
      en      : in  std_ulogic;
      gnt     : in  std_ulogic_vector(N-1 downto 0);
      nxt_gnt : out std_ulogic_vector(N-1 downto 0)
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
  signal selected : std_ulogic_vector(INPUTS-1 downto 0);
  signal active   : std_ulogic_vector(INPUTS-1 downto 0);

  signal activeroute     : std_ulogic;
  signal nxt_activeroute : std_ulogic;

  signal req_masked : std_ulogic_vector(INPUTS-1 downto 0);

  signal out_last_sgnl : std_ulogic;

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --
  req_masked <= (req_masked'range => not activeroute and out_ready) and in_valid;

  processing_0 : process (selected, in_flit, in_last)
  begin
    out_flit      <= (others => '0');
    out_last_sgnl <= '0';
    for c in 0 to INPUTS - 1 loop
      if (selected(c) = '1') then
        out_flit      <= in_flit(c);
        out_last_sgnl <= in_last(c);
      end if;
    end loop;
  end process;

  processing_1 : process (activeroute, in_valid, out_ready, active, out_last_sgnl, selected)
  begin
    nxt_activeroute <= activeroute;
    in_ready        <= (others => '0');

    if (activeroute = '1') then
      if (reduce_or(in_valid) = '1' and out_ready = '1') then
        in_ready  <= active;
        out_valid <= '1';
        if (out_last_sgnl = '1') then
          nxt_activeroute <= '0';
        end if;
      else
        out_valid <= '0';
        in_ready  <= (others => '0');
      end if;
    else
      out_valid <= '0';
      if (reduce_or(in_valid) = '1' and out_ready = '1') then
        out_valid       <= '1';
        nxt_activeroute <= not out_last_sgnl;
        in_ready        <= selected;
      end if;
    end if;
  end process;

  processing_2 : process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        activeroute <= '0';
        active      <= std_ulogic_vector(to_unsigned(1, INPUTS));
      else
        activeroute <= nxt_activeroute;
        active      <= selected;
      end if;
    end if;
  end process;

  arb_rr : riscv_arb_rr
    generic map (
      N => INPUTS
    )
    port map (
      nxt_gnt => selected,
      req     => req_masked,
      gnt     => active,
      en      => '1'
    );

  out_last <= out_last_sgnl;
end RTL;
