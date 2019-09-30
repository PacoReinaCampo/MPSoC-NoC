-- Converted from rtl/verilog/router/riscv_noc_router_lookup_slice.sv
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
--              Network on Chip Router Lookup Slice                           //
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

entity riscv_noc_router_lookup_slice is
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
end riscv_noc_router_lookup_slice;

architecture RTL of riscv_noc_router_lookup_slice is
  --////////////////////////////////////////////////////////////////
  --
  -- Functions
  --
  function reduce_nor (
    reduce_nor_in : std_ulogic_vector
  ) return std_ulogic is
    variable reduce_nor_out : std_ulogic := '0';
  begin
    for i in reduce_nor_in'range loop
      reduce_nor_out := reduce_nor_out nor reduce_nor_in(i);
    end loop;
    return reduce_nor_out;
  end reduce_nor;

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

  -- This is an intermediate register that we use to avoid
  -- stop-and-go behavior
  signal reg_flit  : std_ulogic_vector(PLEN-1 downto 0);
  signal reg_last  : std_ulogic;
  signal reg_valid : std_ulogic_vector(OUTPUTS-1 downto 0);

  -- This signal selects where to store the next incoming flit
  signal pressure : std_ulogic;

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  -- A backpressure in the output port leads to backpressure on the
  -- input with one cycle delay
  in_ready <= not pressure;

  processing_0 : process (clk)
    variable out_valid_sgnl : std_ulogic_vector(OUTPUTS-1 downto 0);
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        pressure       <= '0';
        out_valid_sgnl := (others => '0');
      elsif (pressure = '0') then
        -- We are accepting the input in this cycle, determine
        -- where to store it..
        if (reduce_nor(out_valid_sgnl) = '1' or reduce_or(out_ready and out_valid_sgnl) = '1') then
          -- There is no flit waiting in the register, or
          -- The current flit is transfered this cycle
          out_flit       <= in_flit;
          out_last       <= in_last;
          out_valid_sgnl := in_valid;
        elsif (reduce_or(out_valid_sgnl) = '1' and reduce_nor(out_ready) = '1') then
          -- Otherwise if there is a flit waiting and upstream
          -- not ready, push it to the second register. Enter the
          -- backpressure mode.
          reg_flit  <= in_flit;
          reg_last  <= in_last;
          reg_valid <= in_valid;
          pressure  <= '1';
        end if;
      -- if (!pressure)
      -- We can be sure that a flit is waiting now (don't need
      -- to check)
      elsif (reduce_or(out_ready) = '1') then
        -- If the output accepted this flit, go back to
        -- accepting input flits.
        out_flit  <= reg_flit;
        out_last  <= reg_last;
        out_valid <= reg_valid;
        pressure  <= '0';
      end if;
    end if;

  out_valid <= out_valid_sgnl;
  end process;
end RTL;
