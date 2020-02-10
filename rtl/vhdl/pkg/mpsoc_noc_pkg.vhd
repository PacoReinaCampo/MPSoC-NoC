-- Converted from pkg/mpsoc_noc_pkg.sv
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

package mpsoc_noc_pkg is

  --////////////////////////////////////////////////////////////////
  --
  -- Constants
  --
  constant FLIT_WIDTH : integer := 34;
  constant NODES      : integer := 8;
  constant CHANNELS   : integer := 7;
  constant PCHANNELS  : integer := 1;
  constant VCHANNELS  : integer := 7;
  constant OUTPUTS    : integer := 7;

  --////////////////////////////////////////////////////////////////
  --
  -- Types
  --
  type M_PCHANNELS_FLIT_WIDTH is array (PCHANNELS-1 downto 0) of std_logic_vector(FLIT_WIDTH-1 downto 0);
  type M_PCHANNELS_PCHANNELS is array (PCHANNELS-1 downto 0) of std_logic_vector(PCHANNELS-1 downto 0);
  type M_PCHANNELS_VCHANNELS is array (PCHANNELS-1 downto 0) of std_logic_vector(VCHANNELS-1 downto 0);
  type M_PCHANNELS_CHANNELS is array (PCHANNELS-1 downto 0) of std_logic_vector(CHANNELS-1 downto 0);
  type M_PCHANNELS_OUTPUTS is array (PCHANNELS-1 downto 0) of std_logic_vector(OUTPUTS-1 downto 0);

  type M_VCHANNELS_FLIT_WIDTH is array (VCHANNELS-1 downto 0) of std_logic_vector(FLIT_WIDTH-1 downto 0);
  type M_VCHANNELS_PCHANNELS is array (VCHANNELS-1 downto 0) of std_logic_vector(PCHANNELS-1 downto 0);
  type M_VCHANNELS_VCHANNELS is array (VCHANNELS-1 downto 0) of std_logic_vector(VCHANNELS-1 downto 0);
  type M_VCHANNELS_CHANNELS is array (VCHANNELS-1 downto 0) of std_logic_vector(CHANNELS-1 downto 0);
  type M_VCHANNELS_OUTPUTS is array (VCHANNELS-1 downto 0) of std_logic_vector(OUTPUTS-1 downto 0);

  type M_CHANNELS_FLIT_WIDTH is array (CHANNELS-1 downto 0) of std_logic_vector(FLIT_WIDTH-1 downto 0);
  type M_CHANNELS_PCHANNELS is array (CHANNELS-1 downto 0) of std_logic_vector(PCHANNELS-1 downto 0);
  type M_CHANNELS_VCHANNELS is array (CHANNELS-1 downto 0) of std_logic_vector(VCHANNELS-1 downto 0);
  type M_CHANNELS_CHANNELS is array (CHANNELS-1 downto 0) of std_logic_vector(CHANNELS-1 downto 0);
  type M_CHANNELS_OUTPUTS is array (CHANNELS-1 downto 0) of std_logic_vector(OUTPUTS-1 downto 0);

  type M_OUTPUTS_FLIT_WIDTH is array (OUTPUTS-1 downto 0) of std_logic_vector(FLIT_WIDTH-1 downto 0);
  type M_OUTPUTS_PCHANNELS is array (OUTPUTS-1 downto 0) of std_logic_vector(PCHANNELS-1 downto 0);
  type M_OUTPUTS_VCHANNELS is array (OUTPUTS-1 downto 0) of std_logic_vector(VCHANNELS-1 downto 0);
  type M_OUTPUTS_CHANNELS is array (OUTPUTS-1 downto 0) of std_logic_vector(CHANNELS-1 downto 0);
  type M_OUTPUTS_OUTPUTS is array (OUTPUTS-1 downto 0) of std_logic_vector(OUTPUTS-1 downto 0);

  type M_NODES_FLIT_WIDTH is array (NODES-1 downto 0) of std_logic_vector(FLIT_WIDTH-1 downto 0);
  type M_NODES_PCHANNELS is array (NODES-1 downto 0) of std_logic_vector(PCHANNELS-1 downto 0);
  type M_NODES_VCHANNELS is array (NODES-1 downto 0) of std_logic_vector(VCHANNELS-1 downto 0);
  type M_NODES_CHANNELS is array (NODES-1 downto 0) of std_logic_vector(CHANNELS-1 downto 0);
  type M_NODES_OUTPUTS is array (NODES-1 downto 0) of std_logic_vector(OUTPUTS-1 downto 0);

  type M_VCHANNELS_CHANNELS_FLIT_WIDTH is array (VCHANNELS-1 downto 0) of M_CHANNELS_FLIT_WIDTH;
  type M_VCHANNELS_CHANNELS_PCHANNELS is array (VCHANNELS-1 downto 0) of M_CHANNELS_PCHANNELS;
  type M_VCHANNELS_CHANNELS_VCHANNELS is array (VCHANNELS-1 downto 0) of M_CHANNELS_VCHANNELS;
  type M_VCHANNELS_CHANNELS_CHANNELS is array (VCHANNELS-1 downto 0) of M_CHANNELS_CHANNELS;
  type M_VCHANNELS_CHANNELS_OUTPUTS is array (VCHANNELS-1 downto 0) of M_CHANNELS_OUTPUTS;

  type M_CHANNELS_PCHANNELS_FLIT_WIDTH is array (CHANNELS-1 downto 0) of M_PCHANNELS_FLIT_WIDTH;
  type M_CHANNELS_PCHANNELS_PCHANNELS is array (CHANNELS-1 downto 0) of M_PCHANNELS_PCHANNELS;
  type M_CHANNELS_PCHANNELS_VCHANNELS is array (CHANNELS-1 downto 0) of M_PCHANNELS_VCHANNELS;
  type M_CHANNELS_PCHANNELS_CHANNELS is array (CHANNELS-1 downto 0) of M_PCHANNELS_CHANNELS;
  type M_CHANNELS_PCHANNELS_OUTPUTS is array (CHANNELS-1 downto 0) of M_PCHANNELS_OUTPUTS;

  type M_CHANNELS_VCHANNELS_FLIT_WIDTH is array (CHANNELS-1 downto 0) of M_VCHANNELS_FLIT_WIDTH;
  type M_CHANNELS_VCHANNELS_PCHANNELS is array (CHANNELS-1 downto 0) of M_VCHANNELS_PCHANNELS;
  type M_CHANNELS_VCHANNELS_VCHANNELS is array (CHANNELS-1 downto 0) of M_VCHANNELS_VCHANNELS;
  type M_CHANNELS_VCHANNELS_CHANNELS is array (CHANNELS-1 downto 0) of M_VCHANNELS_CHANNELS;
  type M_CHANNELS_VCHANNELS_OUTPUTS is array (CHANNELS-1 downto 0) of M_VCHANNELS_OUTPUTS;

  type M_OUTPUTS_PCHANNELS_FLIT_WIDTH is array (OUTPUTS-1 downto 0) of M_PCHANNELS_FLIT_WIDTH;
  type M_OUTPUTS_PCHANNELS_PCHANNELS is array (OUTPUTS-1 downto 0) of M_PCHANNELS_PCHANNELS;
  type M_OUTPUTS_PCHANNELS_VCHANNELS is array (OUTPUTS-1 downto 0) of M_PCHANNELS_VCHANNELS;
  type M_OUTPUTS_PCHANNELS_CHANNELS is array (OUTPUTS-1 downto 0) of M_PCHANNELS_CHANNELS;
  type M_OUTPUTS_PCHANNELS_OUTPUTS is array (OUTPUTS-1 downto 0) of M_PCHANNELS_OUTPUTS;

  type M_OUTPUTS_VCHANNELS_FLIT_WIDTH is array (OUTPUTS-1 downto 0) of M_VCHANNELS_FLIT_WIDTH;
  type M_OUTPUTS_VCHANNELS_PCHANNELS is array (OUTPUTS-1 downto 0) of M_VCHANNELS_PCHANNELS;
  type M_OUTPUTS_VCHANNELS_VCHANNELS is array (OUTPUTS-1 downto 0) of M_VCHANNELS_VCHANNELS;
  type M_OUTPUTS_VCHANNELS_CHANNELS is array (OUTPUTS-1 downto 0) of M_VCHANNELS_CHANNELS;
  type M_OUTPUTS_VCHANNELS_OUTPUTS is array (OUTPUTS-1 downto 0) of M_VCHANNELS_OUTPUTS;

  type M_NODES_CHANNELS_FLIT_WIDTH is array (NODES-1 downto 0) of M_CHANNELS_FLIT_WIDTH;
  type M_NODES_CHANNELS_PCHANNELS is array (NODES-1 downto 0) of M_CHANNELS_PCHANNELS;
  type M_NODES_CHANNELS_VCHANNELS is array (NODES-1 downto 0) of M_CHANNELS_VCHANNELS;
  type M_NODES_CHANNELS_CHANNELS is array (NODES-1 downto 0) of M_CHANNELS_CHANNELS;
  type M_NODES_CHANNELS_OUTPUTS is array (NODES-1 downto 0) of M_CHANNELS_OUTPUTS;

  type M_NODES_OUTPUTS_FLIT_WIDTH is array (NODES-1 downto 0) of M_OUTPUTS_FLIT_WIDTH;
  type M_NODES_OUTPUTS_PCHANNELS is array (NODES-1 downto 0) of M_OUTPUTS_PCHANNELS;
  type M_NODES_OUTPUTS_VCHANNELS is array (NODES-1 downto 0) of M_OUTPUTS_VCHANNELS;
  type M_NODES_OUTPUTS_CHANNELS is array (NODES-1 downto 0) of M_OUTPUTS_CHANNELS;
  type M_NODES_OUTPUTS_OUTPUTS is array (NODES-1 downto 0) of M_OUTPUTS_OUTPUTS;

  type M_NODES_CHANNELS_PCHANNELS_FLIT_WIDTH is array (NODES-1 downto 0) of M_CHANNELS_PCHANNELS_FLIT_WIDTH;

  type M_NODES_OUTPUTS_PCHANNELS_FLIT_WIDTH is array (NODES-1 downto 0) of M_OUTPUTS_PCHANNELS_FLIT_WIDTH;

  type M_OUTPUTS_VCHANNELS_CHANNELS_FLIT_WIDTH is array (OUTPUTS-1 downto 0) of M_VCHANNELS_CHANNELS_FLIT_WIDTH;


end mpsoc_noc_pkg;
