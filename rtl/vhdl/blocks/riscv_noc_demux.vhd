-- Converted from rtl/verilog/blocks/riscv_noc_demux.sv
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
--              Network on Chip Demultiplexer                                 //
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

entity riscv_noc_demux is
  generic (
    PLEN     : integer := 64;
    CHANNELS : integer := 2;

    MAPPING    : std_ulogic_vector(63 downto 0) := (others => 'X')
  );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    in_flit  : in  std_ulogic_vector(PLEN-1 downto 0);
    in_last  : in  std_ulogic;
    in_valid : in  std_ulogic;
    in_ready : out std_ulogic;

    out_flit  : out M_CHANNELS_PLEN;
    out_last  : out std_ulogic_vector(CHANNELS-1 downto 0);
    out_valid : out std_ulogic_vector(CHANNELS-1 downto 0);
    out_ready : in  std_ulogic_vector(CHANNELS-1 downto 0)
  );
end riscv_noc_demux;

architecture RTL of riscv_noc_demux is
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
  signal actived     : std_ulogic_vector(CHANNELS-1 downto 0);
  signal nxt_actived : std_ulogic_vector(CHANNELS-1 downto 0);

  signal packet_class : std_ulogic_vector(2 downto 0);
  signal selected     : std_ulogic_vector(CHANNELS-1 downto 0);

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --
  packet_class <= in_flit(NOC_CLASS_MSB downto NOC_CLASS_LSB);

  processing_0 : process (selected, packet_class)
  begin
    selected <= MAPPING(8*to_integer(unsigned(packet_class))+CHANNELS-1 downto 8*to_integer(unsigned(packet_class)));
    if (selected = (selected'range => '0')) then
      selected <= std_ulogic_vector(to_unsigned(1, CHANNELS));
    end if;
  end process;

  generating_0 : for i in CHANNELS-1 downto 0 generate
    out_flit(i) <= in_flit;
  end generate;

  out_last <= (out_last'range => in_last);

  processing_1 : process (actived, in_valid, in_last, out_ready, selected)
  begin
    nxt_actived <= actived;

    out_valid <= (others => '0');
    in_ready  <= '0';

    if (actived = (actived'range => '0')) then
      in_ready  <= reduce_or(selected and out_ready);
      out_valid <= selected and (out_valid'range => in_valid);

      if (in_valid = '1' and in_last = '0') then
        nxt_actived <= selected;
      end if;
    else
      in_ready  <= reduce_or(actived and out_ready);
      out_valid <= actived and (out_valid'range => in_valid);

      if (in_valid = '1' and in_last = '1') then
        nxt_actived <= (others => '0');
      end if;
    end if;
  end process;

  processing_2 : process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        actived <= (others => '0');
      else
        actived <= nxt_actived;
      end if;
    end if;
  end process;
end RTL;
