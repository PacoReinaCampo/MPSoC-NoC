-- Converted from rtl/verilog/router/riscv_noc_router.sv
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
--              Router Top                                                    //
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

entity riscv_noc_router is
  generic (
    PLEN : integer := 64;
    INPUTS : integer := 7;
    OUTPUTS : integer := 7;
    VCHANNELS : integer := 2;

    ROUTES : std_ulogic_vector(8*7-1 downto 0) := (others => '0')
  );
  port (
    clk, rst : in std_ulogic;

    out_flit  : out M_OUTPUTS_PLEN;
    out_last  : out std_ulogic_vector(OUTPUTS-1 downto 0);
    out_valid : out M_OUTPUTS_VCHANNELS;
    out_ready : in  M_OUTPUTS_VCHANNELS;

    in_flit  : in  M_INPUTS_PLEN;
    in_last  : in  std_ulogic_vector(INPUTS-1 downto 0);
    in_valid : in  M_INPUTS_VCHANNELS;
    in_ready : out M_INPUTS_VCHANNELS
  );
end riscv_noc_router;

architecture RTL of riscv_noc_router is
  component riscv_noc_router_input
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
  end component;

  component riscv_noc_router_output
    generic (
      PLEN      : integer := 64;
      INPUTS    : integer := 7;
      VCHANNELS : integer := 2;

      BUFFER_DEPTH : integer := 4
    );
    port (
      clk : in std_ulogic;
      rst : in std_ulogic;

      in_flit  : in  M_VCHANNELS_INPUTS_PLEN;
      in_last  : in  M_VCHANNELS_INPUTS;
      in_valid : in  M_VCHANNELS_INPUTS;
      in_ready : out M_VCHANNELS_INPUTS;

      out_flit  : out std_ulogic_vector(PLEN-1 downto 0);
      out_last  : out std_ulogic;
      out_valid : out std_ulogic_vector(VCHANNELS-1 downto 0);
      out_ready : in  std_ulogic_vector(VCHANNELS-1 downto 0)
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
  signal switch_in_flit  : M_INPUTS_VCHANNELS_PLEN;
  signal switch_in_last  : M_INPUTS_VCHANNELS;
  signal switch_in_valid : M_INPUTS_VCHANNELS_OUTPUTS;
  signal switch_in_ready : M_INPUTS_VCHANNELS_OUTPUTS;

  -- Outputs are fully wired to receive all input requests.
  signal switch_out_flit  : M_OUTPUTS_VCHANNELS_INPUTS_PLEN;
  signal switch_out_last  : M_OUTPUTS_VCHANNELS_INPUTS;
  signal switch_out_valid : M_OUTPUTS_VCHANNELS_INPUTS;
  signal switch_out_ready : M_OUTPUTS_VCHANNELS_INPUTS;

begin
--////////////////////////////////////////////////////////////////
--
-- Module Body
--
  generating_0 : for i in 0 to INPUTS - 1 generate
    -- The input stages
    noc_router_input : riscv_noc_router_input
      generic map (
        PLEN         => PLEN,
        OUTPUTS      => OUTPUTS,
        VCHANNELS    => VCHANNELS,
        BUFFER_DEPTH => BUFFER_SIZE_IN,
        ROUTES       => ROUTES
      )
      port map (
        clk => clk,
        rst => rst,

        in_flit  => in_flit(i),
        in_last  => in_last(i),
        in_valid => in_valid(i),
        in_ready => in_ready(i),

        out_flit  => switch_in_flit(i),
        out_last  => switch_in_last(i),
        out_valid => switch_in_valid(i),
        out_ready => switch_in_ready(i)
      );
  end generate;
  -- block: inputs

  -- The switching logic
  generating_1 : for o in 0 to OUTPUTS - 1 generate
    generating_2 : for v in 0 to VCHANNELS - 1 generate
      generating_3 : for i in 0 to INPUTS - 1 generate
        switch_out_flit(o)(v)(i)  <= switch_in_flit(i)(v);
        switch_out_last(o)(v)(i)  <= switch_in_last(i)(v);
        switch_out_valid(o)(v)(i) <= switch_in_valid(i)(v)(o);
        switch_in_ready(i)(v)(o)  <= switch_out_ready(o)(v)(i);
      end generate;
    end generate;
  end generate;

  generating_4 : for o in 0 to OUTPUTS - 1 generate
    -- The output stages
    noc_router_output : riscv_noc_router_output
      generic map (
        BUFFER_DEPTH => BUFFER_SIZE_OUT
      )
      port map (
        clk => clk,
        rst => rst,

        in_flit  => switch_out_flit(o),
        in_last  => switch_out_last(o),
        in_valid => switch_out_valid(o),
        in_ready => switch_out_ready(o),

        out_flit  => out_flit(o),
        out_last  => out_last(o),
        out_valid => out_valid(o),
        out_ready => out_ready(o)
      );
  end generate;
end RTL;
