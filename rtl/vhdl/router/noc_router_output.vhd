-- Converted from rtl/verilog/router/noc_router_output.sv
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
--              Wishbone Bus Interface                                        //
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
-- *   Stefan Wallentowitz <stefan@wallentowitz.de>
-- *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
-- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.mpsoc_noc_pkg.all;

entity noc_router_output is
  generic (
    FLIT_WIDTH   : integer := 32;
    VCHANNELS    : integer := 7;
    INPUTS       : integer := 7;
    BUFFER_DEPTH : integer := 4
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    in_flit  : in  std_logic_3array(VCHANNELS-1 downto 0)(INPUTS-1 downto 0)(FLIT_WIDTH-1 downto 0);
    in_last  : in  std_logic_matrix(VCHANNELS-1 downto 0)(INPUTS-1 downto 0);
    in_valid : in  std_logic_matrix(VCHANNELS-1 downto 0)(INPUTS-1 downto 0);
    in_ready : out std_logic_matrix(VCHANNELS-1 downto 0)(INPUTS-1 downto 0);

    out_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
    out_last  : out std_logic;
    out_valid : out std_logic_vector(VCHANNELS-1 downto 0);
    out_ready : in  std_logic_vector(VCHANNELS-1 downto 0)
  );
end noc_router_output;

architecture RTL of noc_router_output is
  component noc_mux
    generic (
      FLIT_WIDTH : integer := 32;
      CHANNELS   : integer := 7
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      in_flit  : in  std_logic_matrix(CHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic_vector(CHANNELS-1 downto 0);
      in_valid : in  std_logic_vector(CHANNELS-1 downto 0);
      in_ready : out std_logic_vector(CHANNELS-1 downto 0);

      out_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
      out_last  : out std_logic;
      out_valid : out std_logic;
      out_ready : in  std_logic
    );
  end component;

  component noc_buffer
    generic (
      FLIT_WIDTH : integer := 32;
      DEPTH      : integer := 16
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

  component noc_vchannel_mux
    generic (
      FLIT_WIDTH : integer := 32;
      CHANNELS   : integer := 7
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      in_flit  : in  std_logic_matrix(CHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic_vector(CHANNELS-1 downto 0);
      in_valid : in  std_logic_vector(CHANNELS-1 downto 0);
      in_ready : out std_logic_vector(CHANNELS-1 downto 0);

      out_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
      out_last  : out std_logic;
      out_valid : out std_logic_vector(CHANNELS-1 downto 0);
      out_ready : in  std_logic_vector(CHANNELS-1 downto 0)
    );
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --
  signal channel_flit  : std_logic_matrix(VCHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal channel_last  : std_logic_vector(VCHANNELS-1 downto 0);
  signal channel_valid : std_logic_vector(VCHANNELS-1 downto 0);
  signal channel_ready : std_logic_vector(VCHANNELS-1 downto 0);

  signal buffer_flit  : std_logic_matrix(VCHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal buffer_last  : std_logic_vector(VCHANNELS-1 downto 0);
  signal buffer_valid : std_logic_vector(VCHANNELS-1 downto 0);
  signal buffer_ready : std_logic_vector(VCHANNELS-1 downto 0);

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --
  generating_0 : for v in 0 to VCHANNELS - 1 generate
    mux : noc_mux
      generic map (
        FLIT_WIDTH => FLIT_WIDTH,
        CHANNELS   => INPUTS
      )
      port map (
        clk => clk,
        rst => rst,

        in_flit  => in_flit  (v),
        in_last  => in_last  (v),
        in_valid => in_valid (v),
        in_ready => in_ready (v),

        out_flit  => buffer_flit  (v),
        out_last  => buffer_last  (v),
        out_valid => buffer_valid (v),
        out_ready => buffer_ready (v)
      );

    u_buffer : noc_buffer
      generic map (
        FLIT_WIDTH => FLIT_WIDTH,
        DEPTH      => BUFFER_DEPTH
      )
      port map (
        clk => clk,
        rst => rst,

        in_flit  => buffer_flit  (v),
        in_last  => buffer_last  (v),
        in_valid => buffer_valid (v),
        in_ready => buffer_ready (v),

        out_flit  => channel_flit  (v),
        out_last  => channel_last  (v),
        out_valid => channel_valid (v),
        out_ready => channel_ready (v),

        packet_size => open
      );
  end generate;

  generating_1 : if (VCHANNELS > 1) generate
    vchannel_mux : noc_vchannel_mux
      generic map (
        FLIT_WIDTH => FLIT_WIDTH,
        CHANNELS   => VCHANNELS
      )
      port map (
        clk => clk,
        rst => rst,

        in_flit  => channel_flit,
        in_last  => channel_last,
        in_valid => channel_valid,
        in_ready => channel_ready,

        out_flit  => out_flit,
        out_last  => out_last,
        out_valid => out_valid,
        out_ready => out_ready
      );
  elsif (VCHANNELS <= 1) generate
    out_flit      <= channel_flit (0);
    out_last      <= channel_last (0);
    out_valid     <= channel_valid;

    channel_ready <= out_ready;
  end generate;
end RTL;
