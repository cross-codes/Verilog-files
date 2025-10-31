module BHT(
  input wire [9:0] addr,
  input wire [1:0] data,
  input wire WR,
  input wire CLK,
  output wire [1:0] out
);
  reg [1:0] tbl [0:1023];

  integer i;
  initial begin
    for (i = 0; i < 1024; i = i + 1) begin
      tbl[i] = 2'b00;
    end
  end

  always @(posedge CLK) begin
    if (WR == 1) begin
      tbl[addr] <= data;
    end
  end

  assign out = tbl[addr];
endmodule

module MUX1(
  input wire [1:0] A,
  input wire [1:0] B,
  input wire S,
  output wire [1:0] R
);
  assign R = (S == 1) ? B : A;
endmodule


module PREDICTOR(
  input wire outcome,
  input wire CLK,
  output reg [1:0] next_state
);
  reg [1:0] curr_state;

  initial begin
    curr_state = 2'b00;
  end

  always @(posedge CLK) begin
    case(curr_state)
      2'b00: begin
        if (outcome == 1) begin
          next_state <= 2'b01;
        end else begin
          next_state <= 2'b00;
        end
      end
      2'b01: begin
        if (outcome == 1) begin
          next_state <= 2'b11;
        end else begin
          next_state <= 2'b00;
        end
      end
      2'b10: begin
        if (outcome == 1) begin
          next_state <= 2'b11;
        end else begin
          next_state <= 2'b00;
        end
      end
      2'b11: begin
        if (outcome == 1) begin
          next_state <= 2'b11;
        end else begin
          next_state <= 2'b10;
        end
      end
      default: begin
        next_state <= 2'bxx;
      end
    endcase
  end
endmodule
