-- Converted from pkg/riscv_mpsoc_pkg.sv
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
--              RISC-V Package                                                //
--              AMBA3 AHB-Lite Bus Interface                                  //
--                                                                            //
--//////////////////////////////////////////////////////////////////////////////

-- Copyright (c) 2017-2018 by the author(s)
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

package riscv_mpsoc_pkg is

  --core parameters
  constant XLEN                   : integer := 64;
  constant PLEN                   : integer := 64;
  constant FLEN                   : integer := 64;

  constant PC_INIT                : std_ulogic_vector(XLEN-1 downto 0) := X"0000000080000000";  --Start here after reset
  constant BASE                   : std_ulogic_vector(XLEN-1 downto 0) := PC_INIT;  --offset where to load program in memory

  constant INIT_FILE              : string    := "test.hex";

  constant MEM_LATENCY            : std_ulogic := '1';
  constant HAS_USER               : std_ulogic := '1';
  constant HAS_SUPER              : std_ulogic := '1';
  constant HAS_HYPER              : std_ulogic := '1';
  constant HAS_BPU                : std_ulogic := '1';
  constant HAS_FPU                : std_ulogic := '1';
  constant HAS_MMU                : std_ulogic := '1';
  constant HAS_RVM                : std_ulogic := '1';
  constant HAS_RVA                : std_ulogic := '1';
  constant HAS_RVC                : std_ulogic := '1';
  constant HAS_RVN                : std_ulogic := '1';
  constant HAS_RVB                : std_ulogic := '1';
  constant HAS_RVT                : std_ulogic := '1';
  constant HAS_RVP                : std_ulogic := '1';
  constant HAS_EXT                : std_ulogic := '1';

  constant IS_RV32E               : std_ulogic := '1';

  constant MULT_LATENCY           : integer := 1;

  constant HTIF                   : std_ulogic := '0';  --Host-interface

  constant TOHOST                 : std_ulogic_vector(XLEN-1 downto 0) := X"0000000080001000";
  constant UART_TX                : std_ulogic_vector(XLEN-1 downto 0) := X"0000000080001080";

  constant BREAKPOINTS            : integer := 8;  --Number of hardware breakpoints

  constant PMA_CNT                : integer := 4;
  constant PMP_CNT                : integer := 16;  --Number of Physical Memory Protection entries

  type M_PMA_CNT_13 is array (PMA_CNT-1 downto 0) of std_ulogic_vector(13 downto 0);
  type M_PMA_CNT_PLEN is array (PMA_CNT-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);

  type M_PMP_CNT_7 is array (PMP_CNT-1 downto 0) of std_ulogic_vector(7 downto 0);
  type M_PMP_CNT_PLEN is array (PMP_CNT-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);

  constant BP_GLOBAL_BITS         : integer := 2;
  constant BP_LOCAL_BITS          : integer := 10;
  constant BP_LOCAL_BITS_LSB      : integer := 2; 

  constant ICACHE_SIZE            : integer := 64;  --in KBytes
  constant ICACHE_BLOCK_SIZE      : integer := 64;  --in Bytes
  constant ICACHE_WAYS            : integer := 2;  --'n'-way set associative

  constant ICACHE_REPLACE_ALG     : std_ulogic := '0';
  constant ITCM_SIZE              : integer := 0;

  constant DCACHE_SIZE            : integer := 64;  --in KBytes
  constant DCACHE_BLOCK_SIZE      : integer := 64;  --in Bytes
  constant DCACHE_WAYS            : integer := 2;  --'n'-way set associative
  constant WRITEBUFFER_SIZE       : integer := 8;

  constant DCACHE_REPLACE_ALG     : std_ulogic := '0';
  constant DTCM_SIZE              : integer := 0;

  constant TECHNOLOGY             : string    := "GENERIC";

  constant AVOID_X                : std_ulogic := '0';

  constant MNMIVEC_DEFAULT        : std_ulogic_vector(XLEN-1 downto 0) := X"0000000000000004";
  constant MTVEC_DEFAULT          : std_ulogic_vector(XLEN-1 downto 0) := X"0000000000000040";
  constant HTVEC_DEFAULT          : std_ulogic_vector(XLEN-1 downto 0) := X"0000000000000080";
  constant STVEC_DEFAULT          : std_ulogic_vector(XLEN-1 downto 0) := X"00000000000000C0";
  constant UTVEC_DEFAULT          : std_ulogic_vector(XLEN-1 downto 0) := X"0000000000000100";

  constant JEDEC_BANK             : integer := 10;

  constant JEDEC_MANUFACTURER_ID  : std_ulogic_vector(7 downto 0) := X"6E";

  constant HARTID                 : integer := 0;

  constant PARCEL_SIZE            : integer := 64;

  constant HADDR_SIZE             : integer := XLEN;
  constant HDATA_SIZE             : integer := PLEN;
  constant PADDR_SIZE             : integer := PLEN;
  constant PDATA_SIZE             : integer := XLEN;

  constant SYNC_DEPTH             : integer := 3;

  constant BUFFER_DEPTH           : integer := 4;

  --RF access
  constant RDPORTS                : integer := 2;
  constant WRPORTS                : integer := 1;
  constant AR_BITS                : integer := 5;

  --mpsoc parameters
  constant CORES_PER_SIMD         : integer := 3;
  constant CORES_PER_MISD         : integer := 2;

  constant CORES_PER_TILE         : integer := CORES_PER_SIMD + CORES_PER_MISD;

  --soc parameters
  constant X                      : integer := 2;
  constant Y                      : integer := 1;
  constant Z                      : integer := 2;

  constant NODES                  : integer := X*Y*Z;
  constant CORES                  : integer := NODES*CORES_PER_TILE;

  --noc parameters
  constant CHANNELS               : integer := 2;
  constant PCHANNELS              : integer := 2;
  constant VCHANNELS              : integer := 2;

  constant INPUTS                 : integer := 7;
  constant OUTPUTS                : integer := 7;

  constant ENABLE_VCHANNELS       : integer := 1;

  constant ROUTER_BUFFER_SIZE     : integer := 2;
  constant REG_ADDR_WIDTH         : integer := 2;
  constant VALWIDTH               : integer := 2;
  constant MAX_PKT_LEN            : integer := 2;

  constant TILE_ID : integer := 0;

  constant GENERATE_INTERRUPT     : std_ulogic := '1';

  constant TABLE_ENTRIES          : integer := 4;
  constant NOC_PACKET_SIZE        : integer := 16;

  constant TABLE_ENTRIES_PTRWIDTH : integer := integer(log2(real(TABLE_ENTRIES)));

  constant MUX_PORTS : integer := 2;

  --////////////////////////////////////////////////////////////////
  --
  -- Types
  --
  type M_MUX_PORTS_PLEN is array (MUX_PORTS-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_MUX_PORTS_XLEN is array (MUX_PORTS-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_MUX_PORTS_2 is array (MUX_PORTS-1 downto 0) of std_ulogic_vector(2 downto 0);

  type M_2_CORES_PER_MISD1 is array (2 downto 0) of std_ulogic_vector(CORES_PER_MISD downto 0);
  type M_2_CORES_PER_SIMD1 is array (2 downto 0) of std_ulogic_vector(CORES_PER_SIMD downto 0);
  type M_2_CORES_PER_MISD is array (2 downto 0) of std_ulogic_vector(CORES_PER_MISD-1 downto 0);
  type M_2_CORES_PER_SIMD is array (2 downto 0) of std_ulogic_vector(CORES_PER_SIMD-1 downto 0);
  type M_2_PLEN is array (2 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_2_XLEN is array (2 downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_2_3 is array (2 downto 0) of std_ulogic_vector(3 downto 0);
  type M_2_2 is array (2 downto 0) of std_ulogic_vector(2 downto 0);
  type M_2_1 is array (2 downto 0) of std_ulogic_vector(1 downto 0);

  type M_CORES_PER_MISD1_2_PLEN is array (CORES_PER_MISD downto 0) of M_2_PLEN;
  type M_CORES_PER_MISD1_2_XLEN is array (CORES_PER_MISD downto 0) of M_2_XLEN;
  type M_CORES_PER_MISD1_2_3 is array (CORES_PER_MISD downto 0) of M_2_3;
  type M_CORES_PER_MISD1_2_2 is array (CORES_PER_MISD downto 0) of M_2_2;
  type M_CORES_PER_MISD1_2_1 is array (CORES_PER_MISD downto 0) of M_2_1;

  type M_CORES_PER_SIMD1_2_PLEN is array (CORES_PER_SIMD downto 0) of M_2_PLEN;
  type M_CORES_PER_SIMD1_2_XLEN is array (CORES_PER_SIMD downto 0) of M_2_XLEN;
  type M_CORES_PER_SIMD1_2_3 is array (CORES_PER_SIMD downto 0) of M_2_3;
  type M_CORES_PER_SIMD1_2_2 is array (CORES_PER_SIMD downto 0) of M_2_2;
  type M_CORES_PER_SIMD1_2_1 is array (CORES_PER_SIMD downto 0) of M_2_1;

  type M_CORES_PER_TILE_PLEN is array (CORES_PER_TILE-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_CORES_PER_TILE_XLEN is array (CORES_PER_TILE-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_CORES_PER_TILE_3 is array (CORES_PER_TILE-1 downto 0) of std_ulogic_vector(3 downto 0);
  type M_CORES_PER_TILE_2 is array (CORES_PER_TILE-1 downto 0) of std_ulogic_vector(2 downto 0);
  type M_CORES_PER_TILE_1 is array (CORES_PER_TILE-1 downto 0) of std_ulogic_vector(1 downto 0);

  type M_2CORES_PER_MISD_PLEN is array (2*CORES_PER_MISD-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_2CORES_PER_MISD_XLEN is array (2*CORES_PER_MISD-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_2CORES_PER_MISD_3 is array (2*CORES_PER_MISD-1 downto 0) of std_ulogic_vector(3 downto 0);
  type M_2CORES_PER_MISD_2 is array (2*CORES_PER_MISD-1 downto 0) of std_ulogic_vector(2 downto 0);
  type M_2CORES_PER_MISD_1 is array (2*CORES_PER_MISD-1 downto 0) of std_ulogic_vector(1 downto 0);

  type M_CORES_PER_MISD_CORES_PER_MISD is array (CORES_PER_MISD-1 downto 0) of std_ulogic_vector(CORES_PER_MISD-1 downto 0);
  type M_CORES_PER_MISD_PLEN is array (CORES_PER_MISD-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_CORES_PER_MISD_XLEN is array (CORES_PER_MISD-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_CORES_PER_MISD_3 is array (CORES_PER_MISD-1 downto 0) of std_ulogic_vector(3 downto 0);
  type M_CORES_PER_MISD_2 is array (CORES_PER_MISD-1 downto 0) of std_ulogic_vector(2 downto 0);
  type M_CORES_PER_MISD_1 is array (CORES_PER_MISD-1 downto 0) of std_ulogic_vector(1 downto 0);

  type M_CORES_PER_MISD1_PLEN is array (CORES_PER_MISD downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_CORES_PER_MISD1_XLEN is array (CORES_PER_MISD downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_CORES_PER_MISD1_3 is array (CORES_PER_MISD downto 0) of std_ulogic_vector(3 downto 0);
  type M_CORES_PER_MISD1_2 is array (CORES_PER_MISD downto 0) of std_ulogic_vector(2 downto 0);
  type M_CORES_PER_MISD1_1 is array (CORES_PER_MISD downto 0) of std_ulogic_vector(1 downto 0);

  type M_2CORES_PER_SIMD_PLEN is array (2*CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_2CORES_PER_SIMD_XLEN is array (2*CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_2CORES_PER_SIMD_3 is array (2*CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(3 downto 0);
  type M_2CORES_PER_SIMD_2 is array (2*CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(2 downto 0);
  type M_2CORES_PER_SIMD_1 is array (2*CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(1 downto 0);

  type M_CORES_PER_SIMD_CORES_PER_SIMD is array (CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(CORES_PER_SIMD-1 downto 0);
  type M_CORES_PER_SIMD_PLEN is array (CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_CORES_PER_SIMD_XLEN is array (CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_CORES_PER_SIMD_3 is array (CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(3 downto 0);
  type M_CORES_PER_SIMD_2 is array (CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(2 downto 0);
  type M_CORES_PER_SIMD_1 is array (CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(1 downto 0);

  type M_CORES_PER_SIMD1_PLEN is array (CORES_PER_SIMD downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_CORES_PER_SIMD1_XLEN is array (CORES_PER_SIMD downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_CORES_PER_SIMD1_3 is array (CORES_PER_SIMD downto 0) of std_ulogic_vector(3 downto 0);
  type M_CORES_PER_SIMD1_2 is array (CORES_PER_SIMD downto 0) of std_ulogic_vector(2 downto 0);
  type M_CORES_PER_SIMD1_1 is array (CORES_PER_SIMD downto 0) of std_ulogic_vector(1 downto 0);

  type M_2_CORES_PER_MISD1_XLEN is array (CORES_PER_SIMD downto 0) of M_CORES_PER_MISD1_XLEN;
  type M_2_CORES_PER_SIMD1_XLEN is array (CORES_PER_SIMD downto 0) of M_CORES_PER_SIMD1_XLEN;

  type M_CORES_PER_SIMD_VALWIDTH is array (CORES_PER_SIMD-1 downto 0) of std_ulogic_vector(VALWIDTH-1 downto 0);
  type M_CORES_PER_MISD_VALWIDTH is array (CORES_PER_MISD-1 downto 0) of std_ulogic_vector(VALWIDTH-1 downto 0);

  type M_2_CHANNELS is array (2 downto 0) of std_ulogic_vector(CHANNELS-1 downto 0);

  type M_CHANNELS_3 is array (CHANNELS-1 downto 0) of std_ulogic_vector(3 downto 0);
  type M_CHANNELS_2 is array (CHANNELS-1 downto 0) of std_ulogic_vector(2 downto 0);
  type M_CHANNELS_1 is array (CHANNELS-1 downto 0) of std_ulogic_vector(1 downto 0);

  type M_CHANNELS_PLEN is array (CHANNELS-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_CHANNELS_XLEN is array (CHANNELS-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_INPUTS_CHANNELS is array (INPUTS-1 downto 0) of std_ulogic_vector(CHANNELS -1 downto 0);
  type M_INPUTS_PCHANNELS is array (INPUTS-1 downto 0) of std_ulogic_vector(PCHANNELS -1 downto 0);
  type M_INPUTS_PLEN is array (INPUTS-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_INPUTS_VCHANNELS is array (INPUTS-1 downto 0) of std_ulogic_vector(VCHANNELS -1 downto 0);
  type M_NODES_CHANNELS is array (NODES-1 downto 0) of std_ulogic_vector(CHANNELS-1 downto 0);
  type M_NODES_INPUTS is array (NODES-1 downto 0) of std_ulogic_vector(INPUTS-1 downto 0);
  type M_NODES_NODES_INPUTS is array (NODES-1 downto 0) of std_ulogic_vector(INPUTS-1 downto 0);
  type M_NODES_NODES_OUTPUTS is array (NODES-1 downto 0) of std_ulogic_vector(OUTPUTS-1 downto 0);
  type M_NODES_OUTPUTS is array (NODES-1 downto 0) of std_ulogic_vector(OUTPUTS-1 downto 0);
  type M_NODES_VCHANNELS is array (NODES-1 downto 0) of std_ulogic_vector(VCHANNELS-1 downto 0);
  type M_OUTPUTS_CHANNELS is array (OUTPUTS-1 downto 0) of std_ulogic_vector(CHANNELS -1 downto 0);
  type M_OUTPUTS_PCHANNELS is array (OUTPUTS-1 downto 0) of std_ulogic_vector(PCHANNELS -1 downto 0);
  type M_OUTPUTS_PLEN is array (OUTPUTS-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_OUTPUTS_VCHANNELS is array (OUTPUTS-1 downto 0) of std_ulogic_vector(VCHANNELS -1 downto 0);
  type M_PCHANNELS_PLEN is array (PCHANNELS-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_VCHANNELS_INPUTS is array (VCHANNELS-1 downto 0) of std_ulogic_vector(INPUTS-1 downto 0);
  type M_VCHANNELS_OUTPUTS is array (VCHANNELS-1 downto 0) of std_ulogic_vector(OUTPUTS-1 downto 0);
  type M_VCHANNELS_PLEN is array (VCHANNELS-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);

  type M_INPUTS_VCHANNELS_INPUTS is array (INPUTS-1 downto 0) of M_VCHANNELS_INPUTS;
  type M_INPUTS_VCHANNELS_OUTPUTS is array (INPUTS-1 downto 0) of M_VCHANNELS_OUTPUTS;
  type M_INPUTS_VCHANNELS_PLEN is array (INPUTS-1 downto 0) of M_VCHANNELS_PLEN;
  type M_INPUTS_PCHANNELS_PLEN is array (INPUTS-1 downto 0) of M_PCHANNELS_PLEN;
  type M_NODES_CHANNELS_PLEN is array (NODES-1 downto 0) of M_CHANNELS_PLEN;
  type M_NODES_INPUTS_CHANNELS is array (NODES-1 downto 0) of M_INPUTS_CHANNELS;
  type M_NODES_INPUTS_PCHANNELS is array (NODES-1 downto 0) of M_INPUTS_PCHANNELS;
  type M_NODES_INPUTS_PLEN is array (NODES-1 downto 0) of M_INPUTS_PLEN;
  type M_NODES_INPUTS_VCHANNELS is array (NODES-1 downto 0) of M_INPUTS_VCHANNELS;
  type M_NODES_OUTPUTS_CHANNELS is array (NODES-1 downto 0) of M_OUTPUTS_CHANNELS;
  type M_NODES_OUTPUTS_PCHANNELS is array (NODES-1 downto 0) of M_OUTPUTS_PCHANNELS;
  type M_NODES_OUTPUTS_PLEN is array (NODES-1 downto 0) of M_OUTPUTS_PLEN;
  type M_NODES_OUTPUTS_VCHANNELS is array (NODES-1 downto 0) of M_OUTPUTS_VCHANNELS;
  type M_NODES_VCHANNELS_PLEN is array (NODES-1 downto 0) of M_VCHANNELS_PLEN;
  type M_OUTPUTS_PCHANNELS_PLEN is array (OUTPUTS-1 downto 0) of M_PCHANNELS_PLEN;
  type M_OUTPUTS_VCHANNELS_INPUTS is array (OUTPUTS-1 downto 0) of M_VCHANNELS_INPUTS;
  type M_OUTPUTS_VCHANNELS_OUTPUTS is array (OUTPUTS-1 downto 0) of M_VCHANNELS_OUTPUTS;
  type M_OUTPUTS_VCHANNELS_PLEN is array (OUTPUTS-1 downto 0) of M_VCHANNELS_PLEN;
  type M_VCHANNELS_INPUTS_PLEN is array (VCHANNELS-1 downto 0) of M_INPUTS_PLEN;
  type M_VCHANNELS_OUTPUTS_PLEN is array (VCHANNELS-1 downto 0) of M_OUTPUTS_PLEN;

  type M_CORES_PER_MISD_CORES_PER_MISD_PLEN is array (CORES_PER_MISD-1 downto 0) of M_CORES_PER_MISD_PLEN;
  type M_CORES_PER_MISD_CORES_PER_MISD_XLEN is array (CORES_PER_MISD-1 downto 0) of M_CORES_PER_MISD_XLEN;
  type M_CORES_PER_MISD_CORES_PER_MISD_3 is array (CORES_PER_MISD-1 downto 0) of M_CORES_PER_MISD_3;
  type M_CORES_PER_MISD_CORES_PER_MISD_2 is array (CORES_PER_MISD-1 downto 0) of M_CORES_PER_MISD_2;
  type M_CORES_PER_MISD_CORES_PER_MISD_1 is array (CORES_PER_MISD-1 downto 0) of M_CORES_PER_MISD_1;

  type M_CORES_PER_SIMD_CORES_PER_SIMD_PLEN is array (CORES_PER_SIMD-1 downto 0) of M_CORES_PER_SIMD_PLEN;
  type M_CORES_PER_SIMD_CORES_PER_SIMD_XLEN is array (CORES_PER_SIMD-1 downto 0) of M_CORES_PER_SIMD_XLEN;
  type M_CORES_PER_SIMD_CORES_PER_SIMD_3 is array (CORES_PER_SIMD-1 downto 0) of M_CORES_PER_SIMD_3;
  type M_CORES_PER_SIMD_CORES_PER_SIMD_2 is array (CORES_PER_SIMD-1 downto 0) of M_CORES_PER_SIMD_2;
  type M_CORES_PER_SIMD_CORES_PER_SIMD_1 is array (CORES_PER_SIMD-1 downto 0) of M_CORES_PER_SIMD_1;

  type M_INPUTS_VCHANNELS_INPUTS_PLEN is array (INPUTS-1 downto 0) of M_VCHANNELS_INPUTS_PLEN;
  type M_OUTPUTS_VCHANNELS_INPUTS_PLEN is array (OUTPUTS-1 downto 0) of M_VCHANNELS_INPUTS_PLEN;

  type M_NODES_INPUTS_PCHANNELS_PLEN is array (NODES-1 downto 0) of M_INPUTS_PCHANNELS_PLEN;
  type M_NODES_OUTPUTS_PCHANNELS_PLEN is array (NODES-1 downto 0) of M_OUTPUTS_PCHANNELS_PLEN;

  type M_XYZ is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic;

  type M_XYZ_CORES_PER_MISD1 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(CORES_PER_MISD downto 0);
  type M_XYZ_CORES_PER_SIMD1 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(CORES_PER_SIMD downto 0);
  type M_XYZ_CORES_PER_MISD is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(CORES_PER_MISD-1 downto 0);
  type M_XYZ_CORES_PER_SIMD is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(CORES_PER_SIMD-1 downto 0);
  type M_XYZ_PLEN is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(PLEN-1 downto 0);
  type M_XYZ_XLEN is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);
  type M_XYZ_3 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(3 downto 0);
  type M_XYZ_2 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(2 downto 0);
  type M_XYZ_1 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(1 downto 0);

  type M_XYZ_PDATA_SIZE is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(PDATA_SIZE-1 downto 0);
  type M_XYZ_CHANNELS_XLEN is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CHANNELS_XLEN;
  type M_XYZ_CHANNELS is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_ulogic_vector(CHANNELS-1 downto 0);

  type M_XYZ_CORES_PER_MISD_PLEN is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_MISD_PLEN;
  type M_XYZ_CORES_PER_MISD_XLEN is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_MISD_XLEN;
  type M_XYZ_CORES_PER_MISD_3 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_MISD_3;
  type M_XYZ_CORES_PER_MISD_2 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_MISD_2;
  type M_XYZ_CORES_PER_MISD_1 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_MISD_1;

  type M_XYZ_CORES_PER_SIMD_PLEN is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_SIMD_PLEN;
  type M_XYZ_CORES_PER_SIMD_XLEN is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_SIMD_XLEN;
  type M_XYZ_CORES_PER_SIMD_3 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_SIMD_3;
  type M_XYZ_CORES_PER_SIMD_2 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_SIMD_2;
  type M_XYZ_CORES_PER_SIMD_1 is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_SIMD_1;

  type M_PMA_CNT_XLEN is array (PMA_CNT-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);

  --debug parameters
  constant STDOUT_FILENAME        : integer := 4;
  constant TRACEFILE_FILENAME     : integer := 4;
  constant ENABLE_TRACE           : integer := 4;
  constant GLIP_PORT              : integer := 23000;
  constant TERM_CROSS_NUM         : integer := NODES;

  constant GLIP_UART_LIKE         : std_ulogic := '0';

  --//////////////////////////////////////////////////////////////
  --
  -- Types
  --
  type M_RDPORTS_AR_BITS is array (RDPORTS-1 downto 0) of std_ulogic_vector (AR_BITS-1 downto 0);
  type M_RDPORTS_XLEN    is array (RDPORTS-1 downto 0) of std_ulogic_vector (XLEN   -1 downto 0);
  type M_WRPORTS_AR_BITS is array (WRPORTS-1 downto 0) of std_ulogic_vector (AR_BITS-1 downto 0);
  type M_WRPORTS_XLEN    is array (WRPORTS-1 downto 0) of std_ulogic_vector (XLEN   -1 downto 0);

  type M_CHANNELS_CHANNELS is array (CHANNELS-1 downto 0) of std_ulogic_vector(CHANNELS-1 downto 0);
  type M_CHANNELS_NODES is array (CHANNELS-1 downto 0) of std_ulogic_vector(NODES-1 downto 0);
  type M_NODES_15 is array (NODES-1 downto 0) of std_ulogic_vector(15 downto 0);
  type M_NODES_HDATA_SIZE is array (NODES-1 downto 0) of std_ulogic_vector(HDATA_SIZE-1 downto 0);
  type M_NODES_XLEN is array (NODES-1 downto 0) of std_ulogic_vector(XLEN-1 downto 0);

  type N_CHANNELS_NODES is array (CHANNELS-1 downto 0) of std_ulogic_vector(NODES downto 0);
  type N_NODES_XLEN is array (NODES downto 0) of std_ulogic_vector(XLEN-1 downto 0);

  type M_CHANNELS_CHANNELS_XLEN is array (CHANNELS-1 downto 0) of M_CHANNELS_XLEN;
  type M_CHANNELS_NODES_XLEN is array (CHANNELS-1 downto 0) of N_NODES_XLEN;

  --RV12 Definitions Package
  constant ARCHID       : integer := 12;
  constant REVPRV_MAJOR : integer := 1;
  constant REVPRV_MINOR : integer := 10;
  constant REVUSR_MAJOR : integer := 2;
  constant REVUSR_MINOR : integer := 2;

  --BIU Constants Package
  constant BYTE       : std_ulogic_vector(2 downto 0) := "000";
  constant HWORD      : std_ulogic_vector(2 downto 0) := "001";
  constant WORD       : std_ulogic_vector(2 downto 0) := "010";
  constant DWORD      : std_ulogic_vector(2 downto 0) := "011";
  constant QWORD      : std_ulogic_vector(2 downto 0) := "100";
  constant UNDEF_SIZE : std_ulogic_vector(2 downto 0) := "XXX";

  constant SINGLE      : std_ulogic_vector(2 downto 0) := "000";
  constant INCR        : std_ulogic_vector(2 downto 0) := "001";
  constant WRAP4       : std_ulogic_vector(2 downto 0) := "010";
  constant INCR4       : std_ulogic_vector(2 downto 0) := "011";
  constant WRAP8       : std_ulogic_vector(2 downto 0) := "100";
  constant INCR8       : std_ulogic_vector(2 downto 0) := "101";
  constant WRAP16      : std_ulogic_vector(2 downto 0) := "110";
  constant INCR16      : std_ulogic_vector(2 downto 0) := "111";
  constant UNDEF_BURST : std_ulogic_vector(2 downto 0) := "XXX";

  --Enumeration Codes
  constant PROT_INSTRUCTION  : std_ulogic_vector(2 downto 0) := "000";
  constant PROT_DATA         : std_ulogic_vector(2 downto 0) := "001";
  constant PROT_USER         : std_ulogic_vector(2 downto 0) := "000";
  constant PROT_PRIVILEGED   : std_ulogic_vector(2 downto 0) := "010";
  constant PROT_NONCACHEABLE : std_ulogic_vector(2 downto 0) := "000";
  constant PROT_CACHEABLE    : std_ulogic_vector(2 downto 0) := "100";

  --Complex Enumerations
  constant NONCACHEABLE_USER_INSTRUCTION       : std_ulogic_vector(2 downto 0) := "000";
  constant NONCACHEABLE_USER_DATA              : std_ulogic_vector(2 downto 0) := "001";
  constant NONCACHEABLE_PRIVILEGED_INSTRUCTION : std_ulogic_vector(2 downto 0) := "010";
  constant NONCACHEABLE_PRIVILEGED_DATA        : std_ulogic_vector(2 downto 0) := "011";
  constant CACHEABLE_USER_INSTRUCTION          : std_ulogic_vector(2 downto 0) := "100";
  constant CACHEABLE_USER_DATA                 : std_ulogic_vector(2 downto 0) := "101";
  constant CACHEABLE_PRIVILEGED_INSTRUCTION    : std_ulogic_vector(2 downto 0) := "110";
  constant CACHEABLE_PRIVILEGED_DATA           : std_ulogic_vector(2 downto 0) := "111";

  --One Debug Unit per Hardware Thread (hart)
  constant DU_ADDR_SIZE : integer := 12;  -- 12bit internal address bus

  constant MAX_BREAKPOINTS : integer := 8;

  --  * Debug Unit Memory Map
  --  *
  --  * addr_bits  Description
  --  * ------------------------------
  --  * 15-12      Debug bank
  --  * 11- 0      Address inside bank

  --  * Bank0      Control & Status
  --  * Bank1      GPRs
  --  * Bank2      CSRs
  --  * Bank3-15   reserved

  constant DBG_INTERNAL : std_ulogic_vector(15 downto 12) := X"0";
  constant DBG_GPRS     : std_ulogic_vector(15 downto 12) := X"1";
  constant DBG_CSRS     : std_ulogic_vector(15 downto 12) := X"2";

  --  * Control registers
  --  * 0 00 00 ctrl
  --  * 0 00 01
  --  * 0 00 10 ie
  --  * 0 00 11 cause
  --  *  reserved
  --  *
  --  * 1 0000 BP0 Ctrl
  --  * 1 0001 BP0 Data
  --  * 1 0010 BP1 Ctrl
  --  * 1 0011 BP1 Data
  --  * ...
  --  * 1 1110 BP7 Ctrl
  --  * 1 1111 BP7 Data

  constant DBG_CTRL    : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"000";  --debug control
  constant DBG_HIT     : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"001";  --debug HIT register
  constant DBG_IE      : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"002";  --debug interrupt enable (which exception halts the CPU?)
  constant DBG_CAUSE   : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"003";  --debug cause (which exception halted the CPU?)
  constant DBG_BPCTRL0 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"010";  --hardware breakpoint0 control
  constant DBG_BPDATA0 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"011";  --hardware breakpoint0 data
  constant DBG_BPCTRL1 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"012";  --hardware breakpoint1 control
  constant DBG_BPDATA1 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"013";  --hardware breakpoint1 data
  constant DBG_BPCTRL2 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"014";  --hardware breakpoint2 control
  constant DBG_BPDATA2 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"015";  --hardware breakpoint2 data
  constant DBG_BPCTRL3 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"016";  --hardware breakpoint3 control
  constant DBG_BPDATA3 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"017";  --hardware breakpoint3 data
  constant DBG_BPCTRL4 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"018";  --hardware breakpoint4 control
  constant DBG_BPDATA4 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"019";  --hardware breakpoint4 data
  constant DBG_BPCTRL5 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"01A";  --hardware breakpoint5 control
  constant DBG_BPDATA5 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"01B";  --hardware breakpoint5 data
  constant DBG_BPCTRL6 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"01C";  --hardware breakpoint6 control
  constant DBG_BPDATA6 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"01D";  --hardware breakpoint6 data
  constant DBG_BPCTRL7 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"01E";  --hardware breakpoint7 control
  constant DBG_BPDATA7 : std_ulogic_vector(DU_ADDR_SIZE-1 downto 0) := X"01F";  --hardware breakpoint7 data

  --Debug Codes
  constant DEBUG_SINGLE_STEP_TRACE : integer := 0;
  constant DEBUG_BRANCH_TRACE      : integer := 1;
  constant BP_CTRL_IMP             : integer := 0;
  constant BP_CTRL_ENA             : integer := 1;

  constant BP_CTRL_CC_FETCH        : std_ulogic_vector(2 downto 0) := "000";
  constant BP_CTRL_CC_LD_ADR       : std_ulogic_vector(2 downto 0) := "001";
  constant BP_CTRL_CC_ST_ADR       : std_ulogic_vector(2 downto 0) := "010";
  constant BP_CTRL_CC_LDST_ADR     : std_ulogic_vector(2 downto 0) := "100";

  --  * addr         Key  Description
  --  * --------------------------------------------
  --  * 0x000-0x01f  GPR  General Purpose Registers
  --  * 0x100-0x11f  FPR  Floating Point Registers
  --  * 0x200        PC   Program Counter
  --  * 0x201        PPC  Previous Program Counter

  constant DBG_GPR : std_ulogic_vector(11 downto 0) := "0000000XXXXX";
  constant DBG_FPR : std_ulogic_vector(11 downto 0) := "0001000XXXXX";
  constant DBG_NPC : std_ulogic_vector(11 downto 0) := X"200";
  constant DBG_PPC : std_ulogic_vector(11 downto 0) := X"201";

  --  * Bank2 - CSRs
  --  *
  --  * Direct mapping to the 12bit CSR address space

  --RISCV Opcodes Package
  constant ILEN      : integer := 64;
  constant INSTR_NOP : std_ulogic_vector(ILEN-1 downto 0) := X"0000000000000013";

  --Opcodes
  constant OPC_LOAD     : std_ulogic_vector(6 downto 2) := "00000";
  constant OPC_LOAD_FP  : std_ulogic_vector(6 downto 2) := "00001";
  constant OPC_MISC_MEM : std_ulogic_vector(6 downto 2) := "00011";
  constant OPC_OP_IMM   : std_ulogic_vector(6 downto 2) := "00100";
  constant OPC_AUIPC    : std_ulogic_vector(6 downto 2) := "00101";
  constant OPC_OP_IMM32 : std_ulogic_vector(6 downto 2) := "00110";
  constant OPC_STORE    : std_ulogic_vector(6 downto 2) := "01000";
  constant OPC_STORE_FP : std_ulogic_vector(6 downto 2) := "01001";
  constant OPC_AMO      : std_ulogic_vector(6 downto 2) := "01011";
  constant OPC_OP       : std_ulogic_vector(6 downto 2) := "01100";
  constant OPC_LUI      : std_ulogic_vector(6 downto 2) := "01101";
  constant OPC_OP32     : std_ulogic_vector(6 downto 2) := "01110";
  constant OPC_MADD     : std_ulogic_vector(6 downto 2) := "10000";
  constant OPC_MSUB     : std_ulogic_vector(6 downto 2) := "10001";
  constant OPC_NMSUB    : std_ulogic_vector(6 downto 2) := "10010";
  constant OPC_NMADD    : std_ulogic_vector(6 downto 2) := "10011";
  constant OPC_OP_FP    : std_ulogic_vector(6 downto 2) := "10100";
  constant OPC_BRANCH   : std_ulogic_vector(6 downto 2) := "11000";
  constant OPC_JALR     : std_ulogic_vector(6 downto 2) := "11001";
  constant OPC_JAL      : std_ulogic_vector(6 downto 2) := "11011";
  constant OPC_SYSTEM   : std_ulogic_vector(6 downto 2) := "11100";

  constant OPC00_LOAD   : std_ulogic_vector(6 downto 0) := "0000000";
  constant OPC00_STORE  : std_ulogic_vector(6 downto 0) := "0001000";

  constant OPC0_BRANCH  : std_ulogic_vector(7 downto 2) := "011000";
  constant OPC0_JAL     : std_ulogic_vector(7 downto 2) := "001011";
  constant OPC0_JALR    : std_ulogic_vector(7 downto 2) := "011001";

  --RV32/RV64 Base instructions
  constant LUI   : std_ulogic_vector(15 downto 0) := "XXXXXXXXXXX01101";
  constant AUIPC : std_ulogic_vector(15 downto 0) := "XXXXXXXXXXX00101";
  constant JAL   : std_ulogic_vector(15 downto 0) := "XXXXXXXXXXX11011";
  constant JALR  : std_ulogic_vector(15 downto 0) := "XXXXXXXX00011001";
  constant BEQ   : std_ulogic_vector(15 downto 0) := "XXXXXXXX00011000";
  constant BNE   : std_ulogic_vector(15 downto 0) := "XXXXXXXX00111000";
  constant BLT   : std_ulogic_vector(15 downto 0) := "XXXXXXXX10011000";
  constant BGE   : std_ulogic_vector(15 downto 0) := "XXXXXXXX10111000";
  constant BLTU  : std_ulogic_vector(15 downto 0) := "XXXXXXXX11011000";
  constant BGEU  : std_ulogic_vector(15 downto 0) := "XXXXXXXX11111000";
  constant LB    : std_ulogic_vector(15 downto 0) := "XXXXXXXX00000000";
  constant LH    : std_ulogic_vector(15 downto 0) := "XXXXXXXX00100000";
  constant LW    : std_ulogic_vector(15 downto 0) := "XXXXXXXX01000000";
  constant LBU   : std_ulogic_vector(15 downto 0) := "XXXXXXXX10000000";
  constant LHU   : std_ulogic_vector(15 downto 0) := "XXXXXXXX10100000";
  constant LWU   : std_ulogic_vector(15 downto 0) := "XXXXXXXX11000000";
  constant LD    : std_ulogic_vector(15 downto 0) := "XXXXXXXX01100000";
  constant SB    : std_ulogic_vector(15 downto 0) := "XXXXXXXX00001000";
  constant SH    : std_ulogic_vector(15 downto 0) := "XXXXXXXX00101000";
  constant SW    : std_ulogic_vector(15 downto 0) := "XXXXXXXX01001000";
  constant SD    : std_ulogic_vector(15 downto 0) := "XXXXXXXX01101000";
  constant ADDI  : std_ulogic_vector(15 downto 0) := "XXXXXXXX00000100";
  constant ADDIW : std_ulogic_vector(15 downto 0) := "0XXXXXXX00000110";
  constant ADDX  : std_ulogic_vector(15 downto 0) := "X000000000001100";
  constant ADDW  : std_ulogic_vector(15 downto 0) := "0000000000001110";
  constant SUBX  : std_ulogic_vector(15 downto 0) := "X010000000001100";
  constant SUBW  : std_ulogic_vector(15 downto 0) := "0010000000001110";
  constant XORI  : std_ulogic_vector(15 downto 0) := "XXXXXXXX10000100";
  constant XORX  : std_ulogic_vector(15 downto 0) := "X000000010001100";
  constant ORI   : std_ulogic_vector(15 downto 0) := "XXXXXXXX11000100";
  constant ORX   : std_ulogic_vector(15 downto 0) := "X000000011001100";
  constant ANDI  : std_ulogic_vector(15 downto 0) := "XXXXXXXX11100100";
  constant ANDX  : std_ulogic_vector(15 downto 0) := "X000000011101100";
  constant SLLI  : std_ulogic_vector(15 downto 0) := "X000000X00100100";
  constant SLLIW : std_ulogic_vector(15 downto 0) := "0000000000100110";
  constant SLLX  : std_ulogic_vector(15 downto 0) := "X000000000101100";
  constant SLLW  : std_ulogic_vector(15 downto 0) := "0000000000101110";
  constant SLTI  : std_ulogic_vector(15 downto 0) := "XXXXXXXX01000100";
  constant SLT   : std_ulogic_vector(15 downto 0) := "X000000001001100";
  constant SLTU  : std_ulogic_vector(15 downto 0) := "X000000001101100";
  constant SLTIU : std_ulogic_vector(15 downto 0) := "XXXXXXXX01100100";
  constant SRLI  : std_ulogic_vector(15 downto 0) := "X000000X10100100";
  constant SRLIW : std_ulogic_vector(15 downto 0) := "0000000010100110";
  constant SRLX  : std_ulogic_vector(15 downto 0) := "X000000010101100";
  constant SRLW  : std_ulogic_vector(15 downto 0) := "0000000010101110";
  constant SRAI  : std_ulogic_vector(15 downto 0) := "X010000X10100100";
  constant SRAIW : std_ulogic_vector(15 downto 0) := "0010000010100110";
  constant SRAX  : std_ulogic_vector(15 downto 0) := "X010000010101100";
  constant SRAW  : std_ulogic_vector(15 downto 0) := "X010000010101110";

  --pseudo instructions
  constant SYSTEM  : std_ulogic_vector(15 downto 0) := "0XXXXXXX00011100";  --excludes RDxxx instructions
  constant MISCMEM : std_ulogic_vector(15 downto 0) := "0XXXXXXXXXX00011";

  --SYSTEM/MISC_MEM opcodes
  constant FENCE     : std_ulogic_vector(63 downto 0) := "000000000000000000000000000000000000XXXXXXXX00000000000000001111";
  constant SFENCE_VM : std_ulogic_vector(63 downto 0) := "00000000000000000000000000000000000100000100XXXXX000000001110011";
  constant FENCE_I   : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000001000000001111";
  constant ECALL     : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000000000001110011";
  constant EBREAK    : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000000000000100000000000001110011";
  constant MRET      : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000110000001000000000000001110011";
  constant HRET      : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000100000001000000000000001110011";
  constant SRET      : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000010000001000000000000001110011";
  constant URET      : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000000000001000000000000001110011";
  constant MRTS      : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000110000010100000000000001110011";
  constant MRTH      : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000110000011000000000000001110011";
  constant HRTS      : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000100000010100000000000001110011";

  constant WFI       : std_ulogic_vector(63 downto 0) := "0000000000000000000000000000000000010000010100000000000001110011";

  constant CSRRW  : std_ulogic_vector(15 downto 0) := "0XXXXXXX00111100";
  constant CSRRS  : std_ulogic_vector(15 downto 0) := "0XXXXXXX01011100";
  constant CSRRC  : std_ulogic_vector(15 downto 0) := "0XXXXXXX01111100";
  constant CSRRWI : std_ulogic_vector(15 downto 0) := "0XXXXXXX10111100";
  constant CSRRSI : std_ulogic_vector(15 downto 0) := "0XXXXXXX11011100";
  constant CSRRCI : std_ulogic_vector(15 downto 0) := "0XXXXXXX11111100";

  --RV32/RV64 A-Extensions instructions
  constant LRW      : std_ulogic_vector(14 downto 0) := "00010XX01001011";
  constant SCW      : std_ulogic_vector(14 downto 0) := "00011XX01001011";
  constant AMOSWAPW : std_ulogic_vector(14 downto 0) := "00001XX01001011";
  constant AMOADDW  : std_ulogic_vector(14 downto 0) := "00000XX01001011";
  constant AMOXORW  : std_ulogic_vector(14 downto 0) := "00100XX01001011";
  constant AMOANDW  : std_ulogic_vector(14 downto 0) := "01100XX01001011";
  constant AMOORW   : std_ulogic_vector(14 downto 0) := "01000XX01001011";
  constant AMOMINW  : std_ulogic_vector(14 downto 0) := "10000XX01001011";
  constant AMOMAXW  : std_ulogic_vector(14 downto 0) := "10100XX01001011";
  constant AMOMINUW : std_ulogic_vector(14 downto 0) := "11000XX01001011";
  constant AMOMAXUW : std_ulogic_vector(14 downto 0) := "11100XX01001011";

  constant LRD      : std_ulogic_vector(14 downto 0) := "00010XX01101011";
  constant SCD      : std_ulogic_vector(14 downto 0) := "00011XX01101011";
  constant AMOSWAPD : std_ulogic_vector(14 downto 0) := "00001XX01101011";
  constant AMOADDD  : std_ulogic_vector(14 downto 0) := "00000XX01101011";
  constant AMOXORD  : std_ulogic_vector(14 downto 0) := "00100XX01101011";
  constant AMOANDD  : std_ulogic_vector(14 downto 0) := "01100XX01101011";
  constant AMOORD   : std_ulogic_vector(14 downto 0) := "01000XX01101011";
  constant AMOMIND  : std_ulogic_vector(14 downto 0) := "10000XX01101011";
  constant AMOMAXD  : std_ulogic_vector(14 downto 0) := "10100XX01101011";
  constant AMOMINUD : std_ulogic_vector(14 downto 0) := "11000XX01101011";
  constant AMOMAXUD : std_ulogic_vector(14 downto 0) := "11100XX01101011";

  --RV32/RV64 M-Extensions instructions
  constant MUL    : std_ulogic_vector(15 downto 0) := "X000000100001100";
  constant MULH   : std_ulogic_vector(15 downto 0) := "X000000100101100";
  constant MULW   : std_ulogic_vector(15 downto 0) := "X000000100001110";
  constant MULHSU : std_ulogic_vector(15 downto 0) := "X000000101001100";
  constant MULHU  : std_ulogic_vector(15 downto 0) := "X000000101101100";
  constant DIV    : std_ulogic_vector(15 downto 0) := "X000000110001100";
  constant DIVW   : std_ulogic_vector(15 downto 0) := "0000000110001110";
  constant DIVU   : std_ulogic_vector(15 downto 0) := "X000000110101100";
  constant DIVUW  : std_ulogic_vector(15 downto 0) := "0000000110101110";
  constant REMX   : std_ulogic_vector(15 downto 0) := "X000000111001100";
  constant REMW   : std_ulogic_vector(15 downto 0) := "0000000111001110";
  constant REMU   : std_ulogic_vector(15 downto 0) := "X000000111101100";
  constant REMUW  : std_ulogic_vector(15 downto 0) := "0000000111101110";

  --Per Supervisor Spec draft 1.10

  --PMP-CFG Register
  constant OFF   : std_ulogic_vector(1 downto 0) := "00";
  constant TOR   : std_ulogic_vector(1 downto 0) := "01";
  constant NA4   : std_ulogic_vector(1 downto 0) := "10";
  constant NAPOT : std_ulogic_vector(1 downto 0) := "11";

  constant PMPCFG_MASK : std_ulogic_vector(7 downto 0) := X"9F";

  --CSR mapping
  --User
  --User Trap Setup
  constant USTATUS      : std_ulogic_vector(11 downto 0) := X"000";
  constant UIE          : std_ulogic_vector(11 downto 0) := X"004";
  constant UTVEC        : std_ulogic_vector(11 downto 0) := X"005";
  --User Trap Handling
  constant USCRATCH     : std_ulogic_vector(11 downto 0) := X"040";
  constant UEPC         : std_ulogic_vector(11 downto 0) := X"041";
  constant UCAUSE       : std_ulogic_vector(11 downto 0) := X"042";
  constant UBADADDR     : std_ulogic_vector(11 downto 0) := X"043";
  constant UTVAL        : std_ulogic_vector(11 downto 0) := X"043";
  constant UIP          : std_ulogic_vector(11 downto 0) := X"044";
  --User Floating-Point CSRs
  constant FFLAGS       : std_ulogic_vector(11 downto 0) := X"001";
  constant FRM          : std_ulogic_vector(11 downto 0) := X"002";
  constant FCSR         : std_ulogic_vector(11 downto 0) := X"003";
  --User Counters/Timers
  constant CYCLE        : std_ulogic_vector(11 downto 0) := X"C00";
  constant TIMEX        : std_ulogic_vector(11 downto 0) := X"C01";
  constant INSTRET      : std_ulogic_vector(11 downto 0) := X"C02";
  constant HPMCOUNTER3  : std_ulogic_vector(11 downto 0) := X"C03";  --until HPMCOUNTER31='hC1F
  constant CYCLEH       : std_ulogic_vector(11 downto 0) := X"C80";
  constant TIMEH        : std_ulogic_vector(11 downto 0) := X"C81";
  constant INSTRETH     : std_ulogic_vector(11 downto 0) := X"C82";
  constant HPMCOUNTER3H : std_ulogic_vector(11 downto 0) := X"C83";  --until HPMCONTER31='hC9F

  --Supervisor
  --Supervisor Trap Setup
  constant SSTATUS    : std_ulogic_vector(11 downto 0) := X"100";
  constant SEDELEG    : std_ulogic_vector(11 downto 0) := X"102";
  constant SIDELEG    : std_ulogic_vector(11 downto 0) := X"103";
  constant SIE        : std_ulogic_vector(11 downto 0) := X"104";
  constant STVEC      : std_ulogic_vector(11 downto 0) := X"105";
  constant SCOUNTEREN : std_ulogic_vector(11 downto 0) := X"106";
  --Supervisor Trap Handling
  constant SSCRATCH   : std_ulogic_vector(11 downto 0) := X"140";
  constant SEPC       : std_ulogic_vector(11 downto 0) := X"141";
  constant SCAUSE     : std_ulogic_vector(11 downto 0) := X"142";
  constant STVAL      : std_ulogic_vector(11 downto 0) := X"143";
  constant SIP        : std_ulogic_vector(11 downto 0) := X"144";
  --Supervisor Protection and Translation
  constant SATP       : std_ulogic_vector(11 downto 0) := X"180";

  --Hypervisor
  --Hypervisor trap setup
  constant HSTATUS    : std_ulogic_vector(11 downto 0) := X"200";
  constant HEDELEG    : std_ulogic_vector(11 downto 0) := X"202";
  constant HIDELEG    : std_ulogic_vector(11 downto 0) := X"203";
  constant HIE        : std_ulogic_vector(11 downto 0) := X"204";
  constant HTVEC      : std_ulogic_vector(11 downto 0) := X"205";
  --Hypervisor Trap Handling
  constant HSCRATCH   : std_ulogic_vector(11 downto 0) := X"240";
  constant HEPC       : std_ulogic_vector(11 downto 0) := X"241";
  constant HCAUSE     : std_ulogic_vector(11 downto 0) := X"242";
  constant HTVAL      : std_ulogic_vector(11 downto 0) := X"243";
  constant HIP        : std_ulogic_vector(11 downto 0) := X"244";

  --Machine
  --Machine Information
  constant MVENDORID  : std_ulogic_vector(11 downto 0) := X"F11";
  constant MARCHID    : std_ulogic_vector(11 downto 0) := X"F12";
  constant MIMPID     : std_ulogic_vector(11 downto 0) := X"F13";
  constant MHARTID    : std_ulogic_vector(11 downto 0) := X"F14";
  --Machine Trap Setup
  constant MSTATUS    : std_ulogic_vector(11 downto 0) := X"300";
  constant MISA       : std_ulogic_vector(11 downto 0) := X"301";
  constant MEDELEG    : std_ulogic_vector(11 downto 0) := X"302";
  constant MIDELEG    : std_ulogic_vector(11 downto 0) := X"303";
  constant MIE        : std_ulogic_vector(11 downto 0) := X"304";
  constant MNMIVEC    : std_ulogic_vector(11 downto 0) := X"7C0";  --ROALOGIC NMI Vector
  constant MTVEC      : std_ulogic_vector(11 downto 0) := X"305";
  constant MCOUNTEREN : std_ulogic_vector(11 downto 0) := X"306";
  --Machine Trap Handling
  constant MSCRATCH   : std_ulogic_vector(11 downto 0) := X"340";
  constant MEPC       : std_ulogic_vector(11 downto 0) := X"341";
  constant MCAUSE     : std_ulogic_vector(11 downto 0) := X"342";
  constant MTVAL      : std_ulogic_vector(11 downto 0) := X"343";
  constant MIP        : std_ulogic_vector(11 downto 0) := X"344";
  --Machine Protection and Translation
  constant PMPCFG0    : std_ulogic_vector(11 downto 0) := X"3A0";
  constant PMPCFG1    : std_ulogic_vector(11 downto 0) := X"3A1";  --RV32 only
  constant PMPCFG2    : std_ulogic_vector(11 downto 0) := X"3A2";
  constant PMPCFG3    : std_ulogic_vector(11 downto 0) := X"3A3";  --RV32 only
  constant PMPADDR0   : std_ulogic_vector(11 downto 0) := X"3B0";
  constant PMPADDR1   : std_ulogic_vector(11 downto 0) := X"3B1";
  constant PMPADDR2   : std_ulogic_vector(11 downto 0) := X"3B2";
  constant PMPADDR3   : std_ulogic_vector(11 downto 0) := X"3B3";
  constant PMPADDR4   : std_ulogic_vector(11 downto 0) := X"3B4";
  constant PMPADDR5   : std_ulogic_vector(11 downto 0) := X"3B5";
  constant PMPADDR6   : std_ulogic_vector(11 downto 0) := X"3B6";
  constant PMPADDR7   : std_ulogic_vector(11 downto 0) := X"3B7";
  constant PMPADDR8   : std_ulogic_vector(11 downto 0) := X"3B8";
  constant PMPADDR9   : std_ulogic_vector(11 downto 0) := X"3B9";
  constant PMPADDR10  : std_ulogic_vector(11 downto 0) := X"3BA";
  constant PMPADDR11  : std_ulogic_vector(11 downto 0) := X"3BB";
  constant PMPADDR12  : std_ulogic_vector(11 downto 0) := X"3BC";
  constant PMPADDR13  : std_ulogic_vector(11 downto 0) := X"3BD";
  constant PMPADDR14  : std_ulogic_vector(11 downto 0) := X"3BE";
  constant PMPADDR15  : std_ulogic_vector(11 downto 0) := X"3BF";

  --Machine Counters/Timers
  constant MCYCLE        : std_ulogic_vector(11 downto 0) := X"B00";
  constant MINSTRET      : std_ulogic_vector(11 downto 0) := X"B02";
  constant MHPMCOUNTER3  : std_ulogic_vector(11 downto 0) := X"B03";  --until MHPMCOUNTER31='hB1F
  constant MCYCLEH       : std_ulogic_vector(11 downto 0) := X"B80";
  constant MINSTRETH     : std_ulogic_vector(11 downto 0) := X"B82";
  constant MHPMCOUNTER3H : std_ulogic_vector(11 downto 0) := X"B83";  --until MHPMCOUNTER31H='hB9F

  --Machine Counter Setup
  constant MHPEVENT3 : std_ulogic_vector(11 downto 0) := X"323";  --until MHPEVENT31 = 'h33f

  --Debug
  constant TSELECT  : std_ulogic_vector(11 downto 0) := X"7A0";
  constant TDATA1   : std_ulogic_vector(11 downto 0) := X"7A1";
  constant TDATA2   : std_ulogic_vector(11 downto 0) := X"7A2";
  constant TDATA3   : std_ulogic_vector(11 downto 0) := X"7A3";
  constant DCSR     : std_ulogic_vector(11 downto 0) := X"7B0";
  constant DPC      : std_ulogic_vector(11 downto 0) := X"7B1";
  constant DSCRATCH : std_ulogic_vector(11 downto 0) := X"7B2";

  --MXL mapping
  constant RV32I  : std_ulogic_vector(1 downto 0) := "01";
  constant RV32E  : std_ulogic_vector(1 downto 0) := "01";
  constant RV64I  : std_ulogic_vector(1 downto 0) := "10";
  constant RV128I : std_ulogic_vector(1 downto 0) := "11";

  --Privilege Levels
  constant PRV_M : std_ulogic_vector(1 downto 0) := "11";
  constant PRV_H : std_ulogic_vector(1 downto 0) := "10";
  constant PRV_S : std_ulogic_vector(1 downto 0) := "01";
  constant PRV_U : std_ulogic_vector(1 downto 0) := "00";

  --Virtualisation
  constant VM_MBARE : std_ulogic_vector(3 downto 0) := "0000";
  constant VM_SV32  : std_ulogic_vector(3 downto 0) := "0001";
  constant VM_SV39  : std_ulogic_vector(3 downto 0) := "1000";
  constant VM_SV48  : std_ulogic_vector(3 downto 0) := "1001";
  constant VM_SV57  : std_ulogic_vector(3 downto 0) := "1010";
  constant VM_SV64  : std_ulogic_vector(3 downto 0) := "1011";

  --MIE MIP
  constant MEI : integer := 11;
  constant HEI : integer := 10;
  constant SEI : integer := 9;
  constant UEI : integer := 8;
  constant MTI : integer := 7;
  constant HTI : integer := 6;
  constant STI : integer := 5;
  constant UTI : integer := 4;
  constant MSI : integer := 3;
  constant HSI : integer := 2;
  constant SSI : integer := 1;
  constant USI : integer := 0;

  --Performance Counters
  constant CY : integer := 0;
  constant TM : integer := 1;
  constant IR : integer := 2;

  --Exception Causes
  constant EXCEPTION_SIZE : integer := 16;

  constant CAUSE_MISALIGNED_INSTRUCTION   : integer := 0;
  constant CAUSE_INSTRUCTION_ACCESS_FAULT : integer := 1;
  constant CAUSE_ILLEGAL_INSTRUCTION      : integer := 2;
  constant CAUSE_BREAKPOINT               : integer := 3;
  constant CAUSE_MISALIGNED_LOAD          : integer := 4;
  constant CAUSE_LOAD_ACCESS_FAULT        : integer := 5;
  constant CAUSE_MISALIGNED_STORE         : integer := 6;
  constant CAUSE_STORE_ACCESS_FAULT       : integer := 7;
  constant CAUSE_UMODE_ECALL              : integer := 8;
  constant CAUSE_SMODE_ECALL              : integer := 9;
  constant CAUSE_HMODE_ECALL              : integer := 10;
  constant CAUSE_MMODE_ECALL              : integer := 11;
  constant CAUSE_INSTRUCTION_PAGE_FAULT   : integer := 12;
  constant CAUSE_LOAD_PAGE_FAULT          : integer := 13;
  constant CAUSE_STORE_PAGE_FAULT         : integer := 15;

  constant CAUSE_USINT : integer := 0;
  constant CAUSE_SSINT : integer := 1;
  constant CAUSE_HSINT : integer := 2;
  constant CAUSE_MSINT : integer := 3;
  constant CAUSE_UTINT : integer := 4;
  constant CAUSE_STINT : integer := 5;
  constant CAUSE_HTINT : integer := 6;
  constant CAUSE_MTINT : integer := 7;
  constant CAUSE_UEINT : integer := 8;
  constant CAUSE_SEINT : integer := 9;
  constant CAUSE_HEINT : integer := 10;
  constant CAUSE_MEINT : integer := 11;

  constant MEM_TYPE_EMPTY : std_ulogic_vector(3 downto 0) := X"0";
  constant MEM_TYPE_MAIN  : std_ulogic_vector(3 downto 0) := X"1";
  constant MEM_TYPE_IO    : std_ulogic_vector(3 downto 0) := X"2";
  constant MEM_TYPE_TCM   : std_ulogic_vector(3 downto 0) := X"3";

  constant AMO_TYPE_NONE       : std_ulogic_vector(3 downto 0) := X"0";
  constant AMO_TYPE_SWAP       : std_ulogic_vector(3 downto 0) := X"1";
  constant AMO_TYPE_LOGICAL    : std_ulogic_vector(3 downto 0) := X"2";
  constant AMO_TYPE_ARITHMETIC : std_ulogic_vector(3 downto 0) := X"3";

  --AHB3 Lite Package

  --HTRANS
  constant HTRANS_IDLE   : std_ulogic_vector(1 downto 0) := "00";
  constant HTRANS_BUSY   : std_ulogic_vector(1 downto 0) := "01";
  constant HTRANS_NONSEQ : std_ulogic_vector(1 downto 0) := "10";
  constant HTRANS_SEQ    : std_ulogic_vector(1 downto 0) := "11";

  --HSIZE
  constant HSIZE_B8    : std_ulogic_vector(2 downto 0) := "000";
  constant HSIZE_B16   : std_ulogic_vector(2 downto 0) := "001";
  constant HSIZE_B32   : std_ulogic_vector(2 downto 0) := "010";
  constant HSIZE_B64   : std_ulogic_vector(2 downto 0) := "011";
  constant HSIZE_B128  : std_ulogic_vector(2 downto 0) := "100";  --4-word line
  constant HSIZE_B256  : std_ulogic_vector(2 downto 0) := "101";  --8-word line
  constant HSIZE_B512  : std_ulogic_vector(2 downto 0) := "110";
  constant HSIZE_B1024 : std_ulogic_vector(2 downto 0) := "111";
  constant HSIZE_BYTE  : std_ulogic_vector(2 downto 0) := HSIZE_B8;
  constant HSIZE_HWORD : std_ulogic_vector(2 downto 0) := HSIZE_B16;
  constant HSIZE_WORD  : std_ulogic_vector(2 downto 0) := HSIZE_B32;
  constant HSIZE_DWORD : std_ulogic_vector(2 downto 0) := HSIZE_B64;

  --HBURST
  constant HBURST_SINGLE : std_ulogic_vector(2 downto 0) := "000";
  constant HBURST_INCR   : std_ulogic_vector(2 downto 0) := "001";
  constant HBURST_WRAP4  : std_ulogic_vector(2 downto 0) := "010";
  constant HBURST_INCR4  : std_ulogic_vector(2 downto 0) := "011";
  constant HBURST_WRAP8  : std_ulogic_vector(2 downto 0) := "100";
  constant HBURST_INCR8  : std_ulogic_vector(2 downto 0) := "101";
  constant HBURST_WRAP16 : std_ulogic_vector(2 downto 0) := "110";
  constant HBURST_INCR16 : std_ulogic_vector(2 downto 0) := "111";

  --HPROT
  constant HPROT_OPCODE         : std_ulogic_vector(3 downto 0) := "0000";
  constant HPROT_DATA           : std_ulogic_vector(3 downto 0) := "0001";
  constant HPROT_USER           : std_ulogic_vector(3 downto 0) := "0000";
  constant HPROT_PRIVILEGED     : std_ulogic_vector(3 downto 0) := "0010";
  constant HPROT_NON_BUFFERABLE : std_ulogic_vector(3 downto 0) := "0000";
  constant HPROT_BUFFERABLE     : std_ulogic_vector(3 downto 0) := "0100";
  constant HPROT_NON_CACHEABLE  : std_ulogic_vector(3 downto 0) := "0000";
  constant HPROT_CACHEABLE      : std_ulogic_vector(3 downto 0) := "1000";

  --HRESP
  constant HRESP_OKAY  : std_ulogic := '0';
  constant HRESP_ERROR : std_ulogic := '1';

end riscv_mpsoc_pkg;
