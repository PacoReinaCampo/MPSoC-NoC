////////////////////////////////////////////////////////////////////////////////
//                                            __ _      _     _               //
//                                           / _(_)    | |   | |              //
//                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
//               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
//              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
//               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
//                  | |                                                       //
//                  |_|                                                       //
//                                                                            //
//                                                                            //
//              MPSoC-RISCV CPU                                               //
//              RISC-V Package                                                //
//              AMBA3 AHB-Lite Bus Interface                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2017-2018 by the author(s)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * =============================================================================
 * Author(s):
 *   Francisco Javier Reina Campo <frareicam@gmail.com>
 */

  //core parameters
  `define XLEN               64
  `define PLEN               64
  `define FLEN               64
  `define PC_INIT            'h8000_0000  //Start here after reset
  `define BASE               PC_INIT      //offset where to load program in memory
  `define INIT_FILE          "test.hex"
  `define MEM_LATENCY        1
  `define HAS_USER           1
  `define HAS_SUPER          1
  `define HAS_HYPER          1
  `define HAS_BPU            1
  `define HAS_FPU            1
  `define HAS_MMU            1
  `define HAS_RVM            1
  `define HAS_RVA            1
  `define HAS_RVC            1
  `define HAS_RVN            1
  `define HAS_RVB            1
  `define HAS_RVT            1
  `define HAS_RVP            1
  `define HAS_EXT            1

  `define IS_RV32E           1

  `define MULT_LATENCY       1

  `define HTIF               0 //Host-interface
  `define TOHOST             32'h80001000
  `define UART_TX            32'h80001080

  `define BREAKPOINTS        8  //Number of hardware breakpoints

  `define PMA_CNT            4
  `define PMP_CNT            16 //Number of Physical Memory Protection entries

  `define BP_GLOBAL_BITS     2
  `define BP_LOCAL_BITS      10
  `define BP_LOCAL_BITS_LSB  2 

  `define ICACHE_SIZE        64 //in KBytes
  `define ICACHE_BLOCK_SIZE  64 //in Bytes
  `define ICACHE_WAYS        2  //'n'-way set associative
  `define ICACHE_REPLACE_ALG 0
  `define ITCM_SIZE          0

  `define DCACHE_SIZE        64 //in KBytes
  `define DCACHE_BLOCK_SIZE  64 //in Bytes
  `define DCACHE_WAYS        2  //'n'-way set associative
  `define DCACHE_REPLACE_ALG 0
  `define DTCM_SIZE          0
  `define WRITEBUFFER_SIZE   8

  `define TECHNOLOGY         "GENERIC"
  `define AVOID_X            0

  `define MNMIVEC_DEFAULT    PC_INIT - 'h004
  `define MTVEC_DEFAULT      PC_INIT - 'h040
  `define HTVEC_DEFAULT      PC_INIT - 'h080
  `define STVEC_DEFAULT      PC_INIT - 'h0C0
  `define UTVEC_DEFAULT      PC_INIT - 'h100

  `define JEDEC_BANK            10
  `define JEDEC_MANUFACTURER_ID 'h6e

  `define HARTID             0

  `define PARCEL_SIZE        32

  `define HADDR_SIZE         XLEN
  `define HDATA_SIZE         PLEN
  `define PADDR_SIZE         PLEN
  `define PDATA_SIZE         XLEN

  `define SYNC_DEPTH         3

  `define BUFFER_DEPTH       4

  //RF access
  `define RDPORTS            1
  `define WRPORTS            1
  `define AR_BITS            5

  //mpsoc parameters
  `define CORES_PER_SIMD     3
  `define CORES_PER_MISD     2

  `define CORES_PER_TILE     `CORES_PER_SIMD + `CORES_PER_MISD

  //soc parameters
  `define X                  2
  `define Y                  1
  `define Z                  2

  `define NODES              `X*`Y*`Z
  `define CORES              `NODES*`CORES_PER_TILE

  //noc parameters
  `define CHANNELS           2
  `define PCHANNELS          2
  `define VCHANNELS          2

  `define ENABLE_VCHANNELS   1

  `define ROUTER_BUFFER_SIZE 2
  `define REG_ADDR_WIDTH     2
  `define VALWIDTH           2
  `define MAX_PKT_LEN        2

  `define TILE_ID            0
  `define GENERATE_INTERRUPT 1
  `define TABLE_ENTRIES      4
  `define NOC_PACKET_SIZE    16

  `define TABLE_ENTRIES_PTRWIDTH $clog2(TABLE_ENTRIES)

  //debug parameters
  `define STDOUT_FILENAME    "stdout"
  `define TRACEFILE_FILENAME "trace"

  `define ENABLE_TRACE       4
  `define TERM_CROSS_NUM     NODES

  `define GLIP_PORT          23000
  `define GLIP_UART_LIKE     0

  //RV12 Definitions Package
  `define ARCHID       12
  `define REVPRV_MAJOR 1
  `define REVPRV_MINOR 10
  `define REVUSR_MAJOR 2
  `define REVUSR_MINOR 2

  //BIU Constants Package
  `define BYTE       3'b000
  `define HWORD      3'b001
  `define WORD       3'b010
  `define DWORD      3'b011
  `define QWORD      3'b100
  `define UNDEF_SIZE 3'bxxx

  `define SINGLE      3'b000
  `define INCR        3'b001
  `define WRAP4       3'b010
  `define INCR4       3'b011
  `define WRAP8       3'b100
  `define INCR8       3'b101
  `define WRAP16      3'b110
  `define INCR16      3'b111
  `define UNDEF_BURST 3'bxxx

  //Enumeration Codes
  `define PROT_INSTRUCTION  3'b000
  `define PROT_DATA         3'b001
  `define PROT_USER         3'b000
  `define PROT_PRIVILEGED   3'b010
  `define PROT_NONCACHEABLE 3'b000
  `define PROT_CACHEABLE    3'b100

  //Complex Enumerations
  `define NONCACHEABLE_USER_INSTRUCTION       3'b000
  `define NONCACHEABLE_USER_DATA              3'b001
  `define NONCACHEABLE_PRIVILEGED_INSTRUCTION 3'b010
  `define NONCACHEABLE_PRIVILEGED_DATA        3'b011
  `define CACHEABLE_USER_INSTRUCTION          3'b100
  `define CACHEABLE_USER_DATA                 3'b101
  `define CACHEABLE_PRIVILEGED_INSTRUCTION    3'b110
  `define CACHEABLE_PRIVILEGED_DATA           3'b111

  //One Debug Unit per Hardware Thread (hart)
  `define DU_ADDR_SIZE  12  // 12bit internal address bus

  `define MAX_BREAKPOINTS 8

 /*
  * Debug Unit Memory Map
  *
  * addr_bits  Description
  * ------------------------------
  * 15-12      Debug bank
  * 11- 0      Address inside bank

  * Bank0      Control & Status
  * Bank1      GPRs
  * Bank2      CSRs
  * Bank3-15   reserved
  */

  `define DBG_INTERNAL 4'h0
  `define DBG_GPRS     4'h1
  `define DBG_CSRS     4'h2

 /*
  * Control registers
  * 0 00 00 ctrl
  * 0 00 01
  * 0 00 10 ie
  * 0 00 11 cause
  *  reserved
  *
  * 1 0000 BP0 Ctrl
  * 1 0001 BP0 Data
  * 1 0010 BP1 Ctrl
  * 1 0011 BP1 Data
  * ...
  * 1 1110 BP7 Ctrl
  * 1 1111 BP7 Data
  */

  `define DBG_CTRL    'h00  //debug control
  `define DBG_HIT     'h01  //debug HIT register
  `define DBG_IE      'h02  //debug interrupt enable (which exception halts the CPU?)
  `define DBG_CAUSE   'h03  //debug cause (which exception halted the CPU?)
  `define DBG_BPCTRL0 'h10  //hardware breakpoint0 control
  `define DBG_BPDATA0 'h11  //hardware breakpoint0 data
  `define DBG_BPCTRL1 'h12  //hardware breakpoint1 control
  `define DBG_BPDATA1 'h13  //hardware breakpoint1 data
  `define DBG_BPCTRL2 'h14  //hardware breakpoint2 control
  `define DBG_BPDATA2 'h15  //hardware breakpoint2 data
  `define DBG_BPCTRL3 'h16  //hardware breakpoint3 control
  `define DBG_BPDATA3 'h17  //hardware breakpoint3 data
  `define DBG_BPCTRL4 'h18  //hardware breakpoint4 control
  `define DBG_BPDATA4 'h19  //hardware breakpoint4 data
  `define DBG_BPCTRL5 'h1a  //hardware breakpoint5 control
  `define DBG_BPDATA5 'h1b  //hardware breakpoint5 data
  `define DBG_BPCTRL6 'h1c  //hardware breakpoint6 control
  `define DBG_BPDATA6 'h1d  //hardware breakpoint6 data
  `define DBG_BPCTRL7 'h1e  //hardware breakpoint7 control
  `define DBG_BPDATA7 'h1f  //hardware breakpoint7 data


  //Debug Codes
  `define       DEBUG_SINGLE_STEP_TRACE 0
  `define       DEBUG_BRANCH_TRACE      1
  
  `define       BP_CTRL_IMP         0
  `define       BP_CTRL_ENA         1
  `define       BP_CTRL_CC_FETCH    3'h0
  `define       BP_CTRL_CC_LD_ADR   3'h1
  `define       BP_CTRL_CC_ST_ADR   3'h2
  `define       BP_CTRL_CC_LDST_ADR 3'h3

 /*
  * addr         Key  Description
  * --------------------------------------------
  * 0x000-0x01f  GPR  General Purpose Registers
  * 0x100-0x11f  FPR  Floating Point Registers
  * 0x200        PC   Program Counter
  * 0x201        PPC  Previous Program Counter
  */

  `define DBG_GPR 12'b0000_000?_????
  `define DBG_FPR 12'b0001_000?_????
  `define DBG_NPC 12'h200
  `define DBG_PPC 12'h201

 /*
  * Bank2 - CSRs
  *
  * Direct mapping to the 12bit CSR address space
  */

  //RISCV Opcodes Package
  `define ILEN      64
  `define INSTR_NOP `ILEN'h13

  //Opcodes
  `define OPC_LOAD     5'b00_000
  `define OPC_LOAD_FP  5'b00_001
  `define OPC_MISC_MEM 5'b00_011
  `define OPC_OP_IMM   5'b00_100 
  `define OPC_AUIPC    5'b00_101
  `define OPC_OP_IMM32 5'b00_110
  `define OPC_STORE    5'b01_000
  `define OPC_STORE_FP 5'b01_001
  `define OPC_AMO      5'b01_011 
  `define OPC_OP       5'b01_100
  `define OPC_LUI      5'b01_101
  `define OPC_OP32     5'b01_110
  `define OPC_MADD     5'b10_000
  `define OPC_MSUB     5'b10_001
  `define OPC_NMSUB    5'b10_010
  `define OPC_NMADD    5'b10_011
  `define OPC_OP_FP    5'b10_100
  `define OPC_BRANCH   5'b11_000
  `define OPC_JALR     5'b11_001
  `define OPC_JAL      5'b11_011
  `define OPC_SYSTEM   5'b11_100

  //RV32/RV64 Base instructions

  //                           f7       f3 opcode
  `define LUI    15'b???????_???_01101
  `define AUIPC  15'b???????_???_00101
  `define JAL    15'b???????_???_11011
  `define JALR   15'b???????_000_11001
  `define BEQ    15'b???????_000_11000
  `define BNE    15'b???????_001_11000
  `define BLT    15'b???????_100_11000
  `define BGE    15'b???????_101_11000
  `define BLTU   15'b???????_110_11000
  `define BGEU   15'b???????_111_11000
  `define LB     15'b???????_000_00000
  `define LH     15'b???????_001_00000
  `define LW     15'b???????_010_00000
  `define LBU    15'b???????_100_00000
  `define LHU    15'b???????_101_00000
  `define LWU    15'b???????_110_00000
  `define LD     15'b???????_011_00000
  `define SB     15'b???????_000_01000
  `define SH     15'b???????_001_01000
  `define SW     15'b???????_010_01000
  `define SD     15'b???????_011_01000
  `define ADDI   15'b???????_000_00100
  `define ADDIW  15'b???????_000_00110
  `define ADD    15'b0000000_000_01100
  `define ADDW   15'b0000000_000_01110
  `define SUB    15'b0100000_000_01100
  `define SUBW   15'b0100000_000_01110
  `define XORI   15'b???????_100_00100
  `define XORX   15'b0000000_100_01100
  `define ORI    15'b???????_110_00100
  `define ORX    15'b0000000_110_01100
  `define ANDI   15'b???????_111_00100
  `define ANDX   15'b0000000_111_01100
  `define SLLI   15'b000000?_001_00100
  `define SLLIW  15'b0000000_001_00110
  `define SLLX   15'b0000000_001_01100
  `define SLLW   15'b0000000_001_01110
  `define SLTI   15'b???????_010_00100
  `define SLT    15'b0000000_010_01100
  `define SLTU   15'b0000000_011_01100
  `define SLTIU  15'b???????_011_00100
  `define SRLI   15'b000000?_101_00100
  `define SRLIW  15'b0000000_101_00110
  `define SRLX   15'b0000000_101_01100
  `define SRLW   15'b0000000_101_01110
  `define SRAI   15'b010000?_101_00100
  `define SRAIW  15'b0100000_101_00110
  `define SRAX   15'b0100000_101_01100
  `define SRAW   15'b0100000_101_01110

                   //pseudo instructions
  `define SYSTEM  15'b???????_000_11100  //excludes RDxxx instructions
  `define MISCMEM 15'b???????_???_00011

  //SYSTEM/MISC_MEM opcodes
  `define FENCE      32'b0000????????_00000_000_00000_0001111
  `define SFENCE_VM  32'b000100000100_?????_000_00000_1110011
  `define FENCE_I    32'b000000000000_00000_001_00000_0001111
  `define ECALL      32'b000000000000_00000_000_00000_1110011
  `define EBREAK     32'b000000000001_00000_000_00000_1110011
  `define MRET       32'b001100000010_00000_000_00000_1110011
  `define HRET       32'b001000000010_00000_000_00000_1110011
  `define SRET       32'b000100000010_00000_000_00000_1110011
  `define URET       32'b000000000010_00000_000_00000_1110011
//`define MRTS       32'b001100000101_00000_000_00000_1110011
//`define MRTH       32'b001100000110_00000_000_00000_1110011
//`define HRTS       32'b001000000101_00000_000_00000_1110011
  `define WFI        32'b000100000101_00000_000_00000_1110011

  //                               f7      f3  opcode
  `define CSRRW      15'b???????_001_11100
  `define CSRRS      15'b???????_010_11100
  `define CSRRC      15'b???????_011_11100
  `define CSRRWI     15'b???????_101_11100
  `define CSRRSI     15'b???????_110_11100
  `define CSRRCI     15'b???????_111_11100

  //RV32/RV64 A-Extensions instructions

  //                             f7       f3 opcode
  `define LRW      15'b00010??_010_01011
  `define SCW      15'b00011??_010_01011
  `define AMOSWAPW 15'b00001??_010_01011
  `define AMOADDW  15'b00000??_010_01011
  `define AMOXORW  15'b00100??_010_01011
  `define AMOANDW  15'b01100??_010_01011
  `define AMOORW   15'b01000??_010_01011
  `define AMOMINW  15'b10000??_010_01011
  `define AMOMAXW  15'b10100??_010_01011
  `define AMOMINUW 15'b11000??_010_01011
  `define AMOMAXUW 15'b11100??_010_01011

  `define LRD      15'b00010??_011_01011
  `define SCD      15'b00011??_011_01011
  `define AMOSWAPD 15'b00001??_011_01011
  `define AMOADDD  15'b00000??_011_01011
  `define AMOXORD  15'b00100??_011_01011
  `define AMOANDD  15'b01100??_011_01011
  `define AMOORD   15'b01000??_011_01011
  `define AMOMIND  15'b10000??_011_01011
  `define AMOMAXD  15'b10100??_011_01011
  `define AMOMINUD 15'b11000??_011_01011
  `define AMOMAXUD 15'b11100??_011_01011

  //RV32/RV64 M-Extensions instructions

  //                            f7       f3 opcode
  `define MUL    15'b0000001_000_01100
  `define MULH   15'b0000001_001_01100
  `define MULW   15'b0000001_000_01110
  `define MULHSU 15'b0000001_010_01100
  `define MULHU  15'b0000001_011_01100
  `define DIV    15'b0000001_100_01100
  `define DIVW   15'b0000001_100_01110
  `define DIVU   15'b0000001_101_01100
  `define DIVUW  15'b0000001_101_01110
  `define REM    15'b0000001_110_01100
  `define REMW   15'b0000001_110_01110
  `define REMU   15'b0000001_111_01100
  `define REMUW  15'b0000001_111_01110

  //Per Supervisor Spec draft 1.10

  //PMP-CFG Register
  `define OFF   2'd0
  `define TOR   2'd1
  `define NA4   2'd2
  `define NAPOT 2'd3

  `define PMPCFG_MASK 8'h9F

  //CSR mapping
                   //User
                   //User Trap Setup
  `define USTATUS       'h000
  `define UIE           'h004
  `define UTVEC         'h005
                   //User Trap Handling
  `define USCRATCH      'h040
  `define UEPC          'h041
  `define UCAUSE        'h042
  `define UBADADDR      'h043
  `define UTVAL         'h043
  `define UIP           'h044
                   //User Floating-Point CSRs
  `define FFLAGS        'h001
  `define FRM           'h002
  `define FCSR          'h003
                   //User Counters/Timers
  `define CYCLE         'hC00
  `define TIMEX         'hC01
  `define INSTRET       'hC02
  `define HPMCOUNTER3   'hC03  //until HPMCOUNTER31='hC1F
  `define CYCLEH        'hC80
  `define TIMEH         'hC81
  `define INSTRETH      'hC82
  `define HPMCOUNTER3H  'hC83  //until HPMCONTER31='hC9F

                   //Supervisor
                   //Supervisor Trap Setup
  `define SSTATUS       'h100
  `define SEDELEG       'h102
  `define SIDELEG       'h103
  `define SIE           'h104
  `define STVEC         'h105
  `define SCOUNTEREN    'h106
                   //Supervisor Trap Handling
  `define SSCRATCH      'h140
  `define SEPC          'h141
  `define SCAUSE        'h142
  `define STVAL         'h143
  `define SIP           'h144
                   //Supervisor Protection and Translation
  `define SATP          'h180

/*
                   //Hypervisor
                   //Hypervisor trap setup
  `define HSTATUS       'h200
  `define HEDELEG       'h202
  `define HIDELEG       'h203
  `define HIE           'h204
  `define HTVEC         'h205
  `define //Hypervisor Trap Handling
  `define HSCRATCH      'h240
  `define HEPC          'h241
  `define HCAUSE        'h242
  `define HTVAL         'h243
  `define HIP           'h244
*/

                   //Machine
                   //Machine Information
  `define MVENDORID     'hF11
  `define MARCHID       'hF12
  `define MIMPID        'hF13
  `define MHARTID       'hF14
                   //Machine Trap Setup
  `define MSTATUS       'h300
  `define MISA          'h301
  `define MEDELEG       'h302
  `define MIDELEG       'h303
  `define MIE           'h304
  `define MNMIVEC       'h7C0  //ROALOGIC NMI Vector
  `define MTVEC         'h305
  `define MCOUNTEREN    'h306
                   //Machine Trap Handling
  `define MSCRATCH      'h340
  `define MEPC          'h341
  `define MCAUSE        'h342
  `define MTVAL         'h343
  `define MIP           'h344
                   //Machine Protection and Translation
  `define PMPCFG0       'h3A0
  `define PMPCFG1       'h3A1  //RV32 only
  `define PMPCFG2       'h3A2
  `define PMPCFG3       'h3A3  //RV32 only
  `define PMPADDR0      'h3B0
  `define PMPADDR1      'h3B1
  `define PMPADDR2      'h3B2
  `define PMPADDR3      'h3B3
  `define PMPADDR4      'h3B4
  `define PMPADDR5      'h3B5
  `define PMPADDR6      'h3B6
  `define PMPADDR7      'h3B7
  `define PMPADDR8      'h3B8
  `define PMPADDR9      'h3B9
  `define PMPADDR10     'h3BA
  `define PMPADDR11     'h3BB
  `define PMPADDR12     'h3BC
  `define PMPADDR13     'h3BD
  `define PMPADDR14     'h3BE
  `define PMPADDR15     'h3BF

                   //Machine Counters/Timers
  `define MCYCLE        'hB00
  `define MINSTRET      'hB02
  `define MHPMCOUNTER3  'hB03  //until MHPMCOUNTER31='hB1F
  `define MCYCLEH       'hB80
  `define MINSTRETH     'hB82
  `define MHPMCOUNTER3H 'hB83  //until MHPMCOUNTER31H='hB9F
                   //Machine Counter Setup
  `define MHPEVENT3     'h323  //until MHPEVENT31 'h33f

                   //Debug
  `define TSELECT       'h7A0
  `define TDATA1        'h7A1
  `define TDATA2        'h7A2
  `define TDATA3        'h7A3
  `define DCSR          'h7B0
  `define DPC           'h7B1
  `define DSCRATCH      'h7B2

  //MXL mapping
  `define RV32I  2'b01
  `define RV32E  2'b01
  `define RV64I  2'b10
  `define RV128I 2'b11

  //Privilege Levels
  `define PRV_M 2'b11
  `define PRV_H 2'b10
  `define PRV_S 2'b01
  `define PRV_U 2'b00

  //Virtualisation
  `define VM_MBARE 4'd0
  `define VM_SV32  4'd1
  `define VM_SV39  4'd8
  `define VM_SV48  4'd9
  `define VM_SV57  4'd10
  `define VM_SV64  4'd11

  //MIE MIP
  `define        MEI 11
  `define        HEI 10
  `define        SEI 9
  `define        UEI 8
  `define        MTI 7
  `define        HTI 6
  `define        STI 5
  `define        UTI 4
  `define        MSI 3
  `define        HSI 2
  `define        SSI 1
  `define        USI 0

  //Performance Counters
  `define        CY 0
  `define        TM 1
  `define        IR 2

  //Exception Causes
  `define        EXCEPTION_SIZE                 16

  `define        CAUSE_MISALIGNED_INSTRUCTION   0
  `define        CAUSE_INSTRUCTION_ACCESS_FAULT 1
  `define        CAUSE_ILLEGAL_INSTRUCTION      2
  `define        CAUSE_BREAKPOINT               3
  `define        CAUSE_MISALIGNED_LOAD          4
  `define        CAUSE_LOAD_ACCESS_FAULT        5
  `define        CAUSE_MISALIGNED_STORE         6
  `define        CAUSE_STORE_ACCESS_FAULT       7
  `define        CAUSE_UMODE_ECALL              8
  `define        CAUSE_SMODE_ECALL              9
  `define        CAUSE_HMODE_ECALL              10
  `define        CAUSE_MMODE_ECALL              11
  `define        CAUSE_INSTRUCTION_PAGE_FAULT   12
  `define        CAUSE_LOAD_PAGE_FAULT          13
  `define        CAUSE_STORE_PAGE_FAULT         15

  `define        CAUSE_USINT                    0
  `define        CAUSE_SSINT                    1
  `define        CAUSE_HSINT                    2
  `define        CAUSE_MSINT                    3
  `define        CAUSE_UTINT                    4
  `define        CAUSE_STINT                    5
  `define        CAUSE_HTINT                    6
  `define        CAUSE_MTINT                    7
  `define        CAUSE_UEINT                    8
  `define        CAUSE_SEINT                    9
  `define        CAUSE_HEINT                    10
  `define        CAUSE_MEINT                    11

  `define MEM_TYPE_EMPTY 2'h0
  `define MEM_TYPE_MAIN  2'h1
  `define MEM_TYPE_IO    2'h2
  `define MEM_TYPE_TCM   2'h3

  `define AMO_TYPE_NONE       2'h0
  `define AMO_TYPE_SWAP       2'h1
  `define AMO_TYPE_LOGICAL    2'h2
  `define AMO_TYPE_ARITHMETIC 2'h3

  //AHB3 Lite Package

  //HTRANS
  `define HTRANS_IDLE   2'b00
  `define HTRANS_BUSY   2'b01
  `define HTRANS_NONSEQ 2'b10
  `define HTRANS_SEQ    2'b11

  //HSIZE
  `define HSIZE_B8    3'b000
  `define HSIZE_B16   3'b001
  `define HSIZE_B32   3'b010
  `define HSIZE_B64   3'b011
  `define HSIZE_B128  3'b100  //4-word line
  `define HSIZE_B256  3'b101  //8-word line
  `define HSIZE_B512  3'b110
  `define HSIZE_B1024 3'b111
  `define HSIZE_BYTE  `HSIZE_B8
  `define HSIZE_HWORD `HSIZE_B16
  `define HSIZE_WORD  `HSIZE_B32
  `define HSIZE_DWORD `HSIZE_B64

  //HBURST
  `define HBURST_SINGLE 3'b000
  `define HBURST_INCR   3'b001
  `define HBURST_WRAP4  3'b010
  `define HBURST_INCR4  3'b011
  `define HBURST_WRAP8  3'b100
  `define HBURST_INCR8  3'b101
  `define HBURST_WRAP16 3'b110
  `define HBURST_INCR16 3'b111

  //HPROT
  `define HPROT_OPCODE         4'b0000
  `define HPROT_DATA           4'b0001
  `define HPROT_USER           4'b0000
  `define HPROT_PRIVILEGED     4'b0010
  `define HPROT_NON_BUFFERABLE 4'b0000
  `define HPROT_BUFFERABLE     4'b0100
  `define HPROT_NON_CACHEABLE  4'b0000
  `define HPROT_CACHEABLE      4'b1000

  //HRESP
  `define       HRESP_OKAY  1'b0
  `define       HRESP_ERROR 1'b1
