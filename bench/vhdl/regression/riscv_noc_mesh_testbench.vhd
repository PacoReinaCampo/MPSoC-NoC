-- Converted from riscv_mesh_testbench.sv
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
--              Network on Chip TestBench                                     //
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

entity riscv_noc_mesh_testbench is
end riscv_noc_mesh_testbench;

architecture RTL of riscv_noc_mesh_testbench is
  component riscv_noc_mesh
    generic (
      PLEN      : integer := 64;
      NODES     : integer := 8;
      INPUTS    : integer := 7;
      OUTPUTS   : integer := 7;
      CHANNELS  : integer := 2;
      VCHANNELS : integer := 2
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      in_flit  : in  M_NODES_CHANNELS_PLEN;
      in_last  : in  M_NODES_CHANNELS;
      in_valid : in  M_NODES_CHANNELS;
      in_ready : out M_NODES_CHANNELS;

      out_flit  : out M_NODES_CHANNELS_PLEN;
      out_last  : out M_NODES_CHANNELS;
      out_valid : out M_NODES_CHANNELS;
      out_ready : in  M_NODES_CHANNELS
    );
  end component;

  component riscv_noc_demux
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
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Constants
  --
  constant PLEN : integer := 64;
  constant NODES : integer := 8;
  constant INPUTS : integer := 7;
  constant OUTPUTS : integer := 7;
  constant CHANNELS : integer := 1;
  constant VCHANNELS : integer := 2;

  constant MAPPING : std_ulogic_vector(PLEN-1 downto 0) := (others => 'X');

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --
  signal HCLK    : std_logic;
  signal HRESETn : std_logic;

  signal noc_out_flit  : M_NODES_CHANNELS_PLEN;
  signal noc_out_last  : M_NODES_CHANNELS;
  signal noc_out_valid : M_NODES_CHANNELS;
  signal noc_out_ready : M_NODES_CHANNELS;

  signal noc_in_flit  : M_NODES_CHANNELS_PLEN;
  signal noc_in_last  : M_NODES_CHANNELS;
  signal noc_in_valid : M_NODES_CHANNELS;
  signal noc_in_ready : M_NODES_CHANNELS;

  signal demux_out_flit  : M_CHANNELS_PLEN;
  signal demux_out_last  : std_ulogic_vector(CHANNELS-1 downto 0);
  signal demux_out_valid : std_ulogic_vector(CHANNELS-1 downto 0);
  signal demux_out_ready : std_ulogic_vector(CHANNELS-1 downto 0);

  signal demux_in_flit  : std_ulogic_vector(PLEN-1 downto 0);
  signal demux_in_last  : std_ulogic;
  signal demux_in_valid : std_ulogic;
  signal demux_in_ready : std_ulogic;

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  --DUT
  noc_mesh : riscv_noc_mesh
    generic map (
      PLEN      => PLEN,
      NODES     => NODES,
      INPUTS    => INPUTS,
      OUTPUTS   => OUTPUTS,
      CHANNELS  => CHANNELS,
      VCHANNELS => VCHANNELS
    )
    port map (
      rst => HRESETn,
      clk => HCLK,

      in_flit  => noc_in_flit,
      in_last  => noc_in_last,
      in_valid => noc_in_valid,
      in_ready => noc_in_ready,

      out_flit  => noc_out_flit,
      out_last  => noc_out_last,
      out_valid => noc_out_valid,
      out_ready => noc_out_ready
    );

  noc_demux : riscv_noc_demux
    generic map (
      PLEN     => PLEN,
      CHANNELS => CHANNELS,

      MAPPING => MAPPING
    )
    port map (
      rst => HRESETn,
      clk => HCLK,

      in_flit  => demux_in_flit,
      in_last  => demux_in_last,
      in_valid => demux_in_valid,
      in_ready => demux_in_ready,

      out_flit  => demux_out_flit,
      out_last  => demux_out_last,
      out_valid => demux_out_valid,
      out_ready => demux_out_ready
    );
end RTL;
