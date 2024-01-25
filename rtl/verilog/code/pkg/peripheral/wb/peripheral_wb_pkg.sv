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
//              Package                                                       //
//              Bus Functional Model                                          //
//              WishBone Bus Interface                                        //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018-2019 by the author(s)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////
// Author(s):
//   Paco Reina Campo <pacoreinacampo@queenfield.tech>

package peripheral_wb_pkg;

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  localparam CLASSIC_CYCLE = 1'b0;
  localparam BURST_CYCLE = 1'b1;

  localparam READ = 1'b0;
  localparam WRITE = 1'b1;

  localparam [2:0] CTI_CLASSIC = 3'b000;
  localparam [2:0] CTI_CONST_BURST = 3'b001;
  localparam [2:0] CTI_INC_BURST = 3'b010;
  localparam [2:0] CTI_END_OF_BURST = 3'b111;

  localparam [1:0] BTE_LINEAR = 2'd0;
  localparam [1:0] BTE_WRAP_4 = 2'd1;
  localparam [1:0] BTE_WRAP_8 = 2'd2;
  localparam [1:0] BTE_WRAP_16 = 2'd3;

  //////////////////////////////////////////////////////////////////////////////
  // Functions
  //////////////////////////////////////////////////////////////////////////////

  function get_cycle_type;
    input [2:0] cti;
    begin
      get_cycle_type = (cti === CTI_CLASSIC) ? CLASSIC_CYCLE : BURST_CYCLE;
    end
  endfunction

  function wb_is_last;
    input [2:0] cti;
    begin
      case (cti)
        CTI_CLASSIC:      wb_is_last = 1'b1;
        CTI_CONST_BURST:  wb_is_last = 1'b0;
        CTI_INC_BURST:    wb_is_last = 1'b0;
        CTI_END_OF_BURST: wb_is_last = 1'b1;
        default:          $display("%d : Illegal Wishbone B3 cycle type (%b)", $time, cti);
      endcase
    end
  endfunction

  function [31:0] wb_next_adr;
    input [31:0] adr_i;
    input [2:0] cti_i;
    input [2:0] bte_i;

    input integer dw;

    reg     [31:0] adr;

    integer        shift;

    begin
      if (dw == 64) begin
        shift = 3;
      end else if (dw == 32) begin
        shift = 2;
      end else if (dw == 16) begin
        shift = 1;
      end else begin
        shift = 0;
      end

      adr = adr_i >> shift;

      if (cti_i == CTI_INC_BURST) begin
        case (bte_i)
          BTE_LINEAR:  adr = adr + 1;
          BTE_WRAP_4:  adr = {adr[31:2], adr[1:0] + 2'd1};
          BTE_WRAP_8:  adr = {adr[31:3], adr[2:0] + 3'd1};
          BTE_WRAP_16: adr = {adr[31:4], adr[3:0] + 4'd1};
        endcase
      end
      wb_next_adr = adr << shift;
    end
  endfunction

endpackage
