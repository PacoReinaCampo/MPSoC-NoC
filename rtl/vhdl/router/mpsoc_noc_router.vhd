-- Converted from rtl/verilog/router/mpsoc_noc_router.sv
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

entity mpsoc_noc_router is
  generic (
    FLIT_WIDTH      : integer := 32;
    VCHANNELS       : integer := 7;
    CHANNELS        : integer := 7;
    OUTPUTS         : integer := 7;
    BUFFER_SIZE_IN  : integer := 4;
    BUFFER_SIZE_OUT : integer := 4;
    NODES           : integer := 8
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    routes : in std_logic_matrix(NODES-1 downto 0)(OUTPUTS-1 downto 0);

    out_flit  : out std_logic_matrix(OUTPUTS-1 downto 0)(FLIT_WIDTH-1 downto 0);
    out_last  : out std_logic_vector(OUTPUTS-1 downto 0);
    out_valid : out std_logic_matrix(OUTPUTS-1 downto 0)(VCHANNELS-1 downto 0);
    out_ready : in  std_logic_matrix(OUTPUTS-1 downto 0)(VCHANNELS-1 downto 0);

    in_flit  : in  std_logic_matrix(CHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
    in_last  : in  std_logic_vector(CHANNELS-1 downto 0);
    in_valid : in  std_logic_matrix(CHANNELS-1 downto 0)(VCHANNELS-1 downto 0);
    in_ready : out std_logic_matrix(CHANNELS-1 downto 0)(VCHANNELS-1 downto 0)
  );
end mpsoc_noc_router;

architecture RTL of mpsoc_noc_router is
  component mpsoc_noc_router_input
    generic (
      FLIT_WIDTH   : integer := 32;
      VCHANNELS    : integer := 7;
      OUTPUTS      : integer := 7;
      NODES        : integer := 8;
      BUFFER_DEPTH : integer := 4
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      routes : in std_logic_matrix(NODES-1 downto 0)(OUTPUTS-1 downto 0);

      in_flit  : in  std_logic_vector(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic;
      in_valid : in  std_logic_vector(VCHANNELS-1 downto 0);
      in_ready : out std_logic_vector(VCHANNELS-1 downto 0);

      out_valid : out std_logic_matrix(VCHANNELS-1 downto 0)(OUTPUTS-1 downto 0);
      out_last  : out std_logic_vector(VCHANNELS-1 downto 0);
      out_flit  : out std_logic_matrix(VCHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
      out_ready : in  std_logic_matrix(VCHANNELS-1 downto 0)(OUTPUTS-1 downto 0)
    );
  end component;

  component mpsoc_noc_router_output
    generic (
      FLIT_WIDTH   : integer := 32;
      VCHANNELS    : integer := 7;
      CHANNELS     : integer := 7;
      BUFFER_DEPTH : integer := 4
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      in_flit  : in  std_logic_3array(VCHANNELS-1 downto 0)(CHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic_matrix(VCHANNELS-1 downto 0)(CHANNELS-1 downto 0);
      in_valid : in  std_logic_matrix(VCHANNELS-1 downto 0)(CHANNELS-1 downto 0);
      in_ready : out std_logic_matrix(VCHANNELS-1 downto 0)(CHANNELS-1 downto 0);

      out_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
      out_last  : out std_logic;
      out_valid : out std_logic_vector(VCHANNELS-1 downto 0);
      out_ready : in  std_logic_vector(VCHANNELS-1 downto 0)
    );
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --

  -- The "switch" is just wiring (all logic is in input and
  -- output). All inputs generate their requests for the outputs and
  -- the output arbitrate between the input requests.

  -- The input valid signals are one (or zero) hot and hence share
  -- the flit signal.
  signal switch_in_flit  : std_logic_3array(CHANNELS-1 downto 0)(VCHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal switch_in_last  : std_logic_matrix(CHANNELS-1 downto 0)(VCHANNELS-1 downto 0);
  signal switch_in_valid : std_logic_3array(CHANNELS-1 downto 0)(VCHANNELS-1 downto 0)(OUTPUTS-1 downto 0);
  signal switch_in_ready : std_logic_3array(CHANNELS-1 downto 0)(VCHANNELS-1 downto 0)(OUTPUTS-1 downto 0);

  -- Outputs are fully wired to receive all input requests.
  signal switch_out_flit  : std_logic_4array(OUTPUTS-1 downto 0)(VCHANNELS-1 downto 0)(CHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal switch_out_last  : std_logic_3array(OUTPUTS-1 downto 0)(VCHANNELS-1 downto 0)(CHANNELS-1 downto 0);
  signal switch_out_valid : std_logic_3array(OUTPUTS-1 downto 0)(VCHANNELS-1 downto 0)(CHANNELS-1 downto 0);
  signal switch_out_ready : std_logic_3array(OUTPUTS-1 downto 0)(VCHANNELS-1 downto 0)(CHANNELS-1 downto 0);

begin
--////////////////////////////////////////////////////////////////
--
-- Module Body
--
  generating_0 : for i in 0 to CHANNELS - 1 generate
    -- The input stages
    router_input : mpsoc_noc_router_input
      generic map (
        FLIT_WIDTH   => FLIT_WIDTH,
        VCHANNELS    => VCHANNELS,
        NODES        => NODES,
        OUTPUTS      => OUTPUTS,
        BUFFER_DEPTH => BUFFER_SIZE_IN
      )
      port map (
        clk => clk,
        rst => rst,

        routes => routes,

        in_flit  => in_flit  (i),
        in_last  => in_last  (i),
        in_valid => in_valid (i),
        in_ready => in_ready (i),

        out_flit  => switch_in_flit  (i),
        out_last  => switch_in_last  (i),
        out_valid => switch_in_valid (i),
        out_ready => switch_in_ready (i)
      );
  end generate;
  -- block: inputs

  -- The switching logic
  generating_1 : for o in 0 to OUTPUTS - 1 generate
    generating_2 : for v in 0 to VCHANNELS - 1 generate
      generating_3 : for i in 0 to CHANNELS - 1 generate
        switch_out_flit  (o)(v)(i) <= switch_in_flit   (i)(v);
        switch_out_last  (o)(v)(i) <= switch_in_last   (i)(v);
        switch_out_valid (o)(v)(i) <= switch_in_valid  (i)(v)(o);
        switch_in_ready  (i)(v)(o) <= switch_out_ready (o)(v)(i);
      end generate;
    end generate;
  end generate;

  generating_4 : for o in 0 to OUTPUTS - 1 generate
    -- The output stages
    router_output : mpsoc_noc_router_output
      generic map (
        FLIT_WIDTH   => FLIT_WIDTH,
        VCHANNELS    => VCHANNELS,
        CHANNELS     => CHANNELS,
        BUFFER_DEPTH => BUFFER_SIZE_OUT
      )
      port map (
        clk => clk,
        rst => rst,

        in_flit  => switch_out_flit  (o),
        in_last  => switch_out_last  (o),
        in_valid => switch_out_valid (o),
        in_ready => switch_out_ready (o),

        out_flit  => out_flit  (o),
        out_last  => out_last  (o),
        out_valid => out_valid (o),
        out_ready => out_ready (o)
      );
  end generate;
end RTL;
