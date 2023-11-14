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
--              Master Slave Interface Tesbench                               --
--              AMBA3 AHB-Lite Bus Interface                                  --
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
    SIM   : integer := 0;
    DEBUG : integer := 0
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- WISHBONE interface
    wb_adr_i : in  std_logic_vector(2 downto 0);
    wb_dat_i : in  std_logic_vector(7 downto 0);
    wb_dat_o : out std_logic_vector(7 downto 0);
    wb_we_i  : in  std_logic;
    wb_stb_i : in  std_logic;
    wb_cyc_i : in  std_logic;
    wb_sel_i : in  std_logic_vector(3 downto 0);
    wb_ack_o : out std_logic;
    int_o    : out std_logic;

    -- UART signals
    srx_pad_i : in  std_logic;
    stx_pad_o : out std_logic;
    rts_pad_o : out std_logic;
    cts_pad_i : in  std_logic;
    dtr_pad_o : out std_logic;
    dsr_pad_i : in  std_logic;
    ri_pad_i  : in  std_logic;
    dcd_pad_i : in  std_logic;

    -- optional baudrate output
    baud_o : out std_logic
  );
end peripheral_noc_synthesis;

architecture rtl of peripheral_noc_synthesis is

  ------------------------------------------------------------------------------
  -- Components
  ------------------------------------------------------------------------------
  component peripheral_wb_noc
    generic (
      SIM   : integer := 0;
      DEBUG : integer := 0
    );
    port (
      wb_clk_i : in std_logic;
      wb_rst_i : in std_logic;

      -- WISHBONE interface
      wb_adr_i : in  std_logic_vector(2 downto 0);
      wb_dat_i : in  std_logic_vector(7 downto 0);
      wb_dat_o : out std_logic_vector(7 downto 0);
      wb_we_i  : in  std_logic;
      wb_stb_i : in  std_logic;
      wb_cyc_i : in  std_logic;
      wb_sel_i : in  std_logic_vector(3 downto 0);
      wb_ack_o : out std_logic;
      int_o    : out std_logic;

      -- UART  signals
      srx_pad_i : in  std_logic;
      stx_pad_o : out std_logic;
      rts_pad_o : out std_logic;
      cts_pad_i : in  std_logic;
      dtr_pad_o : out std_logic;
      dsr_pad_i : in  std_logic;
      ri_pad_i  : in  std_logic;
      dcd_pad_i : in  std_logic;

      -- optional baudrate output
      baud_o : out std_logic
    );
  end component;

begin
  ------------------------------------------------------------------------------
  -- Module Body
  ------------------------------------------------------------------------------

  -- DUT WB
  wb_noc : peripheral_wb_noc
    generic map (
      SIM   => SIM,
      DEBUG => DEBUG
    )
    port map (
      wb_clk_i => clk,
      wb_rst_i => rst,

      -- WISHBONE interface
      wb_adr_i => wb_adr_i,
      wb_dat_i => wb_dat_i,
      wb_dat_o => wb_dat_o,
      wb_we_i  => wb_we_i,
      wb_stb_i => wb_stb_i,
      wb_cyc_i => wb_cyc_i,
      wb_sel_i => wb_sel_i,
      wb_ack_o => wb_ack_o,
      int_o    => int_o,

      -- UART signals
      srx_pad_i => srx_pad_i,
      stx_pad_o => stx_pad_o,
      rts_pad_o => rts_pad_o,
      cts_pad_i => cts_pad_i,
      dtr_pad_o => dtr_pad_o,
      dsr_pad_i => dsr_pad_i,
      ri_pad_i  => ri_pad_i,
      dcd_pad_i => dcd_pad_i,

      -- optional baudrate output
      baud_o => baud_o
    );
end rtl;
