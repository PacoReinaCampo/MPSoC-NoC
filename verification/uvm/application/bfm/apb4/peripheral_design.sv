import peripheral_apb4_pkg::*;

module peripheral_design (
  input pclk,
  input presetn,

  input      [PADDR_SIZE-1:0] paddr,
  input      [           1:0] pstrb,
  input                       pwrite,
  output reg                  pready,
  input                       psel,
  input      [PDATA_SIZE-1:0] pwdata,
  output reg [PDATA_SIZE-1:0] prdata,
  input                       penable,
  output reg                  pslverr
);

  // Memory Declaration
  reg [PDATA_SIZE-1:0] memory [31:0];

  // State Declaration Communication
  parameter [1:0] IDLE   = 2'b00;
  parameter [1:0] SETUP  = 2'b01;
  parameter [1:0] ACCESS = 2'b10;

  //state declaration of present and next 
  reg [1:0] present_state;
  reg [1:0] next_state;

  always @(posedge pclk) begin
    if (presetn) begin
      present_state <= IDLE;
    end else begin
      present_state <= next_state;
    end
  end

  always @(*) begin
    // next_state = present_state;
    case (present_state)
      IDLE: begin
        if (psel & !penable) begin
          next_state = SETUP;
        end
        pready = 0;
      end

      SETUP: begin
        if (!penable | !psel) begin
          next_state = IDLE;
        end else begin
          if (pwrite == 1) begin
            memory[paddr] = pwdata;
            pready        = 1;
            pslverr       = 0;
          end else begin
            prdata  = memory[paddr];
            pready  = 1;
            pslverr = 0;
          end

          next_state = ACCESS;
        end
      end

      ACCESS: begin
        if (!penable | !psel) begin
          pready     = 0;
          next_state = IDLE;
        end
      end
    endcase
  end
endmodule
