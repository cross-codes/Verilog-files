module ALUControl(
  input wire [1:0] ALUOp,
  input wire [5:0] funct,
  output reg [2:0] operation
);
  always @(*) begin
    case(ALUOp)
      2'b00: begin
        operation = 3'b010;
      end
      2'b01: begin
        operation = 3'b110;
      end
      2'b10: begin
        if (funct[3:0] == 4'b0000) begin
          operation = 3'b010;
        end else if (funct[3:0] == 4'b0010) begin
          operation = 3'b110;
        end else if (funct[3:0] == 4'b0100) begin
          operation = 3'b000;
        end else if (funct[3:0] == 4'b0101) begin
          operation = 3'b001;
        end else if (funct[3:0] == 4'b1010) begin
          operation = 3'b111;
        end else begin
          operation = 3'bxxx;
        end
      end
    endcase
  end
endmodule

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
module BIT_32_MUX3TO1(
  input wire[31:0] a,
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
  reg [1:0] ALUOp;
  reg [5:0] funct;
  wire [2:0] op;

  ALUControl alu_control(ALUOp, funct, op);

  wire [31:0] a, b, result;
  wire carryin, carryout;
  wire [1:0] operation;
  wire binvert;

  assign a = 32'ha5a5a5a5;
  assign b = 32'h5a5a5a5a;
  assign carryin = 1'b0;

  assign {binvert, operation} = op;

  ALU alu_inst(a, b, carryin, operation, binvert, result, carryout);

  initial begin
    $monitor($time, " ALUOp: %b, funct: %b, op: %b, result: %b", ALUOp, funct, op, result);
  end

  initial begin
    #0 ALUOp = 2'b00;
    #5 ALUOp = 2'b01;
    #10 ALUOp = 2'b10; funct = 6'bxx0000;
    #15 funct = 6'bxx0010;
    #20 funct = 6'bxx0100;
    #25 funct = 6'bxx0101;
    #30 funct = 6'bxx1010;

    #100 $finish;
  end
endmodule
