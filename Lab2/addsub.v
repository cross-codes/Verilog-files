module FULLADDER(A, B, CIN, S, COUT);
  input wire A, B, CIN;
  output reg S, COUT;

  always @(*) begin
    case ({A, B, CIN})
      3'b000: {COUT, S} = 2'b00;
      3'b001: {COUT, S} = 2'b01;
      3'b010: {COUT, S} = 2'b01;
      3'b011: {COUT, S} = 2'b10;
      3'b100: {COUT, S} = 2'b01;
      3'b101: {COUT, S} = 2'b10;
      3'b110: {COUT, S} = 2'b10;
      3'b111: {COUT, S} = 2'b11;
    endcase
  end
endmodule

module ADDSUB(A, B, M, C, S, V);
  input wire [3:0] A, B;
  input wire M;

  output wire C, V;
  output wire [3:0] S;
  
  wire [2:0] CIM;
  wire [3:0] BIM;

  assign BIM[0] = B[0] ^ M;
  assign BIM[1] = B[1] ^ M;
  assign BIM[2] = B[2] ^ M;
  assign BIM[3] = B[3] ^ M;

  FULLADDER f0(A[0], BIM[0], M, S[0], CIM[0]);
  FULLADDER f1(A[1], BIM[1], CIM[0], S[1], CIM[1]);
  FULLADDER f2(A[2], BIM[2], CIM[1], S[2], CIM[2]);
  FULLADDER f3(A[3], BIM[3], CIM[2], S[3], C);

  assign V = C ^ CIM[2];
endmodule
