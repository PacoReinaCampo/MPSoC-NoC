-- Converted from rtl/verilog/router/mpsoc_noc_router_input.sv
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
use ieee.math_real.all;

use work.mpsoc_noc_pkg.all;

entity mpsoc_noc_router_input is
  generic (
    FLIT_WIDTH   : integer := 34;
    VCHANNELS    : integer := 7;
    OUTPUTS      : integer := 7;
    NODES        : integer := 8;
    BUFFER_DEPTH : integer := 4
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    routes : in M_NODES_OUTPUTS;

    in_flit  : in  std_logic_vector(FLIT_WIDTH-1 downto 0);
    in_last  : in  std_logic;
    in_valid : in  std_logic_vector(VCHANNELS-1 downto 0);
    in_ready : out std_logic_vector(VCHANNELS-1 downto 0);

    out_valid : out M_VCHANNELS_OUTPUTS;
    out_last  : out std_logic_vector(VCHANNELS-1 downto 0);
    out_flit  : out M_VCHANNELS_FLIT_WIDTH;
    out_ready : in  M_VCHANNELS_OUTPUTS
  );
end mpsoc_noc_router_input;

architecture RTL of mpsoc_noc_router_input is
  component mpsoc_noc_buffer
    generic (
      FLIT_WIDTH : integer := 32;
      DEPTH      : integer := 16;
      FULLPACKET : integer := 0
    );
    port (
      -- the width of the index
      clk : in std_logic;
      rst : in std_logic;

      --FIFO input side
      in_flit  : in  std_logic_vector(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic;
      in_valid : in  std_logic;
      in_ready : out std_logic;

      --FIFO output side
      out_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
      out_last  : out std_logic;
      out_valid : out std_logic;
      out_ready : in  std_logic;

      packet_size : out std_logic_vector(integer(log2(real(DEPTH))) downto 0)
    );
  end component;

  component mpsoc_noc_router_lookup
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
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --
  signal buffer_flit  : M_VCHANNELS_FLIT_WIDTH;
  signal buffer_last  : std_logic_vector(VCHANNELS-1 downto 0);
  signal buffer_valid : std_logic_vector(VCHANNELS-1 downto 0);
  signal buffer_ready : std_logic_vector(VCHANNELS-1 downto 0);

--////////////////////////////////////////////////////////////////
--
-- Module Body
--
begin
  generating_0 : for v in 0 to VCHANNELS - 1 generate
    U_buffer : mpsoc_noc_buffer
      generic map (
        FLIT_WIDTH => FLIT_WIDTH,
        DEPTH      => BUFFER_DEPTH,
        FULLPACKET => 0
      )
      port map (
        clk => clk,
        rst => rst,

        in_flit  => in_flit,
        in_last  => in_last,
        in_valid => in_valid (v),
        in_ready => in_ready (v),

        out_flit  => buffer_flit  (v),
        out_last  => buffer_last  (v),
        out_valid => buffer_valid (v),
        out_ready => buffer_ready (v),

        packet_size => open
      );

    router_lookup : mpsoc_noc_router_lookup
      generic map (
        FLIT_WIDTH => FLIT_WIDTH,
        NODES      => NODES,
        OUTPUTS    => OUTPUTS
      )
      port map (
        clk => clk,
        rst => rst,

        routes  => routes,

        in_flit  => buffer_flit  (v),
        in_last  => buffer_last  (v),
        in_valid => buffer_valid (v),
        in_ready => buffer_ready (v),

        out_flit  => out_flit  (v),
        out_last  => out_last  (v),
        out_valid => out_valid (v),
        out_ready => out_ready (v)
      );
  end generate;
end RTL;
