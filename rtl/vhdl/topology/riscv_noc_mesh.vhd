-- Converted from rtl/verilog/topology/riscv_noc_mesh.sv
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
--              Network on Chip Top                                           //
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

entity riscv_noc_mesh is
  generic (
    PLEN      : integer := 64;
    NODES     : integer := 8;
    INPUTS    : integer := 7;
    OUTPUTS   : integer := 7;
    CHANNELS  : integer := 2;
    VCHANNELS : integer := 2
  );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    in_flit  : in  M_NODES_CHANNELS_PLEN;
    in_last  : in  M_NODES_CHANNELS;
    in_valid : in  M_NODES_CHANNELS;
    in_ready : out M_NODES_CHANNELS;

    out_flit  : out M_NODES_CHANNELS_PLEN;
    out_last  : out M_NODES_CHANNELS;
    out_valid : out M_NODES_CHANNELS;
    out_ready : in  M_NODES_CHANNELS
  );
end riscv_noc_mesh;

architecture RTL of riscv_noc_mesh is
  component riscv_noc_channel_mux
    generic (
      PLEN     : integer := 64;
      CHANNELS : integer := 2
    );
    port (
      clk : in std_ulogic;
      rst : in std_ulogic;

      in_flit  : in  M_CHANNELS_PLEN;
      in_last  : in  std_ulogic_vector(CHANNELS-1 downto 0);
      in_valid : in  std_ulogic_vector(CHANNELS-1 downto 0);
      in_ready : out std_ulogic_vector(CHANNELS-1 downto 0);

      out_flit  : out std_ulogic_vector(PLEN-1 downto 0);
      out_last  : out std_ulogic;
      out_valid : out std_ulogic_vector(CHANNELS-1 downto 0);
      out_ready : in  std_ulogic_vector(CHANNELS-1 downto 0)
    );
  end component;

  component riscv_noc_router
    generic (
      PLEN      : integer := 64;
      INPUTS    : integer := 7;
      OUTPUTS   : integer := 7;
      VCHANNELS : integer := 2;

      ROUTES : std_ulogic_vector(8*7-1 downto 0) := (others => '0')
    );
    port (
      clk : in std_ulogic;
      rst : in std_ulogic;

      out_flit  : out M_OUTPUTS_PLEN;
      out_last  : out std_ulogic_vector(OUTPUTS-1 downto 0);
      out_valid : out M_OUTPUTS_VCHANNELS;
      out_ready : in  M_OUTPUTS_VCHANNELS;

      in_flit  : in  M_INPUTS_PLEN;
      in_last  : in  std_ulogic_vector(INPUTS-1 downto 0);
      in_valid : in  M_INPUTS_VCHANNELS;
      in_ready : out M_INPUTS_VCHANNELS
    );
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Functions
  --

  -- Get the node number
  function nodenum (
    xd : integer;
    yd : integer;
    zd : integer
  ) return integer is
  begin
    return xd+yd*X+zd*X;
  end function nodenum;

  -- Get the node up of position
  function upof (
    xd : integer;
    yd : integer;
    zd : integer
  ) return integer is
  begin
    return xd+yd*X+(zd+1)*X;
  end function upof;

  -- Get the node north of position
  function northof (
    xd : integer;
    yd : integer;
    zd : integer
  ) return integer is
  begin
    return xd+(yd+1)*X+zd*X;
  end function northof;

  -- Get the node east of position
  function eastof (
    xd : integer;
    yd : integer;
    zd : integer
  ) return integer is
  begin
    return (xd+1)+yd*X+zd*X;
  end function eastof;

  -- Get the node down of position
  function downof (
    xd : integer;
    yd : integer;
    zd : integer
  ) return integer is
  begin
    return xd+yd*X+(zd-1)*X;
  end function downof;

  -- Get the node south of position
  function southof (
    xd : integer;
    yd : integer;
    zd : integer
  ) return integer is
  begin
    return xd+(yd-1)*X+zd*X;
  end function southof;

  -- Get the node west of position
  function westof (
    xd : integer;
    yd : integer;
    zd : integer
  ) return integer is
  begin
    return (xd-1)+yd*X+zd*X;
  end function westof;

  function genroutes (
    x : integer;
    y : integer;
    z : integer
  ) return std_ulogic_vector is
    variable xd               : integer;
    variable yd               : integer;
    variable zd               : integer;
    variable nd               : integer;
    variable d                : std_ulogic_vector(OUTPUTS-1 downto 0);
    variable genroutes_return : std_ulogic_vector(NODES*OUTPUTS-1 downto 0);
  begin
    for zd in 0 to Z - 1 loop
      for yd in 0 to Y - 1 loop
        for xd in 0 to X - 1 loop
          nd := nodenum(xd, yd, zd);
          d  := (others => '0');
          if ((xd = x) and (yd = y) and (zd = z)) then
            d := DIR_LOCAL;
          elsif ((xd = x) and (yd = z)) then
            if (zd < z) then
              d := DIR_DOWN;
            else
              d := DIR_UP;
            end if;
          elsif ((xd = x) and (zd = z)) then
            if (yd < y) then
              d := DIR_SOUTH;
            else
              d := DIR_NORTH;
            end if;
          elsif ((yd = y) and (zd = z)) then
            if (xd < x) then
              d := DIR_WEST;
            else
              d := DIR_EAST;
            end if;
          end if;
          genroutes_return((nd+1)*OUTPUTS-1 downto nd*OUTPUTS) := d;
        end loop;
      end loop;
    end loop;

    return genroutes_return;
  end genroutes;

  --////////////////////////////////////////////////////////////////
  --
  -- Constants
  --

  -- Number of physical channels between routers. This is essentially
  -- the number of flits (and last) between the routers.
  constant PCHANNELS : integer := 1;

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --

  -- Arrays of wires between the routers. Each router has a
  -- pair of NoC wires per direction and below those are hooked
  -- up.
  signal node_in_flit  : M_NODES_INPUTS_PCHANNELS_PLEN;
  signal node_in_last  : M_NODES_INPUTS_PCHANNELS;
  signal node_in_valid : M_NODES_INPUTS_CHANNELS;
  signal node_in_ready : M_NODES_INPUTS_CHANNELS;

  signal node_r_in_flit  : M_NODES_INPUTS_PCHANNELS_PLEN;
  signal node_r_in_last  : M_NODES_INPUTS_PCHANNELS;
  signal node_r_in_valid : M_NODES_INPUTS_CHANNELS;
  signal node_r_in_ready : M_NODES_INPUTS_CHANNELS;

  signal node_out_flit  : M_NODES_OUTPUTS_PCHANNELS_PLEN;
  signal node_out_last  : M_NODES_OUTPUTS_PCHANNELS;
  signal node_out_valid : M_NODES_OUTPUTS_CHANNELS;
  signal node_out_ready : M_NODES_OUTPUTS_CHANNELS;

  signal node_r_out_flit  : M_NODES_OUTPUTS_PCHANNELS_PLEN;
  signal node_r_out_last  : M_NODES_OUTPUTS_PCHANNELS;
  signal node_r_out_valid : M_NODES_OUTPUTS_CHANNELS;
  signal node_r_out_ready : M_NODES_OUTPUTS_CHANNELS;

  -- First we just need to re-arrange the wires a bit
  -- because the array structure varies a bit here:
  -- The directions and channels and differently
  -- multiplexed here. Hence create some helper
  -- arrays.
  signal phys_in_flit  : M_INPUTS_PLEN;
  signal phys_in_last  : std_ulogic_vector(INPUTS-1 downto 0);
  signal phys_in_valid : M_INPUTS_VCHANNELS;
  signal phys_in_ready : M_INPUTS_VCHANNELS;

  signal phys_out_flit  : M_OUTPUTS_PLEN;
  signal phys_out_last  : std_ulogic_vector(OUTPUTS-1 downto 0);
  signal phys_out_valid : M_OUTPUTS_VCHANNELS;
  signal phys_out_ready : M_OUTPUTS_VCHANNELS;

  signal router_out_flit  : M_OUTPUTS_PLEN;
  signal router_out_last  : std_ulogic_vector(OUTPUTS-1 downto 0);
  signal router_out_valid : M_OUTPUTS_VCHANNELS;
  signal router_out_ready : M_OUTPUTS_VCHANNELS;

  signal router_in_flit  : M_INPUTS_PLEN;
  signal router_in_last  : std_ulogic_vector(INPUTS-1 downto 0);
  signal router_in_valid : M_INPUTS_VCHANNELS;
  signal router_in_ready : M_INPUTS_VCHANNELS;

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  -- With virtual channels, we generate one router per node and
  -- then add a virtual channel muxer between the tiles and the
  -- local router input. On the output the "demux" is plain
  -- wiring.

  -- Instantiate the router. We call a function to
  -- generate the routing table
  noc_router : riscv_noc_router
    generic map (
      PLEN      => PLEN,
      INPUTS    => INPUTS,
      OUTPUTS   => OUTPUTS,
      VCHANNELS => VCHANNELS,

      ROUTES => (others => '0')
    )
    port map (
      clk => clk,
      rst => rst,

      in_flit  => router_in_flit,
      in_last  => router_in_last,
      in_valid => router_in_valid,
      in_ready => router_in_ready,

      out_flit  => router_out_flit,
      out_last  => router_out_last,
      out_valid => router_out_valid,
      out_ready => router_out_ready
    );

  --node_r_in_flit  <= node_in_flit;
  --node_r_in_last  <= node_in_last;
  --node_r_in_valid <= node_in_valid;
  node_in_ready <= node_r_in_ready;

  node_out_flit  <= node_r_out_flit;
  node_out_last  <= node_r_out_last;
  node_out_valid <= node_r_out_valid;
  --node_out_ready <= node_r_out_ready;

  generating_0 : for zd in 0 to Z - 1 generate
    generating_1 : for yd in 0 to Y - 1 generate
      generating_2 : for xd in 0 to X - 1 generate
        generating_3 : if (ENABLE_VCHANNELS = 1) generate
          -- Mux inputs to virtual channels
          --noc_channel_mux : riscv_noc_channel_mux
            --generic map (
              --PLEN     => PLEN,
              --CHANNELS => CHANNELS
            --)
            --port map (
              --clk => clk,
              --rst => rst,

              --in_flit  => in_flit(nodenum(xd, yd, zd)),
              --in_last  => in_last(nodenum(xd, yd, zd)),
              --in_valid => in_valid(nodenum(xd, yd, zd)),
              --in_ready => in_ready(nodenum(xd, yd, zd)),

              --out_flit  => node_in_flit(nodenum(xd, yd, zd))(LOCAL)(0),
              --out_last  => node_in_last(nodenum(xd, yd, zd))(LOCAL)(0),
              --out_valid => node_in_valid(nodenum(xd, yd, zd))(LOCAL),
              --out_ready => node_in_ready(nodenum(xd, yd, zd))(LOCAL)
            --);

          -- Replicate the flit to all output channels and the
          -- rest is just wiring
          generating_4 : for c in 0 to CHANNELS - 1 generate
            out_flit(nodenum(xd, yd, zd))(c) <= node_out_flit(nodenum(xd, yd, zd))(LOCAL)(c);
            out_last(nodenum(xd, yd, zd))(c) <= node_out_last(nodenum(xd, yd, zd))(LOCAL)(c);
          end generate;

          out_valid(nodenum(xd, yd, zd))             <= node_out_valid(nodenum(xd, yd, zd))(LOCAL);
          node_out_ready(nodenum(xd, yd, zd))(LOCAL) <= out_ready(nodenum(xd, yd, zd));

          generating_5 : for i in 0 to INPUTS - 1 generate
            generating_6 : for c in 0 to CHANNELS - 1 generate
              node_r_in_flit(nodenum(xd, yd, zd))(i)(c) <= router_in_flit(i);
              node_r_in_last(nodenum(xd, yd, zd))(i)(c) <= router_in_last(i);

              node_r_in_valid(nodenum(xd, yd, zd))(i)(c) <= router_in_valid(i)(c);
              node_r_in_ready(nodenum(xd, yd, zd))(i)(c) <= router_in_ready(i)(c);
            end generate;
          end generate;

          generating_7 : for o in 0 to OUTPUTS - 1 generate
            generating_8 : for c in 0 to CHANNELS - 1 generate
              node_r_out_flit(nodenum(xd, yd, zd))(o)(c) <= router_out_flit(o);
              node_r_out_last(nodenum(xd, yd, zd))(o)(c) <= router_out_last(o);

              node_r_out_valid(nodenum(xd, yd, zd))(o)(c) <= router_out_valid(o)(c);
              node_r_out_ready(nodenum(xd, yd, zd))(o)(c) <= router_out_ready(o)(c);
            end generate;
          end generate;
        end generate;

        generating_9 : if (ENABLE_VCHANNELS = 0) generate
          generating_10 : for c in 0 to CHANNELS - 1 generate
            out_flit(nodenum(xd, yd, zd))(c) <= node_out_flit(nodenum(xd, yd, zd))(LOCAL)(c);
            out_last(nodenum(xd, yd, zd))(c) <= node_out_last(nodenum(xd, yd, zd))(LOCAL)(c);
            out_valid(nodenum(xd, yd, zd))   <= node_out_valid(nodenum(xd, yd, zd))(LOCAL);

            node_out_ready(nodenum(xd, yd, zd))(LOCAL) <= out_ready(nodenum(xd, yd, zd));

            node_in_flit(nodenum(xd, yd, zd))(LOCAL)(c) <= in_flit(nodenum(xd, yd, zd))(c);
            node_in_last(nodenum(xd, yd, zd))(LOCAL)(c) <= in_last(nodenum(xd, yd, zd))(c);
            node_in_valid(nodenum(xd, yd, zd))(LOCAL)   <= in_valid(nodenum(xd, yd, zd));

            in_ready(nodenum(xd, yd, zd)) <= node_in_ready(nodenum(xd, yd, zd))(LOCAL);

            -- Re-wire the ports
            generating_11 : for i in 0 to INPUTS - 1 generate
              phys_in_flit(i)  <= node_in_flit(nodenum(xd, yd, zd))(i)(0);
              phys_in_last(i)  <= node_in_last(nodenum(xd, yd, zd))(i)(0);
              phys_in_valid(i) <= node_in_valid(nodenum(xd, yd, zd))(i);

              node_in_ready(nodenum(xd, yd, zd))(i) <= phys_in_ready(i);
            end generate;

            generating_12 : for o in 0 to OUTPUTS - 1 generate
              node_out_flit(nodenum(xd, yd, zd))(o)(c) <= phys_out_flit(o);
              node_out_last(nodenum(xd, yd, zd))(o)(c) <= phys_out_last(o);
              node_out_valid(nodenum(xd, yd, zd))(o)   <= phys_out_valid(o);

              phys_out_ready(o) <= node_out_ready(nodenum(xd, yd, zd))(o);
            end generate;

            -- Instantiate the router. We call a function to
            -- generate the routing table
            noc_router : riscv_noc_router
              generic map (
                PLEN      => PLEN,
                INPUTS    => INPUTS,
                OUTPUTS   => OUTPUTS,
                VCHANNELS => VCHANNELS,

                ROUTES => genroutes(xd, yd, zd)
              )
              port map (
                clk => clk,
                rst => rst,

                in_flit  => phys_in_flit,
                in_last  => phys_in_last,
                in_valid => phys_in_valid,
                in_ready => phys_in_ready,

                out_flit  => phys_out_flit,
                out_last  => phys_out_last,
                out_valid => phys_out_valid,
                out_ready => phys_out_ready
              );
          end generate;
        end generate;

        -- The following are all the connections of the routers
        -- in the four directions. If the router is on an outer
        -- border, tie off.
        generating_13 : if (zd > 0) generate
          node_in_flit(nodenum(xd, yd, zd))(DOWN)   <= node_out_flit(nodenum(xd, yd, zd))(UP);
          node_in_last(nodenum(xd, yd, zd))(DOWN)   <= node_out_last(nodenum(xd, yd, zd))(UP);
          node_in_valid(nodenum(xd, yd, zd))(DOWN)  <= node_out_valid(nodenum(xd, yd, zd))(UP);
          node_out_ready(nodenum(xd, yd, zd))(DOWN) <= node_in_ready(nodenum(xd, yd, zd))(UP);
        end generate;
        generating_14 : if (zd <= 0) generate
          node_in_flit(nodenum(xd, yd, zd))(DOWN)   <= (others => (others => 'X'));
          node_in_last(nodenum(xd, yd, zd))(DOWN)   <= (others => 'X');
          node_in_valid(nodenum(xd, yd, zd))(DOWN)  <= (others => '0');
          node_out_ready(nodenum(xd, yd, zd))(DOWN) <= (others => '0');
        end generate;
        generating_15 : if (zd < Z-1) generate
          node_in_flit(nodenum(xd, yd, zd))(UP)   <= node_out_flit(nodenum(xd, yd, zd))(DOWN);
          node_in_last(nodenum(xd, yd, zd))(UP)   <= node_out_last(nodenum(xd, yd, zd))(DOWN);
          node_in_valid(nodenum(xd, yd, zd))(UP)  <= node_out_valid(nodenum(xd, yd, zd))(DOWN);
          node_out_ready(nodenum(xd, yd, zd))(UP) <= node_in_ready(nodenum(xd, yd, zd))(DOWN);
        end generate;
        generating_16 : if (zd >= Z-1) generate
          node_in_flit(nodenum(xd, yd, zd))(UP)   <= (others => (others => 'X'));
          node_in_last(nodenum(xd, yd, zd))(UP)   <= (others => 'X');
          node_in_valid(nodenum(xd, yd, zd))(UP)  <= (others => '0');
          node_out_ready(nodenum(xd, yd, zd))(UP) <= (others => '0');
        end generate;
        generating_17 : if (yd > 0) generate
          node_in_flit(nodenum(xd, yd, zd))(SOUTH)   <= node_out_flit(nodenum(xd, yd, zd))(NORTH);
          node_in_last(nodenum(xd, yd, zd))(SOUTH)   <= node_out_last(nodenum(xd, yd, zd))(NORTH);
          node_in_valid(nodenum(xd, yd, zd))(SOUTH)  <= node_out_valid(nodenum(xd, yd, zd))(NORTH);
          node_out_ready(nodenum(xd, yd, zd))(SOUTH) <= node_in_ready(nodenum(xd, yd, zd))(NORTH);
        end generate;
        generating_18 : if (yd <= 0) generate
          node_in_flit(nodenum(xd, yd, zd))(SOUTH)   <= (others => (others => 'X'));
          node_in_last(nodenum(xd, yd, zd))(SOUTH)   <= (others => 'X');
          node_in_valid(nodenum(xd, yd, zd))(SOUTH)  <= (others => '0');
          node_out_ready(nodenum(xd, yd, zd))(SOUTH) <= (others => '0');
        end generate;
        generating_19 : if (yd < Y-1) generate
          node_in_flit(nodenum(xd, yd, zd))(NORTH)   <= node_out_flit(nodenum(xd, yd, zd))(SOUTH);
          node_in_last(nodenum(xd, yd, zd))(NORTH)   <= node_out_last(nodenum(xd, yd, zd))(SOUTH);
          node_in_valid(nodenum(xd, yd, zd))(NORTH)  <= node_out_valid(nodenum(xd, yd, zd))(SOUTH);
          node_out_ready(nodenum(xd, yd, zd))(NORTH) <= node_in_ready(nodenum(xd, yd, zd))(SOUTH);
        end generate;
        generating_20 : if (yd >= Y-1) generate
          node_in_flit(nodenum(xd, yd, zd))(NORTH)   <= (others => (others => 'X'));
          node_in_last(nodenum(xd, yd, zd))(NORTH)   <= (others => 'X');
          node_in_valid(nodenum(xd, yd, zd))(NORTH)  <= (others => '0');
          node_out_ready(nodenum(xd, yd, zd))(NORTH) <= (others => '0');
        end generate;
        generating_21 : if (xd > 0) generate
          node_in_flit(nodenum(xd, yd, zd))(WEST)   <= node_out_flit(nodenum(xd, yd, zd))(EAST);
          node_in_last(nodenum(xd, yd, zd))(WEST)   <= node_out_last(nodenum(xd, yd, zd))(EAST);
          node_in_valid(nodenum(xd, yd, zd))(WEST)  <= node_out_valid(nodenum(xd, yd, zd))(EAST);
          node_out_ready(nodenum(xd, yd, zd))(WEST) <= node_in_ready(nodenum(xd, yd, zd))(EAST);
        end generate;
        generating_22 : if (xd <= 0) generate
          node_in_flit(nodenum(xd, yd, zd))(WEST)   <= (others => (others => 'X'));
          node_in_last(nodenum(xd, yd, zd))(WEST)   <= (others => 'X');
          node_in_valid(nodenum(xd, yd, zd))(WEST)  <= (others => '0');
          node_out_ready(nodenum(xd, yd, zd))(WEST) <= (others => '0');
        end generate;
        generating_23 : if (xd < X-1) generate
          node_in_flit(nodenum(xd, yd, zd))(EAST)   <= node_out_flit(nodenum(xd, yd, zd))(WEST);
          node_in_last(nodenum(xd, yd, zd))(EAST)   <= node_out_last(nodenum(xd, yd, zd))(WEST);
          node_in_valid(nodenum(xd, yd, zd))(EAST)  <= node_out_valid(nodenum(xd, yd, zd))(WEST);
          node_out_ready(nodenum(xd, yd, zd))(EAST) <= node_in_ready(nodenum(xd, yd, zd))(WEST);
        end generate;
        generating_24 : if (xd >= X-1) generate
          node_in_flit(nodenum(xd, yd, zd))(EAST)   <= (others => (others => 'X'));
          node_in_last(nodenum(xd, yd, zd))(EAST)   <= (others => 'X');
          node_in_valid(nodenum(xd, yd, zd))(EAST)  <= (others => '0');
          node_out_ready(nodenum(xd, yd, zd))(EAST) <= (others => '0');
        end generate;
      end generate;
    end generate;
  end generate;
end RTL;
