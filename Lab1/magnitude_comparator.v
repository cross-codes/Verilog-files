module magnitude_comparator_gf(A3, A2, A1, A0, B3, B2, B1, B0, EQ, G, L);
  // EQ : A = B
  // G : A > B
  // L : A < B

  input A3, A2, A1, A0, B3, B2, B1, B0;
  output EQ, G, L;
  wire X0, X1, X2, X3;
  wire F0, F1, F2, F3, F4, F5;
  wire I0, I1, I2, I3, I4, I5, I6, I7;
  wire K0, K1, K2, K3, K4, K5, K6, K7;

  not(K0, A3);
  not(K1, B3);

  not(K2, A2);
  not(K3, B2);

  not(K4, A1);
  not(K5, B1);

  not(K6, A0);
  not(K7, B0);

  and(I0, K0, B3);
  and(I1, K1, A3);

  and(I2, K2, B2);
  and(I3, K3, A2);

  and(I4, K4, B1);
  and(I5, K5, A1);

  and(I6, K5, B0);
  and(I7, K6, A0);

  nor(X3, I0, I1);
  nor(X2, I2, I3);
  nor(X1, I4, I5);
  nor(X0, I6, I7);

  and(F0, X3, I2);
  and(F1, X3, I3);
  and(F2, X3, X2, I4);
  and(F3, X3, X2, I5);
  and(F4, X3, X2, X1, I6);
  and(F5, X3, X2, X1, I7);
  and(EQ, X0, X1, X2, X3);

  or(L, I0, F0, F2, F4);
  or(G, I1, F1, F3, F5);

endmodule

module magnitude_comparator_bm(A3, A2, A1, A0, B3, B2, B1, B0, EQ, G, L);
  input A3, A2, A1, A0, B3, B2, B1, B0;
  output EQ, G, L;
  reg EQ, G, L;

  always @(*) begin
    if ({A3, A2, A1, A0} > {B3, B2, B1, B0}) begin
      G = 1'b1;
      L = 1'b0;
      EQ = 1'b0;
    end else if ({A3, A2, A1, A0} < {B3, B2, B1, B0}) begin
      G = 1'b0;
      L = 1'b1;
      EQ = 1'b0;
    end else begin
      G = 1'b0;
      L = 1'b0;
      EQ = 1'b1;
    end
  end
endmodule
