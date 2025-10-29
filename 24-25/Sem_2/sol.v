module F4bit_Counter(
  output reg [3:0] Q_out,
  input wire clk,
  input wire EN1
);
  initial begin
    Q_out = 4'b0000;
  end

  always @(posedge clk) begin
    if (EN1 == 1) begin
      Q_out <= Q_out + 1;
    end
  end
endmodule

module DECO(
  output reg [7:0] O_8,
  input wire [2:0] S_3,
  input wire EN2
);
  always @(*) begin
    O_8 = 8'b0000_0000;

    if (EN2 == 1) begin
      O_8[S_3] <= 1'b1;
    end
  end
endmodule

module JKFF(
  output reg Q,
  input wire J, 
  input wire K,
  input wire CLK
);
  initial begin
    Q = 1'b0;
  end

  always @(posedge CLK) begin
    case ({J, K})
      2'b00: begin
        Q <= Q;
      end
      2'b01: begin
        Q <= 0;
      end
      2'b10: begin
        Q <= 1;
      end
      2'b11: begin
        Q <= ~Q;
      end
    endcase
  end
endmodule

module INTG(
  output wire [2:0] Q_3,
  input wire CLK,
  input wire EN1,
  input wire EN2
);
  wire [3:0] cnt_out;
  F4bit_Counter cnt(cnt_out, CLK, EN1);

  wire [7:0] dec_out;
  DECO dec(dec_out, cnt_out[2:0], EN2);

  JKFF A(Q_3[2], dec_out[0], dec_out[2], CLK);
  JKFF B(Q_3[1], dec_out[1], dec_out[5], CLK);
  JKFF C(Q_3[0], dec_out[3], dec_out[4], CLK);
endmodule

module TESTBENCH();
  reg CLK, EN1, EN2;
  wire [2:0] out;

  initial begin
    forever begin
      #0 CLK = 1;
      #5 CLK = 0;
      #5 CLK = 1;
    end
  end

  initial begin
    #0 EN1 = 1'b0; EN2 = 1'b0;
    #5 EN1 = 1'b1; EN2 = 1'b1;
  end;

  INTG arch(out, CLK, EN1, EN2);

  integer i;
  initial begin
    #1;
    for (i = 0; i < 20; i = i + 1) begin
      #10 $display($time, " Cycle : %d, out: %b", i, out);
    end
  end

  initial begin
    #250 $finish;
  end

endmodule
