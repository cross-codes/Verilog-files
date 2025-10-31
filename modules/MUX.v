module MUX(
  output wire [31:0] O,
  input wire [31:0] A0,
  input wire [31:0] A1,
  input wire [31:0] A2,
  input wire [31:0] A3,
  input wire [1:0] S
);
  always @(*) begin
    case(S)
      2'b00: begin
        S = A0;
      end
      2'b01: begin
        S = A1;
      end
      2'b10: begin
        S = A2;
      end
      2'b11: begin
        S = A3;
      end
    endcase
  end
endmodule
