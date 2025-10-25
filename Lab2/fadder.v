module DECODER(d0, d1, d2, d3, d4, d5, d6, d7, x, y, z);
  input x, y, z;
  output d0, d1, d2, d3, d4, d5, d6, d7;

  wire x0, y0, z0;
  not n1(x0, x);
  not n2(y0, y);
  not n3(z0,z); 
  and a0(d0,x0,y0,z0); 
  and a1(d1,x0,y0,z); 
  and a2(d2,x0,y,z0); 
  and a3(d3,x0,y,z); 
  and a4(d4,x,y0,z0); 
  and a5(d5,x,y0,z); 
  and a6(d6,x,y,z0); 
  and a7(d7,x,y,z);

endmodule

module FADDER(s, c, x, y, z);
  input x, y, z;
  output s, c;

  wire d0, d1, d2, d3, d4, d5, d6, d7;

  DECODER dec(d0, d1, d2, d3, d4, d5, d6, d7, x, y, z);
  
  assign s = d1 | d2 | d4 | d7;
  assign c = d3 | d5 | d6 | d7;

endmodule

module BIT_8_FADDER(s, c, x, y, z);
  input [7:0] x, y;
  input z;

  output [7:0] s;
  wire [6:0] con;
  output c;

  FADDER f1(s[0], con[0], x[0], y[0], z);
  FADDER f2(s[1], con[1], x[1], y[1], con[0]);
  FADDER f3(s[2], con[2], x[2], y[2], con[1]);
  FADDER f4(s[3], con[3], x[3], y[3], con[2]);
  FADDER f5(s[4], con[4], x[4], y[4], con[3]);
  FADDER f6(s[5], con[5], x[5], y[5], con[4]);
  FADDER f7(s[6], con[6], x[6], y[6], con[5]);
  FADDER f8(s[7], c, x[7], y[7], con[6]);

endmodule

module BIT_32_FADDER(s, c, x, y, z);
  input [31:0] x, y;
  input z;

  output [31:0] s;
  wire [2:0] con;
  output c;

  BIT_8_FADDER f1(s[7:0], con[0], x[7:0], y[7:0], z);
  BIT_8_FADDER f2(s[15:8], con[1], x[15:8], y[15:8], con[0]);
  BIT_8_FADDER f3(s[23:16], con[2], x[23:16], y[23:16], con[1]);
  BIT_8_FADDER f4(s[31:24], c, x[31:24], y[31:24], con[2]);

endmodule
