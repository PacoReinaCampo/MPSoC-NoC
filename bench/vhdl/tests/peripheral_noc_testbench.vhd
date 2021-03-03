-- Converted from bench/verilog/regression/mpsoc_noc_testbench.sv
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
-- *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
-- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mpsoc_noc_pkg.all;

entity mpsoc_noc_testbench is
end mpsoc_noc_testbench;

architecture RTL of mpsoc_noc_testbench is
  component noc_mesh4d
    generic (
      FLIT_WIDTH       : integer := 34;
      CHANNELS         : integer := 9;

      ENABLE_VCHANNELS : integer := 1;

      T                : integer := 2;
      X                : integer := 2;
      Y                : integer := 2;
      Z                : integer := 2;

      BUFFER_SIZE_IN   : integer := 4;
      BUFFER_SIZE_OUT  : integer := 4;

      NODES            : integer := 16
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      in_flit  : in  std_logic_3array(NODES-1 downto 0)(CHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);
      in_valid : in  std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);
      in_ready : out std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);

      out_flit  : out std_logic_3array(NODES-1 downto 0)(CHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
      out_last  : out std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);
      out_valid : out std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);
      out_ready : in  std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0)
    );
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Constants
  --
  constant FLIT_WIDTH       : integer := 34;
  constant CHANNELS         : integer := 9;


  constant ENABLE_VCHANNELS : integer := 1;

  constant T                : integer := 2;
  constant X                : integer := 2;
  constant Y                : integer := 2;
  constant Z                : integer := 2;

  constant BUFFER_SIZE_IN   : integer := 4;
  constant BUFFER_SIZE_OUT  : integer := 4;

  constant NODES            : integer := 16;

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --
  signal clk : std_logic;
  signal rst : std_logic;

  signal mpsoc_noc_out_flit  : std_logic_3array(NODES-1 downto 0)(CHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal mpsoc_noc_out_last  : std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);
  signal mpsoc_noc_out_valid : std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);
  signal mpsoc_noc_out_ready : std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);

  signal mpsoc_noc_in_flit  : std_logic_3array(NODES-1 downto 0)(CHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal mpsoc_noc_in_last  : std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);
  signal mpsoc_noc_in_valid : std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);
  signal mpsoc_noc_in_ready : std_logic_matrix(NODES-1 downto 0)(CHANNELS-1 downto 0);

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  --DUT
  u_mesh : noc_mesh4d
  generic map (
    FLIT_WIDTH       => FLIT_WIDTH,
    CHANNELS         => CHANNELS,

    ENABLE_VCHANNELS => ENABLE_VCHANNELS,

    T                => T,
    X                => X,
    Y                => Y,
    Z                => Z,

    BUFFER_SIZE_IN   => BUFFER_SIZE_IN,
    BUFFER_SIZE_OUT  => BUFFER_SIZE_OUT,

    NODES            => NODES
  )
  port map (
    rst => rst,
    clk => clk,

    in_flit  => mpsoc_noc_in_flit,
    in_last  => mpsoc_noc_in_last,
    in_valid => mpsoc_noc_in_valid,
    in_ready => mpsoc_noc_in_ready,

    out_flit  => mpsoc_noc_out_flit,
    out_last  => mpsoc_noc_out_last,
    out_valid => mpsoc_noc_out_valid,
    out_ready => mpsoc_noc_out_ready
  );
end RTL;
