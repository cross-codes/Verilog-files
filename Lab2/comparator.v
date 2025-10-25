module SIGN(neg, A);
  input [3:0] A;
  output neg;

  reg neg;

  always @(A) begin
    if (A[3] == 1)
      neg = 1;
    else
      neg = 0;
  end
endmodule

module COMPARATOR(A, B, signA, signB, CMP1, CMP2, CMP3);
  input [3:0] A, B;
  output signA, signB, CMP1, CMP2, CMP3;

  reg CMP1, CMP2, CMP3;

  SIGN sgna(signA, A);
  SIGN sgnb(signB, B);

  always @(A or B or signA or signB) begin
    if (signA == 1 && signB == 0) begin
      CMP1 = 0;
      CMP2 = 0;
      CMP3 = 1;
    end else if (signA == 0 && signB == 1) begin
      CMP1 = 1;
      CMP2 = 0;
      CMP3 = 0;
    end else if (A > B) begin
      CMP1 = 1;
      CMP2 = 0;
      CMP3 = 0;
    end else if (A == B) begin
      CMP1 = 0;
      CMP2 = 1;
      CMP3 = 0;
    end else begin
      CMP1 = 0;
      CMP2 = 0;
      CMP3 = 1;
    end
  end
endmodule

module testbench;
  reg[3:0] A, B;
  wire signA, signB, CMP1, CMP2, CMP3;

  initial begin
    A = 4'b0000;
    B = 4'b0000;
  end

  initial begin
    #1 A = -8; B = -5;
    #1 A = 2; B = 7;
    #1 A = 5; B = -1;
  end

  COMPARATOR c1(A, B, signA, signB, CMP1, CMP2, CMP3);

  initial begin
    $monitor("A = %b, B = %b A > B = %b, A == B = %b, A < B = %b", A, B, CMP1, CMP2, CMP3);
    #5 $finish;
  end

endmodule
