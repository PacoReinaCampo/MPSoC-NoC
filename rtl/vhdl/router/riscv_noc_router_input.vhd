-- Converted from rtl/verilog/router/riscv_noc_router_input.sv
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
--              Router Input                                                  //
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
use ieee.math_real.all;

use work.riscv_mpsoc_pkg.all;
use work.riscv_noc_pkg.all;

entity riscv_noc_router_input is
  generic (
    PLEN : integer := 64;
    OUTPUTS : integer := 7;
    VCHANNELS : integer := 2;
    BUFFER_DEPTH : integer := 4;

    ROUTES : std_ulogic_vector(8*7-1 downto 0) := (others => '0')
  );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    in_flit  : in  std_ulogic_vector(PLEN-1 downto 0);
    in_last  : in  std_ulogic;
    in_valid : in  std_ulogic_vector(VCHANNELS-1 downto 0);
    in_ready : out std_ulogic_vector(VCHANNELS-1 downto 0);

    out_valid : out M_VCHANNELS_OUTPUTS;
    out_last  : out std_ulogic_vector(VCHANNELS-1 downto 0);
    out_flit  : out M_VCHANNELS_PLEN;
    out_ready : in  M_VCHANNELS_OUTPUTS
  );
end riscv_noc_router_input;

architecture RTL of riscv_noc_router_input is
  component riscv_noc_buffer
    generic (
      PLEN : integer := 64;

      BUFFER_DEPTH : integer := 4;
      FULLPACKET   : integer := 1
    );
    port (
      -- the width of the index
      clk : in std_ulogic;
      rst : in std_ulogic;

      --FIFO input side
      in_flit  : in  std_ulogic_vector(PLEN-1 downto 0);
      in_last  : in  std_ulogic;
      in_valid : in  std_ulogic;
      in_ready : out std_ulogic;

      --FIFO output side
      out_flit  : out std_ulogic_vector(PLEN-1 downto 0);
      out_last  : out std_ulogic;
      out_valid : out std_ulogic;
      out_ready : in  std_ulogic;

      packet_size : out std_ulogic_vector(integer(log2(real(BUFFER_DEPTH))) downto 0)
    );
  end component;

  component riscv_noc_router_lookup
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
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --
  signal buffer_flit  : M_VCHANNELS_PLEN;
  signal buffer_last  : std_ulogic_vector(VCHANNELS-1 downto 0);
  signal buffer_valid : std_ulogic_vector(VCHANNELS-1 downto 0);
  signal buffer_ready : std_ulogic_vector(VCHANNELS-1 downto 0);

--////////////////////////////////////////////////////////////////
--
-- Module Body
--
begin
  generating_0 : for v in 0 to VCHANNELS - 1 generate
    noc_buffer : riscv_noc_buffer
      generic map (
        PLEN => PLEN,

        BUFFER_DEPTH => BUFFER_DEPTH,
        FULLPACKET   => 0
      )
      port map (
        clk => clk,
        rst => rst,

        in_flit  => in_flit,
        in_last  => in_last,
        in_valid => in_valid(v),
        in_ready => in_ready(v),

        out_flit  => buffer_flit(v),
        out_last  => buffer_last(v),
        out_valid => buffer_valid(v),
        out_ready => buffer_ready(v),

        packet_size => open
      );

    noc_router_lookup : riscv_noc_router_lookup
      generic map (
        PLEN    => PLEN,
        OUTPUTS => OUTPUTS,

        ROUTES => ROUTES
      )
      port map (
        clk => clk,
        rst => rst,

        in_flit  => buffer_flit(v),
        in_last  => buffer_last(v),
        in_valid => buffer_valid(v),
        in_ready => buffer_ready(v),

        out_flit  => out_flit(v),
        out_last  => out_last(v),
        out_valid => out_valid(v),
        out_ready => out_ready(v)
      );
  end generate;
end RTL;
