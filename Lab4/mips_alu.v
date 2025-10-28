module MUX3TO1(input wire a, input wire b, input wire c, input wire [1:0] s, output wire res);
  assign res = (s[1] == 1) ? (s[0] == 1 ? 0 : c) : (s[0] == 1 ? b : a);
endmodule

module BIT_8_MUX3TO1(
  input wire [7:0] a,
  input wire [7:0] b,
  input wire [7:0] c,
  input wire [1:0] s,
  output wire [7:0] res
);
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin: gen_loop
      MUX3TO1 m(a[i], b[i], c[i], s, res[i]);
    end
  endgenerate
endmodule

// [7:0], [15:8], [23:16], [31:24]
module BIT_32_MUX3TO1(input wire[31:0] a,
  input wire [31:0] b,
  input wire [31:0] c,
  input wire [1:0] s,
  output wire [31:0] res
);
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin: gen_loop
      BIT_8_MUX3TO1 m(a[((8 * i) + 7):(8 * i)], b[((8 * i) + 7):(8 * i)], c[((8 * i) + 7):(8 * i)], s, res[((8 * i) + 7):(8 * i)]);
    end
  endgenerate
endmodule

module BIT_32_AND(input wire [31:0] in1, input wire [31:0] in2, output wire [31:0] out);
  assign out = in1 & in2;
endmodule

module BIT_32_OR(input wire [31:0] in1, input wire [31:0] in2, output wire [31:0] out);
  assign out = in1 | in2;
endmodule

module FULL_ADDER(
  input wire [31:0] a,
  input wire [31:0] b,
  input wire cin,
  output wire [31:0] s,
  output wire cout
);
  assign {cout, s} = {32'b0, cin} + {1'b0, a} + {1'b0, b};
endmodule

module NEGATE(
  input wire [31:0] a,
  output wire [31:0] res
);
  assign res = -a;
endmodule

module ALU(
  input wire [31:0] a,
  input wire [31:0] b,
  input wire carryin,
  input wire [1:0] operation,
  input wire binvert,
  output reg [31:0] result,
  output reg carryout
);

  wire [31:0] and_out;
  wire [31:0] or_out;
  wire [31:0] neg_b;
  wire [31:0] sum;
  wire carry;

  BIT_32_AND and_inst(a, b, and_out);
  BIT_32_OR or_inst(a, b, or_out);
  NEGATE negate_inst(b, neg_b);
  FULL_ADDER full_adder_inst(a, binvert ? neg_b : b, carryin, sum, carry);

  always @(*) begin
    case (operation)
      2'b00: begin
        result = and_out;
        carryout = 0;
      end
      2'b01: begin
        result = or_out;
        carryout = 0;
      end
      2'b10: begin
        result = sum;
        carryout = carry;
      end
      default: begin
        result = 32'b0;
        carryout = 0;
      end
    endcase
  end

endmodule

module tbALU();
  reg Binvert, Carryin; 
  reg [1:0] Operation; 
  reg [31:0] a,b; 
  wire [31:0] Result; 
  wire CarryOut; 

  ALU alu(a,b,Carryin,Operation,Binvert,Result,CarryOut); 

  initial begin
    $monitor("Operation: %b, Binvert: %b, Result: %b, CarryOut: %b", Operation, Binvert, Result, CarryOut);
  end

  initial begin 
  a=32'ha5a5a5a5; 
  b=32'h5a5a5a5a; 
  Operation=2'b00; 
  Binvert=1'b0; 
  Carryin=1'b0;
  #100 Operation=2'b01;
  #100 Operation=2'b10;
  #100 Binvert=1'b1;
  #200 $finish; 
  end 
endmodule 
