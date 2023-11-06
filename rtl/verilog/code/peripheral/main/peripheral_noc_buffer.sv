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
//              Peripheral-NoC for MPSoC                                      //
//              Network on Chip for MPSoC                                     //
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
 *   Stefan Wallentowitz <stefan@wallentowitz.de>
 *   Wei Song <wsong83@gmail.com>
 *   Max Koenen <max.koenen@tum.de>
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

module peripheral_noc_buffer #(
  parameter FLIT_WIDTH = 32,
  parameter DEPTH      = 16,  // must be a power of 2
  parameter FULLPACKET = 0,

  parameter AW = $clog2(DEPTH)  // the width of the index
) (
  input clk,
  input rst,

  // FIFO input side
  input  [FLIT_WIDTH-1:0] in_flit,
  input                   in_last,
  input                   in_valid,
  output                  in_ready,

  // FIFO output side
  output reg [FLIT_WIDTH-1:0] out_flit,
  output reg                  out_last,
  output                      out_valid,
  input                       out_ready,

  output [AW:0] packet_size
);

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  reg  [      AW-1:0] wr_addr;
  reg  [      AW-1:0] rd_addr;
  reg  [        AW:0] rd_count;
  wire                fifo_read;
  wire                fifo_write;
  wire                read_ram;
  wire                write_through;
  wire                write_ram;

  // Generic dual-port, single clock memory
  reg  [FLIT_WIDTH:0] ram               [DEPTH-1:0];

  reg  [     DEPTH:0] data_last_buf;
  wire [     DEPTH:0] data_last_shifted;

  //////////////////////////////////////////////////////////////////////////////
  //
  // Functions
  //

  function logic [AW:0] find_first_one(input logic [DEPTH:0] data);
    for (int i = DEPTH; i >= 0; i--) begin
      if (data[i]) begin
        return i;
      end
    end
    return DEPTH + 1;
  endfunction

  //////////////////////////////////////////////////////////////////////////////
  // Module Body
  //////////////////////////////////////////////////////////////////////////////

  // Ensure that parameters are set to allowed values
  initial begin
    if ((1 << $clog2(DEPTH)) != DEPTH) begin
      $fatal("noc_buffer: the DEPTH must be a power of two.");
    end
  end

  // The actual depth is DEPTH+1 because of the output register
  assign in_ready      = (rd_count < DEPTH + 1);
  assign fifo_read     = out_valid & out_ready;
  assign fifo_write    = in_ready & in_valid;
  assign read_ram      = fifo_read & (rd_count > 1);
  assign write_through = ((rd_count == 0) | ((rd_count == 1) & fifo_read));
  assign write_ram     = fifo_write & ~write_through;

  // Address logic
  always @(posedge clk) begin
    if (rst) begin
      wr_addr  <= 'b0;
      rd_addr  <= 'b0;
      rd_count <= 'b0;
    end else begin
      if (fifo_write & ~fifo_read) begin
        rd_count <= rd_count + 1'b1;
      end else if (fifo_read & ~fifo_write) begin
        rd_count <= rd_count - 1'b1;
      end

      if (write_ram) begin
        wr_addr <= wr_addr + 1'b1;
      end

      if (read_ram) begin
        rd_addr <= rd_addr + 1'b1;
      end
    end
  end

  // Write
  always @(posedge clk) begin
    if (write_ram) begin
      ram[wr_addr] <= {in_last, in_flit};
    end
  end

  // Read
  always @(posedge clk) begin
    if (read_ram) begin
      out_flit <= ram[rd_addr][0+:FLIT_WIDTH];
      out_last <= ram[rd_addr][FLIT_WIDTH];
    end else if (fifo_write & write_through) begin
      out_flit <= in_flit;
      out_last <= in_last;
    end
  end

  generate
    if (FULLPACKET != 0) begin
      always @(posedge clk) begin
        if (rst) begin
          data_last_buf <= 0;
        end else if (fifo_write) begin
          data_last_buf <= {data_last_buf, in_last};
        end
      end

      // Extra logic to get the packet size in a stable manner
      assign data_last_shifted = data_last_buf << DEPTH + 1 - rd_count;

      assign out_valid         = (rd_count > 0) & |data_last_shifted;
      assign packet_size       = DEPTH + 1 - find_first_one(data_last_shifted);
    end else begin
      assign out_valid   = rd_count > 0;
      assign packet_size = 0;
    end
  endgenerate
endmodule
