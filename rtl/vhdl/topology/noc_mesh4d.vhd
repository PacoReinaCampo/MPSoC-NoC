-- Converted from rtl/verilog/topology/noc.sv
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
-- *   Francisco Javier Reina Campo <frareicam@gmail.com>
-- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mpsoc_noc_pkg.all;

entity noc_mesh4d is
  generic (
    FLIT_WIDTH : integer := 32;
    CHANNELS   : integer := 1;

    ENABLE_VCHANNELS : integer := 1;

    X : integer := 2;
    Y : integer := 2;
    Z : integer := 2;
    T : integer := 2;

    BUFFER_SIZE_IN  : integer := 4;
    BUFFER_SIZE_OUT : integer := 4;

    NODES : integer := 16
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
end noc_mesh4d;

architecture RTL of noc_mesh4d is
  component noc_vchannel_mux
    generic (
      FLIT_WIDTH : integer := 32;
      CHANNELS   : integer := 9
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

  component noc_router
    generic (
      FLIT_WIDTH      : integer := 32;
      VCHANNELS       : integer := 9;
      INPUTS          : integer := 9;
      OUTPUTS         : integer := 9;
      BUFFER_SIZE_IN  : integer := 4;
      BUFFER_SIZE_OUT : integer := 4;
      DESTS           : integer := 8
      );
    port (
      clk : in std_logic;
      rst : in std_logic;

      ROUTES : in std_logic_vector(OUTPUTS*DESTS-1 downto 0);

      out_flit  : out std_logic_matrix(OUTPUTS-1 downto 0)(FLIT_WIDTH-1 downto 0);
      out_last  : out std_logic_vector(OUTPUTS-1 downto 0);
      out_valid : out std_logic_matrix(OUTPUTS-1 downto 0)(VCHANNELS-1 downto 0);
      out_ready : in  std_logic_matrix(OUTPUTS-1 downto 0)(VCHANNELS-1 downto 0);

      in_flit  : in  std_logic_matrix(INPUTS-1 downto 0)(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic_vector(INPUTS-1 downto 0);
      in_valid : in  std_logic_matrix(INPUTS-1 downto 0)(VCHANNELS-1 downto 0);
      in_ready : out std_logic_matrix(INPUTS-1 downto 0)(VCHANNELS-1 downto 0)
      );
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Constants
  --

  -- Those are indexes into the wiring arrays
  constant LOCAL : integer := 0;
  constant FWARD : integer := 1;
  constant UP    : integer := 2;
  constant NORTH : integer := 3;
  constant EAST  : integer := 4;
  constant BWARD : integer := 5;
  constant DOWN  : integer := 6;
  constant SOUTH : integer := 7;
  constant WEST  : integer := 8;

  -- Those are direction codings that match the wiring indices
  -- above. The router is configured to use those to select the
  -- proper output port.
  constant DIR_LOCAL : std_logic_vector(6 downto 0) := "000000001";
  constant DIR_FWARD : std_logic_vector(6 downto 0) := "000000010";
  constant DIR_UP    : std_logic_vector(6 downto 0) := "000000100";
  constant DIR_NORTH : std_logic_vector(6 downto 0) := "000001000";
  constant DIR_EAST  : std_logic_vector(6 downto 0) := "000010000";
  constant DIR_BWARD : std_logic_vector(6 downto 0) := "000100000";
  constant DIR_DOWN  : std_logic_vector(6 downto 0) := "001000000";
  constant DIR_SOUTH : std_logic_vector(6 downto 0) := "010000000";
  constant DIR_WEST  : std_logic_vector(6 downto 0) := "100000000";

  -- Number of physical channels between routers. This is essentially
  -- the number of flits (and last) between the routers.
  constant PCHANNELS : integer := ternary(1, CHANNELS, ENABLE_VCHANNELS);

  --////////////////////////////////////////////////////////////////
  --
  -- Functions
  --

  -- Get the node number
  function nodenum (
    xd : integer;
    yd : integer;
    zd : integer;
    td : integer
    ) return integer is
  begin
    return xd+yd*X+zd*X*Y+td*X*Y*Z;
  end function nodenum;

  -- Get the node forward of position
  function fwardof (
    xd : integer;
    yd : integer;
    zd : integer;
    td : integer
    ) return integer is
  begin
    return xd+yd*X+zd*X*Y+(td+1)*X*Y*Z;
  end function fwardof;

  -- Get the node up of position
  function upof (
    xd : integer;
    yd : integer;
    zd : integer;
    td : integer
    ) return integer is
  begin
    return xd+yd*X+(zd+1)*X*Y+td*X*Y*Z;
  end function upof;

  -- Get the node north of position
  function northof (
    xd : integer;
    yd : integer;
    zd : integer;
    td : integer
    ) return integer is
  begin
    return xd+(yd+1)*X+zd*X*Y+td*X*Y*Z;
  end function northof;

  -- Get the node east of position
  function eastof (
    xd : integer;
    yd : integer;
    zd : integer;
    td : integer
    ) return integer is
  begin
    return (xd+1)+yd*X+zd*X*Y+td*X*Y*Z;
  end function eastof;

  -- Get the node backward of position
  function bwardof (
    xd : integer;
    yd : integer;
    zd : integer;
    td : integer
    ) return integer is
  begin
    return xd+yd*X+zd*X*Y+(td-1)*X*Y*Z;
  end function bwardof;

  -- Get the node down of position
  function downof (
    xd : integer;
    yd : integer;
    zd : integer;
    td : integer
    ) return integer is
  begin
    return xd+yd*X+(zd-1)*X*Y+td*X*Y*Z;
  end function downof;

  -- Get the node south of position
  function southof (
    xd : integer;
    yd : integer;
    zd : integer;
    td : integer
    ) return integer is
  begin
    return xd+(yd-1)*X+zd*X*Y+td*X*Y*Z;
  end function southof;

  -- Get the node west of position
  function westof (
    xd : integer;
    yd : integer;
    zd : integer;
    td : integer
    ) return integer is
  begin
    return (xd-1)+yd*X+zd*X*Y+td*X*Y*Z;
  end function westof;

  function genroutes (
    x : integer;
    y : integer;
    z : integer;
    t : integer
    ) return std_logic_vector is
    variable xd               : integer;
    variable yd               : integer;
    variable zd               : integer;
    variable nd               : integer;
    variable d                : std_logic_vector(OUTPUTS-1 downto 0);
    variable genroutes_return : std_logic_vector(NODES*9-1 downto 0);
  begin

    genroutes_return := (others => '0');

    for td in 0 to T - 1 loop
      for zd in 0 to Z - 1 loop
        for yd in 0 to Y - 1 loop
          for xd in 0 to X - 1 loop
            nd := nodenum(xd, yd, zd, td);
            d  := (others => '0');
            if ((xd = x) and (yd = y) and (zd = z) and (td = t)) then
              d := DIR_LOCAL;
            elsif ((xd = x) and (yd = z) and (zd = t)) then
              if (td < z) then
                d := DIR_DOWN;
              else
                d := DIR_UP;
              end if;
            elsif ((xd = x) and (yd = z) and (td = t)) then
              if (zd < z) then
                d := DIR_DOWN;
              else
                d := DIR_UP;
              end if;
            elsif ((xd = x) and (zd = z) and (td = t)) then
              if (yd < y) then
                d := DIR_SOUTH;
              else
                d := DIR_NORTH;
              end if;
            elsif ((yd = y) and (zd = z) and (td = t)) then
              if (xd < x) then
                d := DIR_WEST;
              else
                d := DIR_EAST;
              end if;
            end if;
            genroutes_return(OUTPUTS*(nd+1)-1 downto OUTPUTS*nd) := d;
          end loop;
        end loop;
      end loop;
    end loop;

    return genroutes_return;
  end genroutes;

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --

  -- Arrays of wires between the routers. Each router has a
  -- pair of NoC wires per direction and below those are hooked
  -- up.
  signal node_in_flit  : std_logic_4array(NODES-1 downto 0)(6 downto 0)(PCHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal node_in_last  : std_logic_3array(NODES-1 downto 0)(6 downto 0)(PCHANNELS-1 downto 0);
  signal node_in_valid : std_logic_3array(NODES-1 downto 0)(6 downto 0)(CHANNELS-1 downto 0);
  signal node_in_ready : std_logic_3array(NODES-1 downto 0)(6 downto 0)(CHANNELS-1 downto 0);

  signal node_out_flit  : std_logic_4array(NODES-1 downto 0)(6 downto 0)(PCHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal node_out_last  : std_logic_3array(NODES-1 downto 0)(6 downto 0)(PCHANNELS-1 downto 0);
  signal node_out_valid : std_logic_3array(NODES-1 downto 0)(6 downto 0)(CHANNELS-1 downto 0);
  signal node_out_ready : std_logic_3array(NODES-1 downto 0)(6 downto 0)(CHANNELS-1 downto 0);

  -- First we just need to re-arrange the wires a bit
  -- because the array structure varies a bit here:
  -- The directions and channels and differently
  -- multiplexed here. Hence create some helper
  -- arrays.
  signal phys_in_flit  : std_logic_4array(NODES-1 downto 0)(6 downto 0)(PCHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal phys_in_last  : std_logic_3array(NODES-1 downto 0)(6 downto 0)(PCHANNELS-1 downto 0);
  signal phys_in_valid : std_logic_3array(NODES-1 downto 0)(6 downto 0)(CHANNELS-1 downto 0);
  signal phys_in_ready : std_logic_3array(NODES-1 downto 0)(6 downto 0)(CHANNELS-1 downto 0);

  signal phys_out_flit  : std_logic_4array(NODES-1 downto 0)(6 downto 0)(PCHANNELS-1 downto 0)(FLIT_WIDTH-1 downto 0);
  signal phys_out_last  : std_logic_3array(NODES-1 downto 0)(6 downto 0)(PCHANNELS-1 downto 0);
  signal phys_out_valid : std_logic_3array(NODES-1 downto 0)(6 downto 0)(CHANNELS-1 downto 0);
  signal phys_out_ready : std_logic_3array(NODES-1 downto 0)(6 downto 0)(CHANNELS-1 downto 0);

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  -- With virtual channels, we generate one router per node and
  -- then add a virtual channel muxer between the tiles and the
  -- local router input. On the output the "demux" is plain
  -- wiring.

  generating_t : for td in 0 to T - 1 generate
    generating_z : for zd in 0 to Z - 1 generate
      generating_y : for yd in 0 to Y - 1 generate
        generating_x : for xd in 0 to X - 1 generate
          generating_ev : if (ENABLE_VCHANNELS = 1) generate
            -- Mux inputs to virtual channels
            vchannel_mux : noc_vchannel_mux
              generic map (
                FLIT_WIDTH => FLIT_WIDTH,
                CHANNELS   => CHANNELS
                )
              port map (
                clk => clk,
                rst => rst,

                in_flit  => in_flit (nodenum(xd, yd, zd, td)),
                in_last  => in_last (nodenum(xd, yd, zd, td)),
                in_valid => in_valid (nodenum(xd, yd, zd, td)),
                in_ready => in_ready (nodenum(xd, yd, zd, td)),

                out_flit  => node_in_flit (nodenum(xd, yd, zd, td))(LOCAL)(0),
                out_last  => node_in_last (nodenum(xd, yd, zd, td))(LOCAL)(0),
                out_valid => node_in_valid (nodenum(xd, yd, zd, td))(LOCAL),
                out_ready => node_in_ready (nodenum(xd, yd, zd, td))(LOCAL)
                );

            -- Replicate the flit to all output channels and the
            -- rest is just wiring
            generating_4 : for c in 0 to CHANNELS - 1 generate
              out_flit(nodenum(xd, yd, zd, td))(c) <= node_out_flit(nodenum(xd, yd, zd, td))(LOCAL)(0);
              out_last(nodenum(xd, yd, zd, td))(c) <= node_out_last(nodenum(xd, yd, zd, td))(LOCAL)(0);
            end generate;

            out_valid(nodenum(xd, yd, zd, td)) <= node_out_valid(nodenum(xd, yd, zd, td))(LOCAL);

            node_out_ready(nodenum(xd, yd, zd, td))(LOCAL) <= out_ready(nodenum(xd, yd, zd, td));

            -- Instantiate the router. We call a function to
            -- generate the routing table
            router : noc_router
              generic map (
                FLIT_WIDTH      => FLIT_WIDTH,
                VCHANNELS       => CHANNELS,
                INPUTS          => 9,
                OUTPUTS         => 9,
                BUFFER_SIZE_IN  => BUFFER_SIZE_IN,
                BUFFER_SIZE_OUT => BUFFER_SIZE_OUT,
                DESTS           => NODES
                )
              port map (
                clk => clk,
                rst => rst,

                ROUTES => genroutes(xd, yd, zd, td),

                in_flit  => (others => (others => '0')),
                in_last  => (others => '0'),
                in_valid => node_in_valid (nodenum(xd, yd, zd, td)),
                in_ready => node_in_ready (nodenum(xd, yd, zd, td)),

                out_flit  => open,
                out_last  => open,
                out_valid => node_out_valid (nodenum(xd, yd, zd, td)),
                out_ready => node_out_ready (nodenum(xd, yd, zd, td))
                );
          elsif (ENABLE_VCHANNELS = 0) generate
            out_flit (nodenum(xd, yd, zd, td))  <= node_out_flit (nodenum(xd, yd, zd, td))(LOCAL);
            out_last (nodenum(xd, yd, zd, td))  <= node_out_last (nodenum(xd, yd, zd, td))(LOCAL);
            out_valid (nodenum(xd, yd, zd, td)) <= node_out_valid (nodenum(xd, yd, zd, td))(LOCAL);

            node_out_ready(nodenum(xd, yd, zd, td))(LOCAL) <= out_ready(nodenum(xd, yd, zd, td));

            node_out_flit (nodenum(xd, yd, zd, td))(LOCAL) <= out_flit (nodenum(xd, yd, zd, td));
            node_out_last (nodenum(xd, yd, zd, td))(LOCAL) <= out_last (nodenum(xd, yd, zd, td));
            node_in_valid (nodenum(xd, yd, zd, td))(LOCAL) <= in_valid (nodenum(xd, yd, zd, td));

            in_ready(nodenum(xd, yd, zd, td)) <= node_in_ready(nodenum(xd, yd, zd, td))(LOCAL);

            generating_5 : for c in 0 to CHANNELS - 1 generate
              -- First we just need to re-arrange the wires a bit
              -- because the array structure varies a bit here:
              -- The directions and channels and differently
              -- multiplexed here. Hence create some helper
              -- arrays.

              -- Re-wire the ports
              generating_6 : for p in 0 to 6 generate
                phys_in_flit (nodenum(xd, yd, zd, td))(p)(c)  <= node_in_flit (nodenum(xd, yd, zd, td))(p)(c);
                phys_in_last (nodenum(xd, yd, zd, td))(p)(c)  <= node_in_last (nodenum(xd, yd, zd, td))(p)(c);
                phys_in_valid (nodenum(xd, yd, zd, td))(p)(c) <= node_in_valid (nodenum(xd, yd, zd, td))(p)(c);

                node_in_ready (nodenum(xd, yd, zd, td))(p)(c) <= phys_in_ready (nodenum(xd, yd, zd, td))(p)(c);


                node_out_flit (nodenum(xd, yd, zd, td))(p)(c)  <= phys_out_flit (nodenum(xd, yd, zd, td))(p)(c);
                node_out_last (nodenum(xd, yd, zd, td))(p)(c)  <= phys_out_last (nodenum(xd, yd, zd, td))(p)(c);
                node_out_valid (nodenum(xd, yd, zd, td))(p)(c) <= phys_out_valid (nodenum(xd, yd, zd, td))(p)(c);

                phys_out_ready (nodenum(xd, yd, zd, td))(p)(c) <= node_out_ready (nodenum(xd, yd, zd, td))(p)(c);
              end generate;

              -- Instantiate the router. We call a function to
              -- generate the routing table
              router : noc_router
                generic map (
                  FLIT_WIDTH      => FLIT_WIDTH,
                  VCHANNELS       => 1,
                  INPUTS          => 9,
                  OUTPUTS         => 9,
                  BUFFER_SIZE_IN  => BUFFER_SIZE_IN,
                  BUFFER_SIZE_OUT => BUFFER_SIZE_OUT,
                  DESTS           => NODES
                  )
                port map (
                  clk => clk,
                  rst => rst,

                  ROUTES => genroutes(xd, yd, zd, td),

                  in_flit  => (others => (others => '0')),
                  in_last  => (others => '0'),
                  in_valid => phys_in_valid (nodenum(xd, yd, zd, td)),
                  in_ready => phys_in_ready (nodenum(xd, yd, zd, td)),

                  out_flit  => open,
                  out_last  => open,
                  out_valid => phys_out_valid (nodenum(xd, yd, zd, td)),
                  out_ready => phys_out_ready (nodenum(xd, yd, zd, td))
                  );
            end generate;
          end generate;

          -- The following are all the connections of the routers
          -- in the four directions. If the router is on an outer
          -- border, tie off.
          generating_11 : if (td > 0) generate
            node_in_flit (nodenum(xd, yd, zd, td))(BWARD)   <= node_out_flit (bwardof(xd, yd, zd, td))(FWARD);
            node_in_last (nodenum(xd, yd, zd, td))(BWARD)   <= node_out_last (bwardof(xd, yd, zd, td))(FWARD);
            node_in_valid (nodenum(xd, yd, zd, td))(BWARD)  <= node_out_valid (bwardof(xd, yd, zd, td))(FWARD);
            node_out_ready (nodenum(xd, yd, zd, td))(BWARD) <= node_in_ready (bwardof(xd, yd, zd, td))(FWARD);
          elsif (td <= 0) generate
            node_in_flit (nodenum(xd, yd, zd, td))(BWARD)   <= (others => (others => 'X'));
            node_in_last (nodenum(xd, yd, zd, td))(BWARD)   <= (others => 'X');
            node_in_valid (nodenum(xd, yd, zd, td))(BWARD)  <= (others => '0');
            node_out_ready (nodenum(xd, yd, zd, td))(BWARD) <= (others => '0');
          end generate;
          generating_12 : if (td < T-1) generate
            node_in_flit (nodenum(xd, yd, zd, td))(FWARD)   <= node_out_flit (fwardof(xd, yd, zd, td))(BWARD);
            node_in_last (nodenum(xd, yd, zd, td))(FWARD)   <= node_out_last (fwardof(xd, yd, zd, td))(BWARD);
            node_in_valid (nodenum(xd, yd, zd, td))(FWARD)  <= node_out_valid (fwardof(xd, yd, zd, td))(BWARD);
            node_out_ready (nodenum(xd, yd, zd, td))(FWARD) <= node_in_ready (fwardof(xd, yd, zd, td))(BWARD);
          elsif (td >= T-1) generate
            node_in_flit (nodenum(xd, yd, zd, td))(FWARD)   <= (others => (others => 'X'));
            node_in_last (nodenum(xd, yd, zd, td))(FWARD)   <= (others => 'X');
            node_in_valid (nodenum(xd, yd, zd, td))(FWARD)  <= (others => '0');
            node_out_ready (nodenum(xd, yd, zd, td))(FWARD) <= (others => '0');
          end generate;
          generating_13 : if (zd > 0) generate
            node_in_flit (nodenum(xd, yd, zd, td))(DOWN)   <= node_out_flit (downof(xd, yd, zd, td))(UP);
            node_in_last (nodenum(xd, yd, zd, td))(DOWN)   <= node_out_last (downof(xd, yd, zd, td))(UP);
            node_in_valid (nodenum(xd, yd, zd, td))(DOWN)  <= node_out_valid (downof(xd, yd, zd, td))(UP);
            node_out_ready (nodenum(xd, yd, zd, td))(DOWN) <= node_in_ready (downof(xd, yd, zd, td))(UP);
          elsif (zd <= 0) generate
            node_in_flit (nodenum(xd, yd, zd, td))(DOWN)   <= (others => (others => 'X'));
            node_in_last (nodenum(xd, yd, zd, td))(DOWN)   <= (others => 'X');
            node_in_valid (nodenum(xd, yd, zd, td))(DOWN)  <= (others => '0');
            node_out_ready (nodenum(xd, yd, zd, td))(DOWN) <= (others => '0');
          end generate;
          generating_14 : if (zd < Z-1) generate
            node_in_flit (nodenum(xd, yd, zd, td))(UP)   <= node_out_flit (upof(xd, yd, zd, td))(DOWN);
            node_in_last (nodenum(xd, yd, zd, td))(UP)   <= node_out_last (upof(xd, yd, zd, td))(DOWN);
            node_in_valid (nodenum(xd, yd, zd, td))(UP)  <= node_out_valid (upof(xd, yd, zd, td))(DOWN);
            node_out_ready (nodenum(xd, yd, zd, td))(UP) <= node_in_ready (upof(xd, yd, zd, td))(DOWN);
          elsif (zd >= Z-1) generate
            node_in_flit (nodenum(xd, yd, zd, td))(UP)   <= (others => (others => 'X'));
            node_in_last (nodenum(xd, yd, zd, td))(UP)   <= (others => 'X');
            node_in_valid (nodenum(xd, yd, zd, td))(UP)  <= (others => '0');
            node_out_ready (nodenum(xd, yd, zd, td))(UP) <= (others => '0');
          end generate;
          generating_15 : if (yd > 0) generate
            node_in_flit (nodenum(xd, yd, zd, td))(SOUTH)   <= node_out_flit (southof(xd, yd, zd, td))(NORTH);
            node_in_last (nodenum(xd, yd, zd, td))(SOUTH)   <= node_out_last (southof(xd, yd, zd, td))(NORTH);
            node_in_valid (nodenum(xd, yd, zd, td))(SOUTH)  <= node_out_valid (southof(xd, yd, zd, td))(NORTH);
            node_out_ready (nodenum(xd, yd, zd, td))(SOUTH) <= node_in_ready (southof(xd, yd, zd, td))(NORTH);
          elsif (yd <= 0) generate
            node_in_flit (nodenum(xd, yd, zd, td))(SOUTH)   <= (others => (others => 'X'));
            node_in_last (nodenum(xd, yd, zd, td))(SOUTH)   <= (others => 'X');
            node_in_valid (nodenum(xd, yd, zd, td))(SOUTH)  <= (others => '0');
            node_out_ready (nodenum(xd, yd, zd, td))(SOUTH) <= (others => '0');
          end generate;
          generating_16 : if (yd < Y-1) generate
            node_in_flit (nodenum(xd, yd, zd, td))(NORTH)   <= node_out_flit (northof(xd, yd, zd, td))(SOUTH);
            node_in_last (nodenum(xd, yd, zd, td))(NORTH)   <= node_out_last (northof(xd, yd, zd, td))(SOUTH);
            node_in_valid (nodenum(xd, yd, zd, td))(NORTH)  <= node_out_valid (northof(xd, yd, zd, td))(SOUTH);
            node_out_ready (nodenum(xd, yd, zd, td))(NORTH) <= node_in_ready (northof(xd, yd, zd, td))(SOUTH);
          elsif (yd >= Y-1) generate
            node_in_flit (nodenum(xd, yd, zd, td))(NORTH)   <= (others => (others => 'X'));
            node_in_last (nodenum(xd, yd, zd, td))(NORTH)   <= (others => 'X');
            node_in_valid (nodenum(xd, yd, zd, td))(NORTH)  <= (others => '0');
            node_out_ready (nodenum(xd, yd, zd, td))(NORTH) <= (others => '0');
          end generate;
          generating_19 : if (xd > 0) generate
            node_in_flit (nodenum(xd, yd, zd, td))(WEST)   <= node_out_flit (westof(xd, yd, zd, td))(EAST);
            node_in_last (nodenum(xd, yd, zd, td))(WEST)   <= node_out_last (westof(xd, yd, zd, td))(EAST);
            node_in_valid (nodenum(xd, yd, zd, td))(WEST)  <= node_out_valid (westof(xd, yd, zd, td))(EAST);
            node_out_ready (nodenum(xd, yd, zd, td))(WEST) <= node_in_ready (westof(xd, yd, zd, td))(EAST);
          elsif (xd <= 0) generate
            node_in_flit (nodenum(xd, yd, zd, td))(WEST)   <= (others => (others => 'X'));
            node_in_last (nodenum(xd, yd, zd, td))(WEST)   <= (others => 'X');
            node_in_valid (nodenum(xd, yd, zd, td))(WEST)  <= (others => '0');
            node_out_ready (nodenum(xd, yd, zd, td))(WEST) <= (others => '0');
          end generate;
          generating_18 : if (xd < X-1) generate
            node_in_flit (nodenum(xd, yd, zd, td))(EAST)   <= node_out_flit (eastof(xd, yd, zd, td))(WEST);
            node_in_last (nodenum(xd, yd, zd, td))(EAST)   <= node_out_last (eastof(xd, yd, zd, td))(WEST);
            node_in_valid (nodenum(xd, yd, zd, td))(EAST)  <= node_out_valid (eastof(xd, yd, zd, td))(WEST);
            node_out_ready (nodenum(xd, yd, zd, td))(EAST) <= node_in_ready (eastof(xd, yd, zd, td))(WEST);
          elsif (xd >= X-1) generate
            node_in_flit (nodenum(xd, yd, zd, td))(EAST)   <= (others => (others => 'X'));
            node_in_last (nodenum(xd, yd, zd, td))(EAST)   <= (others => 'X');
            node_in_valid (nodenum(xd, yd, zd, td))(EAST)  <= (others => '0');
            node_out_ready (nodenum(xd, yd, zd, td))(EAST) <= (others => '0');
          end generate;
        end generate;
      end generate;
    end generate;
  end RTL;
