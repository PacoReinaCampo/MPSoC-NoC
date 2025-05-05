--------------------------------------------------------------------------------
--                                            __ _      _     _               --
--                                           / _(_)    | |   | |              --
--                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              --
--               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              --
--              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              --
--               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              --
--                  | |                                                       --
--                  |_|                                                       --
--                                                                            --
--                                                                            --
--              MPSoC-RISCV CPU                                               --
--              Universal Asynchronous Receiver-Transmitter                   --
--              AMBA4 AHB-Lite Bus Interface                                  --
--                                                                            --
--------------------------------------------------------------------------------

-- Copyright (c) 2018-2019 by the author(s)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
--------------------------------------------------------------------------------
-- Author(s):
--   Paco Reina Campo <pacoreinacampo@queenfield.tech>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity peripheral_noc_synthesis is
  generic (
    HADDR_SIZE     : integer := 8;
    HDATA_SIZE     : integer := 32;
    APB_ADDR_WIDTH : integer := 8;
    APB_DATA_WIDTH : integer := 32;
    SYNC_DEPTH     : integer := 3
  );
  port (
    -- Common signals
    HRESETn   : in  std_logic;
    HCLK      : in  std_logic;

    -- UART AHB4
    noc_HSEL      : in  std_logic;
    noc_HADDR     : in  std_logic_vector(HADDR_SIZE-1 downto 0);
    noc_HWDATA    : in  std_logic_vector(HDATA_SIZE-1 downto 0);
    noc_HRDATA    : out std_logic_vector(HDATA_SIZE-1 downto 0);
    noc_HWRITE    : in  std_logic;
    noc_HSIZE     : in  std_logic_vector(2 downto 0);
    noc_HBURST    : in  std_logic_vector(2 downto 0);
    noc_HPROT     : in  std_logic_vector(3 downto 0);
    noc_HTRANS    : in  std_logic_vector(1 downto 0);
    noc_HMASTLOCK : in  std_logic;
    noc_HREADYOUT : out std_logic;
    noc_HREADY    : in  std_logic;
    noc_HRESP     : out std_logic
  );
end peripheral_noc_synthesis;

architecture rtl of peripheral_noc_synthesis is

  ------------------------------------------------------------------------------
  -- Components
  ------------------------------------------------------------------------------

  component peripheral_bridge_apb2ahb
    generic (
      HADDR_SIZE : integer := 32;
      HDATA_SIZE : integer := 32;
      PADDR_SIZE : integer := 10;
      PDATA_SIZE : integer := 8;
      SYNC_DEPTH : integer := 3
      );
    port (
      -- AHB Slave Interface
      HRESETn   : in  std_logic;
      HCLK      : in  std_logic;
      HSEL      : in  std_logic;
      HADDR     : in  std_logic_vector(HADDR_SIZE-1 downto 0);
      HWDATA    : in  std_logic_vector(HDATA_SIZE-1 downto 0);
      HRDATA    : out std_logic_vector(HDATA_SIZE-1 downto 0);
      HWRITE    : in  std_logic;
      HSIZE     : in  std_logic_vector(2 downto 0);
      HBURST    : in  std_logic_vector(2 downto 0);
      HPROT     : in  std_logic_vector(3 downto 0);
      HTRANS    : in  std_logic_vector(1 downto 0);
      HMASTLOCK : in  std_logic;
      HREADYOUT : out std_logic;
      HREADY    : in  std_logic;
      HRESP     : out std_logic;

      -- APB Master Interface
      PRESETn : in  std_logic;
      PCLK    : in  std_logic;
      PSEL    : out std_logic;
      PENABLE : out std_logic;
      PPROT   : out std_logic_vector(2 downto 0);
      PWRITE  : out std_logic;
      PSTRB   : out std_logic;
      PADDR   : out std_logic_vector(PADDR_SIZE-1 downto 0);
      PWDATA  : out std_logic_vector(PDATA_SIZE-1 downto 0);
      PRDATA  : in  std_logic_vector(PDATA_SIZE-1 downto 0);
      PREADY  : in  std_logic;
      PSLVERR : in  std_logic
      );
  end component;

  component peripheral_apb4_noc
    generic (
      APB_ADDR_WIDTH : integer := 12;  -- APB slaves are 4KB by default
      APB_DATA_WIDTH : integer := 32  -- APB slaves are 4KB by default
      );
    port (
      CLK     : in  std_logic;
      RSTN    : in  std_logic;
      PADDR   : in  std_logic_vector(APB_ADDR_WIDTH-1 downto 0);
      PWDATA  : in  std_logic_vector(APB_DATA_WIDTH-1 downto 0);
      PWRITE  : in  std_logic;
      PSEL    : in  std_logic;
      PENABLE : in  std_logic;
      PRDATA  : out std_logic_vector(APB_DATA_WIDTH-1 downto 0);
      PREADY  : out std_logic;
      PSLVERR : out std_logic;

      rx_i : in  std_logic;  -- Receiver input
      tx_o : out std_logic;  -- Transmitter output

      event_o : out std_logic  -- interrupt/event output
      );
  end component;

  ------------------------------------------------------------------------------
  -- Variables
  ------------------------------------------------------------------------------

  signal noc_PADDR   : std_logic_vector(APB_ADDR_WIDTH-1 downto 0);
  signal noc_PWDATA  : std_logic_vector(APB_DATA_WIDTH-1 downto 0);
  signal noc_PWRITE  : std_logic;
  signal noc_PSEL    : std_logic;
  signal noc_PENABLE : std_logic;
  signal noc_PRDATA  : std_logic_vector(APB_DATA_WIDTH-1 downto 0);
  signal noc_PREADY  : std_logic;
  signal noc_PSLVERR : std_logic;

  signal noc_rx_i : std_logic;         -- Receiver input
  signal noc_tx_o : std_logic;         -- Transmitter output

  signal noc_event_o : std_logic;

begin
  ------------------------------------------------------------------------------
  -- Module Body
  ------------------------------------------------------------------------------

  -- DUT AHB4
  bridge_apb2ahb : peripheral_bridge_apb2ahb
    generic map (
      HADDR_SIZE => HADDR_SIZE,
      HDATA_SIZE => HDATA_SIZE,
      PADDR_SIZE => APB_ADDR_WIDTH,
      PDATA_SIZE => APB_DATA_WIDTH,
      SYNC_DEPTH => SYNC_DEPTH
      )
    port map (
      -- AHB Slave Interface
      HRESETn => HRESETn,
      HCLK    => HCLK,

      HSEL      => noc_HSEL,
      HADDR     => noc_HADDR,
      HWDATA    => noc_HWDATA,
      HRDATA    => noc_HRDATA,
      HWRITE    => noc_HWRITE,
      HSIZE     => noc_HSIZE,
      HBURST    => noc_HBURST,
      HPROT     => noc_HPROT,
      HTRANS    => noc_HTRANS,
      HMASTLOCK => noc_HMASTLOCK,
      HREADYOUT => noc_HREADYOUT,
      HREADY    => noc_HREADY,
      HRESP     => noc_HRESP,

      -- APB Master Interface
      PRESETn => HRESETn,
      PCLK    => HCLK,

      PSEL    => noc_PSEL,
      PENABLE => noc_PENABLE,
      PPROT   => open,
      PWRITE  => noc_PWRITE,
      PSTRB   => open,
      PADDR   => noc_PADDR,
      PWDATA  => noc_PWDATA,
      PRDATA  => noc_PRDATA,
      PREADY  => noc_PREADY,
      PSLVERR => noc_PSLVERR
      );

  apb4_noc : peripheral_apb4_noc
    generic map (
      APB_ADDR_WIDTH => APB_ADDR_WIDTH,
      APB_DATA_WIDTH => APB_DATA_WIDTH
      )
    port map (
      CLK     => HCLK,
      RSTN    => HRESETn,
      PADDR   => noc_PADDR,
      PWDATA  => noc_PWDATA,
      PWRITE  => noc_PWRITE,
      PSEL    => noc_PSEL,
      PENABLE => noc_PENABLE,
      PRDATA  => noc_PRDATA,
      PREADY  => noc_PREADY,
      PSLVERR => noc_PSLVERR,

      rx_i => noc_rx_i,
      tx_o => noc_tx_o,

      event_o => noc_event_o
      );
end rtl;
