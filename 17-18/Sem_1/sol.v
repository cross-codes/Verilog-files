`timescale 1ms/1ns

module MUX_SMALL(
  output wire R,
  input wire A,
  input wire B,
  input wire S
);
  assign R = (S == 1) ? B : A;
endmodule

module MUX_BIG(
  output wire R,
  input wire [7:0] A,
  input wire [2:0] S
);

  wire layer1_out [0:3];
  MUX_SMALL m00(layer1_out[0], A[0], A[1], S[0]);
  MUX_SMALL m01(layer1_out[1], A[2], A[3], S[0]);
  MUX_SMALL m02(layer1_out[2], A[4], A[5], S[0]);
  MUX_SMALL m03(layer1_out[3], A[6], A[7], S[0]);

  wire layer2_out [0:1];
  MUX_SMALL m10(layer2_out[0], layer1_out[0], layer1_out[1], S[1]);
  MUX_SMALL m11(layer2_out[1], layer1_out[2], layer1_out[3], S[1]);

  MUX_SMALL m20(R, layer2_out[0], layer2_out[1], S[2]);
endmodule

module TFF(
  output reg Q,
  output reg QBAR,
  input wire T,
  input wire CLK,
  input wire RST
);

  initial begin
    Q = 1'b0;
  end

  always @(RST) begin
    if (RST == 1) begin
      Q <= 1'b0;
      QBAR <= 1'b1;
    end
  end

  always @(posedge CLK) begin
    if (T) begin
      Q <= ~Q;
      QBAR <= Q;
    end else begin
      Q <= Q;
      QBAR <= ~Q;
    end
  end
endmodule

module COUNTER_4BIT(
  output wire [3:0] Q,
  input wire CLK,
  input wire CLEAR
);
  wire [3:0] QBAR;
  TFF tff1(Q[0], QBAR[0], 1'b1, CLK, CLEAR);
  TFF tff2(Q[1], QBAR[1], Q[0], CLK, CLEAR);
  TFF tff3(Q[2], QBAR[2], Q[1] & Q[0], CLK, CLEAR);
  TFF tff4(Q[3], QBAR[3], Q[2] & Q[1] & Q[0], CLK, CLEAR);
endmodule

module COUNTER_3BIT(
  output wire [2:0] Q,
  input wire CLK,
  input wire CLEAR
);
  wire [2:0] QBAR;
  TFF tff1(Q[0], QBAR[0], 1'b1, CLK, CLEAR);
  TFF tff2(Q[1], QBAR[1], Q[0], CLK, CLEAR);
  TFF tff3(Q[2], QBAR[2], Q[1] & Q[0], CLK, CLEAR);
endmodule

module MEMORY(
  output reg [7:0] data,
  input wire [3:0] addr
);
  always @(*) begin
    if (addr & 1) begin
      data = 8'hAA;
    end else begin
      data = 8'hCC;
    end
  end
endmodule

module INTG(
  output wire waveform,
  input wire CLEAR4,
  input wire CLEAR3,
  input wire CLK1
);
  wire [2:0] cnt_3;
  COUNTER_3BIT cnt3(cnt_3, CLK1, CLEAR3);

  wire CLK2;
  assign CLK2 = cnt_3[0] & cnt_3[1] & cnt_3[2];

  wire [3:0] cnt_4;
  COUNTER_4BIT cnt4(cnt_4, CLK2, CLEAR4);

  wire [7:0] mem_out;
  MEMORY mem(mem_out, cnt_4);

  MUX_BIG mux(waveform, mem_out, cnt_3);
endmodule

module TESTBENCH();
  initial begin
    $dumpfile("file.vcd");
    $dumpvars;
  end

  reg CLK1, CLEAR3, CLEAR4;
  wire waveform;

  INTG dut(waveform, CLEAR4, CLEAR3, CLK1);

  always begin
    #0.5 CLK1 = ~CLK1;
  end

  initial begin
    #0 CLEAR3 = 1'b1; CLEAR4 = 1'b1; CLK1 = 1'b1;
    #1.5 CLEAR3 = 1'b0; CLEAR4 = 1'b0;
    #200 $finish;
  end

  initial begin
    $monitor($time, " CLK1: %b, CLK2: %b, CLEAR3: %b, CLEAR4: %b CNT3: %b, CNT4: %b, mem_out: %b o/p: %b", CLK1, dut.CLK2, dut.CLEAR3, dut.CLEAR4, dut.cnt_3, dut.cnt_4, dut.mem_out, waveform);
  end
endmodule
