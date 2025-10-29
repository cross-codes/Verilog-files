`timescale 1ms/1ns

module MUX_2x1(
  input wire A,
  input wire B,
  input wire S,
  output wire R
);
  assign R = (S == 1) ? B : A;
endmodule

module MUX_8x1(
  input wire [7:0] A,
  input wire [2:0] S,
  output wire R
);
  assign R = A[S];
endmodule

module MUX_ARRAY(
  input wire [7:0] C,
  input wire [7:0] S,
  output wire [7:0] E
);
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin: gen_loop
      MUX_2x1 mux(1'b0, C[i], S[i], E[i]);
    end
  endgenerate
endmodule

module COUNTER_3BIT(
  input wire CLK,
  input wire CLEAR,
  output reg [2:0] Q
);
  initial begin
    Q <= 3'b000;
  end

  always @(posedge CLK or CLEAR) begin
    if (CLEAR == 1) begin
      Q <= 3'b000;
    end else begin
      Q <= Q + 1;
    end
  end
endmodule

module DECODER(
  input wire [2:0] A,
  input wire EN,
  output reg [7:0] B
);
  always @(*) begin
    B = 8'b0000_0000;
    if (EN == 1) begin
      B[A] = 1;
    end
  end
endmodule

module MEMORY(
  input wire [2:0] addr,
  output reg [7:0] data
);
  initial begin
    data = 8'b0000_0000;
  end

  always @(*) begin
    case (addr)
      3'b000: begin
        data = 8'h01;
      end
      3'b001: begin
        data = 8'h03;
      end
      3'b010: begin
        data = 8'h07;
      end
      3'b011: begin
        data = 8'h0F;
      end
      3'b100: begin
        data = 8'h1F;
      end
      3'b101: begin
        data = 8'h3F;
      end
      3'b110: begin
        data = 8'h7F;
      end
      3'b111: begin
        data = 8'hFF;
      end
      default: begin
        data = 8'hxx;
      end
    endcase
  end
endmodule

module TOP(
  input wire CLK,
  input wire CLEAR,
  input wire [2:0] S,
  output wire O
);
  wire [2:0] cnt_out;
  COUNTER_3BIT cnt(CLK, CLEAR, cnt_out);

  wire [7:0] dec_out;
  DECODER dec(cnt_out, 1'b1, dec_out);

  wire [7:0] data, arr_out;
  MEMORY mem(S, data);
  MUX_ARRAY arr(dec_out, data, arr_out);

  MUX_8x1 mux(arr_out, cnt_out, O);
endmodule

module TESTBENCH();
  reg CLK, CLEAR;
  reg [2:0] S;
  wire O;

  TOP dut(CLK, CLEAR, S, O);

  initial begin
    forever begin
      #0   CLK = 1'b1;
      #0.5 CLK = 1'b0;
      #0.5 CLK = 1'b1;
    end
  end

  initial begin
    S = 3'b000;
    CLEAR = 1'b1;
    #1 CLEAR = 1'b0;
    #100 $finish;
  end

  always begin
    #8 S = S + 1;
  end

  initial begin
    $monitor($time, "CLK: %b S: %b O: %b", CLK, S, O);
  end

endmodule
