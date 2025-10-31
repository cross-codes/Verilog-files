module DFF(
  output reg Q,
  input wire D,
  input wire CLK
);
  initial begin
    Q <= 1'b0;
  end

  always @(posedge CLK) begin
    Q <= D;
  end
endmodule

module ControlLogic(
  output wire T0,
  output wire T1,
  output wire T2,
  input wire S,
  input wire Z,
  input wire X
);
  wire a, b, c, d;
  not(a, S);
  and(b, T0, a);
  and(c, T2, Z);
  or(d, b, c);

  DFF ff0(T0, d, CLK);

  wire e, f, g, h, i, j, k;
  and(e, T0, S);
  not(f, X);
  not(g, Z);
  and(h, f, g, T2);
  not(i, X);
  and(j, i, T1);
  or(k, j, h, e);

  DFF ff1(T1, k, CLK);

  wire l, m, n, o;
  and(l, T1, X);
  not(m, Z);
  and(n, T2, m, X);
  or(o, n, l);

  DFF ff2(T2, o, CLK);
endmodule

module TFF(
  output reg Q,
  output reg QBAR,
  input wire T,
  input wire CLK,
  input wire CLEAR,
  input wire EN
);
  initial begin
    Q = 1'b0;
    QBAR = 1'b1;
  end

  always @(posedge CLK) begin
    if (EN == 0) begin
      Q <= Q;
      QBAR <= ~Q;
    end else if (CLEAR == 1) begin
      Q <= 1'b0;
      QBAR <= 1'b1;
    end else if (T) begin
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
  input wire CLEAR,
  input wire EN
);
  wire [3:0] QBAR;
  TFF ff1(Q[0], QBAR[0], 1'b1, CLK, CLEAR, EN);
  TFF ff2(Q[1], QBAR[1], Q[0], CLK, CLEAR, EN);
  TFF ff3(Q[2], QBAR[2], Q[1] & Q[0], CLK, CLEAR, EN);
  TFF ff4(Q[3], QBAR[3], Q[2] & Q[1] & Q[0], CLK, CLEAR, EN);
endmodule

module INTG(
  output wire G,
  output wire [3:0] cnt_out,
  input wire S,
  input wire X,
  input wire CLK
);
  wire T0, T1, T2, Z;
  assign Z = cnt_out[0] & cnt_out[1] & cnt_out[2] & cnt_out[3];

  COUNTER_4BIT cnt(cnt_out, CLK, T0 & S, (T1 & X) | (T2 & X & ~Z));
  ControlLogic controller(T0, T1, T2, S, Z, X);
  DFF dff(G, T2 & Z, CLK);
endmodule

module TESTBENCH();
  reg S, X, CLK;
  wire [3:0] cnt_out;
  wire G;

  INTG dut(G, cnt_out, S, X, CLK);

  always begin
    #0.5 CLK = ~CLK;
  end

  initial begin
    #0 CLK = 1'b0;
    #0.5 S = 1'b1; X = 1'b1;

    #200 $finish;
  end

  initial begin
    $monitor("G: %b, cnt_out: %b", G, cnt_out);
  end
endmodule
