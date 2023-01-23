module bench;
  reg clk;
  reg rst;

  reg [7:0] ip1;
  reg [7:0] ip2;

  wire [8:0] out;

  adder DUT (
    .clk(clk),
    .rst(rst),

    .in1(ip1),
    .in2(ip2),

    .out(out)
  );
  
  always #5 clk = ~clk;
    

  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1);

    clk = 0;

    ip1 = 0;
    ip2 = 0;

    rst = 0;
    #2ns;
    rst = 1;

    #2ns;
    rst = 0;
    #10;

    ip1 = 5;
    ip2 = 2;
    #5;
    $display("End.");
    $finish;
  end 

endmodule
