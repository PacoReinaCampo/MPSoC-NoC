-- Converted from rtl/verilog/core/noc_buffer.sv
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
use ieee.math_real.all;

use work.mpsoc_noc_pkg.all;

entity noc_buffer is
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
end noc_buffer;

architecture RTL of noc_buffer is
  --////////////////////////////////////////////////////////////////
  --
  -- Constants
  --

  -- must be a power of 2
  constant AW : integer := integer(log2(real(DEPTH)));

  --////////////////////////////////////////////////////////////////
  --
  -- Functions
  --
  function find_first_one (
    data : std_logic_vector(DEPTH downto 0)
  ) return std_logic_vector is
    variable find_first_one_return : std_logic_vector (AW downto 0);
  begin
    for i in DEPTH downto 0 loop
      if (data(i) = '1') then
        find_first_one_return := std_logic_vector(to_unsigned(i, AW+1));
      else
        find_first_one_return := std_logic_vector(to_unsigned(DEPTH + 1, AW+1));
      end if;
    end loop;
    return find_first_one_return;
  end find_first_one;  -- size_count

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --
  signal wr_addr  : std_logic_vector(AW-1 downto 0);
  signal rd_addr  : std_logic_vector(AW-1 downto 0);
  signal rd_count : std_logic_vector(AW downto 0);

  signal fifo_read     : std_logic;
  signal fifo_write    : std_logic;
  signal read_ram      : std_logic;
  signal write_through : std_logic;
  signal write_ram     : std_logic;

  -- Generic dual-port, single clock memory

  -- Write
  signal ram : std_logic_matrix(DEPTH-1 downto 0)(FLIT_WIDTH downto 0);

  -- Read
  signal data_last_buf     : std_logic_vector(DEPTH downto 0);
  signal data_last_shifted : std_logic_vector(DEPTH downto 0);

  signal in_ready_sgn  : std_logic;
  signal out_valid_sgn : std_logic;

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  -- The actual depth is DEPTH+1 because of the output register
  in_ready_sgn <= to_stdlogic(rd_count < std_logic_vector(to_unsigned(DEPTH+1, AW+1)));

  fifo_read     <= out_valid_sgn and out_ready;
  fifo_write    <= in_ready_sgn and in_valid;
  read_ram      <= fifo_read and to_stdlogic(rd_count > std_logic_vector(to_unsigned(1, AW+1)));
  write_through <= to_stdlogic(rd_count > std_logic_vector(to_unsigned(0, AW+1))) or 
                  (to_stdlogic(rd_count > std_logic_vector(to_unsigned(1, AW+1))) and fifo_read);
  write_ram     <= fifo_write and not write_through;

  -- Address logic
  processing_1 : process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        wr_addr  <= (others => '0');
        rd_addr  <= (others => '0');
        rd_count <= (others => '0');
      else
        if (fifo_write = '1' and fifo_read = '0') then
          rd_count <= std_logic_vector(unsigned(rd_count)+to_unsigned(1, AW+1));
        elsif (fifo_read = '1' and fifo_write = '0') then
          rd_count <= std_logic_vector(unsigned(rd_count)-to_unsigned(1, AW+1));
          if (write_ram = '1') then
            wr_addr <= std_logic_vector(unsigned(wr_addr)+to_unsigned(1, AW+1));
          elsif (read_ram = '1') then
            rd_addr <= std_logic_vector(unsigned(rd_addr)+to_unsigned(1, AW+1));
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Generic dual-port, single clock memory

  -- Write
  processing_2 : process (clk)
  begin
    if (rising_edge(clk)) then
      if (write_ram = '1') then
        ram(to_integer(unsigned(wr_addr))) <= (in_last & in_flit);
      end if;
    end if;
  end process;

  -- Read
  processing_3 : process (clk)
  begin
    if (rising_edge(clk)) then
      if (read_ram = '1') then
        out_flit <= ram(to_integer(unsigned(rd_addr)))(FLIT_WIDTH-1 downto 0);
        out_last <= ram(to_integer(unsigned(rd_addr)))(FLIT_WIDTH);
      elsif (fifo_write = '1' and write_through = '1') then
        out_flit <= in_flit;
        out_last <= in_last;
      end if;
    end if;
  end process;

  generating_0 : if (FULLPACKET = 1) generate
    processing_4 : process (clk)
    begin
      if (rising_edge(clk)) then
        if (rst = '1') then
          data_last_buf <= (others => '0');
        elsif (fifo_write = '1') then
          data_last_buf <= (data_last_buf(DEPTH downto 1) & in_last);
        end if;
      end if;
    end process;

    -- Extra logic to get the packet size in a stable manner
    data_last_shifted <= std_logic_vector(unsigned(data_last_buf) sll (DEPTH+1-to_integer(unsigned(rd_addr))));

  out_valid_sgn <= to_stdlogic(rd_count > std_logic_vector(to_unsigned(0, AW+1))) and reduce_or(data_last_shifted) when FULLPACKET = 1
                   else to_stdlogic(rd_count > std_logic_vector(to_unsigned(0, AW+1)));

  packet_size   <= std_logic_vector(to_unsigned(DEPTH+1, AW+1)-unsigned(find_first_one(data_last_shifted))) when FULLPACKET = 1
                   else (others => '0');
  elsif (FULLPACKET > 1) generate
    out_valid_sgn <= to_stdlogic(rd_count > std_logic_vector(to_unsigned(0, AW+1)));
    packet_size   <= (others => '0');
  end generate;

  in_ready  <= in_ready_sgn;
  out_valid <= out_valid_sgn;
end RTL;
