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
//              Network on Chip FIFO Buffer                                   //
//              Mesh Topology                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2018-2019 by the author(s)
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

`include "riscv_noc_pkg.sv"

module riscv_noc_buffer #(
  parameter PLEN = 64,

  parameter BUFFER_DEPTH = 4,
  parameter FULLPACKET   = 1
)
  (
    input clk,
    input rst,

    //FIFO input side
    input      [PLEN         -1:0] in_flit,
    input                          in_last,
    input                          in_valid,
    output                         in_ready,

    //FIFO output side
    output reg [PLEN         -1:0] out_flit,
    output reg                     out_last,
    output                         out_valid,
    input                          out_ready,

    output     [$clog2(BUFFER_DEPTH) :0] packet_size
  );

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //

  // must be a power of 2
  localparam AW = $clog2(BUFFER_DEPTH);

  //////////////////////////////////////////////////////////////////
  //
  // Functions
  //
  function [AW:0] find_first_one;
    input [BUFFER_DEPTH:0] data;
    integer i;
    for (i = BUFFER_DEPTH; i >= 0; i=i-1)
      if (data[i]) find_first_one = i;
  endfunction // size_count

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  reg [AW  -1:0] wr_addr;
  reg [AW  -1:0] rd_addr;
  reg [AW    :0] rd_count;

  wire           fifo_read;
  wire           fifo_write;
  wire           read_ram;
  wire           write_through;
  wire           write_ram;

  // Generic dual-port, single clock memory

  // Write
  reg [PLEN:0] ram [BUFFER_DEPTH-1:0];

  // Read
  reg  [BUFFER_DEPTH:0] data_last_buf;
  wire [BUFFER_DEPTH:0] data_last_shifted;

  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  // Ensure that parameters are set to allowed values
  initial begin
    if ((1 << $clog2(BUFFER_DEPTH)) != BUFFER_DEPTH) begin
      $fatal("noc_buffer: the DEPTH must be a power of two.");
    end
  end

  assign in_ready      = (rd_count < BUFFER_DEPTH + 1); // The actual depth is DEPTH+1 because of the output register
  assign fifo_read     = out_valid & out_ready;
  assign fifo_write    = in_ready & in_valid;
  assign read_ram      = fifo_read & (rd_count > 1);
  assign write_through = (rd_count == 0) | ((rd_count == 1) & fifo_read);
  assign write_ram     = fifo_write & ~write_through;

  // Address logic
  always @(posedge clk) begin
    if (rst) begin
      wr_addr  <= 'b0;
      rd_addr  <= 'b0;
      rd_count <= 'b0;
    end
    else begin
      if (fifo_write & ~fifo_read)
        rd_count <=  rd_count + 1'b1;
      else if (fifo_read & ~fifo_write) begin
        rd_count <= rd_count - 1'b1;
        if (write_ram)
          wr_addr <= wr_addr + 1'b1;
        if (read_ram)
          rd_addr <= rd_addr + 1'b1;
      end
    end
  end

  // Generic dual-port, single clock memory

  // Write
  always @(posedge clk) begin
    if (write_ram) begin
      ram[wr_addr] <= {in_last, in_flit};
    end
  end

  // Read
  always @(posedge clk) begin
    if (read_ram) begin
      out_flit <= ram[rd_addr][0 +: PLEN];
      out_last <= ram[rd_addr][PLEN];
    end
    else if (fifo_write & write_through) begin
      out_flit <= in_flit;
      out_last <= in_last;
    end
  end

  generate
    if (FULLPACKET != 0) begin
      always @(posedge clk) begin
        if (rst)
          data_last_buf <= 0;
        else if (fifo_write)
          data_last_buf <= {data_last_buf, in_last};
      end

      // Extra logic to get the packet size in a stable manner
      assign data_last_shifted = data_last_buf << BUFFER_DEPTH + 1 - rd_count;

      assign out_valid = (rd_count > 0) & |data_last_shifted;
      //assign packet_size = BUFFER_DEPTH + 1 - find_first_one(data_last_shifted);
    end
    else begin // if (FULLPACKET)
      assign out_valid = rd_count > 0;
      assign packet_size = 0;
    end
  endgenerate
endmodule
