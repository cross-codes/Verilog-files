// BCD to gray code converter
// G3 = B3; G2 = B3 ^ B2; G1 = B2 ^ B1; G0 = B1 ^ B0

module bcd_to_gray_gf(B0, B1, B2, B3, G0, G1, G2, G3);
  input B0, B1, B2, B3;
  output G0, G1, G2, G3;

  buf(G3, B3);
  xor(G2, B3, B2);
  xor(G1, B2, B1);
  xor(G0, B1, B0);

endmodule

module bcd_to_gray_df(B0, B1, B2, B3, G0, G1, G2, G3);
  input B0, B1, B2, B3;
  output G0, G1, G2, G3;

  assign G3 = B3;
  assign G2 = B3 ^ B2;
  assign G1 = B2 ^ B1;
  assign G0 = B1 ^ B0;
endmodule

module testbench;
  reg B0, B1, B2, B3;
  wire G0, G1, G2, G3;
  wire G4, G5, G6, G7;

  bcd_to_gray_gf gf(B0, B1, B2, B3, G0, G1, G2, G3);
  bcd_to_gray_df df(B0, B1, B2, B3, G4, G5, G6, G7);

  wire [3:0] net0, net1, net2;
  assign net0 = {B3, B2, B1, B0};
  assign net1 = {G3, G2, G1, G0};
  assign net2 = {G7, G6, G5, G4};

  initial
  begin
    $monitor("Input: %b, GF: %b, DF: %b", net0, net1, net2);

    #0 {B3, B2, B1, B0} = 4'b1001; // expect 1101
    #2 {B3, B2, B1, B0} = 4'b0100; // expect 0110
    #100 $finish;

  end
endmodule

