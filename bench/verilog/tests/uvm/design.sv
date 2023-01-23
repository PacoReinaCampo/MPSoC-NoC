module adder(
  input clk,
  input rst,

  input [7:0] in1,
  input [7:0] in2,

  output reg [8:0] out
);
  
  always@(posedge clk or posedge rst) begin 
    if(rst)
      out <= 0;
    else
      out <= in1 + in2;
  end
endmodule
