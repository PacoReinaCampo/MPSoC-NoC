-- Converted from rtl/verilog/blocks/riscv_noc_vchannel_mux.sv
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
--              Network on Chip Virtual Channel Multiplexer                   //
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

entity riscv_noc_vchannel_mux is
  generic (
    PLEN      : integer := 64;
    VCHANNELS : integer := 2
  );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    in_flit  : in  M_VCHANNELS_PLEN;
    in_last  : in  std_ulogic_vector(VCHANNELS-1 downto 0);
    in_valid : in  std_ulogic_vector(VCHANNELS-1 downto 0);
    in_ready : out std_ulogic_vector(VCHANNELS-1 downto 0);

    out_flit  : out std_ulogic_vector(PLEN-1 downto 0);
    out_last  : out std_ulogic;
    out_valid : out std_ulogic_vector(VCHANNELS-1 downto 0);
    out_ready : in  std_ulogic_vector(VCHANNELS-1 downto 0)
  );
end riscv_noc_vchannel_mux;

architecture RTL of riscv_noc_vchannel_mux is
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
  -- Variables
  --
  signal selected     : std_ulogic_vector(VCHANNELS-1 downto 0);
  signal nxt_selected : std_ulogic_vector(VCHANNELS-1 downto 0);

  signal req : std_ulogic_vector(VCHANNELS-1 downto 0);

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --
  out_valid <= in_valid and selected;
  in_ready  <= out_ready and selected;
  req       <= in_valid and out_ready;

  processing_0 : process (rst, selected, in_flit, in_last)
  begin
    if (rst = '1') then
      out_flit <= (others => 'X');
      out_last <= 'X';
    else
      for c in 0 to CHANNELS - 1 loop
        if (selected(c) = '1') then
          out_flit <= in_flit(c);
          out_last <= in_last(c);
        end if;
      end loop;
    end if;
  end process;

  arb_rr : riscv_arb_rr
    generic map (
      N => VCHANNELS
    )
    port map (
      req     => req,
      en      => '1',
      gnt     => selected,
      nxt_gnt => nxt_selected
    );

  processing_1 : process (clk, rst)
  begin
    if (rst = '1') then
      selected <= std_ulogic_vector(to_unsigned(1, VCHANNELS));
    elsif (rising_edge(clk)) then
      selected <= nxt_selected;
    end if;
  end process;
end RTL;
