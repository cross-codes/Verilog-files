module DFF(
  output reg Q,
  input wire D,
  input wire CLK
);
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
