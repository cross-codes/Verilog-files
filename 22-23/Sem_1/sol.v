module REG_8BIT(
  output reg [7:0] reg_out,
  input wire [7:0] num_in,
  input wire clock,
  input wire reset
);
  initial begin
    reg_out = 8'b0000_0000;
  end

  always @(posedge clock) begin
    if (reset != 1) begin
      reg_out = num_in;
    end else begin
      reg_out = 8'b0000_0000;
    end
  end
endmodule

module EXPANSION_BOX(
  input wire [3:0] in,
  output wire [7:0] out
);
  assign out[0] = in[0];
  assign out[1] = in[2];
  assign out[2] = in[3];
  assign out[3] = in[1];
  assign out[4] = in[2];
  assign out[5] = in[1];
  assign out[6] = in[0];
  assign out[7] = in[3];
endmodule

module XOR_8BIT(
  output wire [7:0] xout_8,
  input wire [7:0] xin1_8,
  input wire [7:0] xin2_8
);
  assign xout_8 = xin1_8 ^ xin2_8;
endmodule

module XOR_4BIT(
  output wire [3:0] xout_4,
  input wire [3:0] xin1_4,
  input wire [3:0] xin2_4
);
  assign xout_4 = xin1_4 ^ xin2_4;
endmodule

module FULL_ADDER_4BIT(
  input wire [3:0] A,
  input wire [3:0] B,
  input wire cin,
  output wire [3:0] S,
  output wire cout
);
  assign {cout, S} = {1'b0, A} + {1'b0, B} + {4'b0, cin};
endmodule

module MUX_2x1_1BIT(
  input wire A,
  input wire B,
  input wire S,
  output wire R
);
  assign R = (S == 1) ? B : A;
endmodule

module MUX_2x1_4BIT(
  input wire [3:0] A,
  input wire [3:0] B,
  input wire S,
  output wire [3:0] R
);
  assign R = (S == 1) ? B : A;
endmodule

module CSA_4BIT(
  input wire cin,
  input wire [3:0] inA,
  input wire [3:0] inB,
  output wire cout,
  output wire [3:0] out
);
  wire [3:0] s_1, s_2;
  wire cout_1, cout_2;
  FULL_ADDER_4BIT fa1(inA, inB, 1'b1, s_1, cout_1);
  FULL_ADDER_4BIT fa2(inA, inB, 1'b0, s_2, cout_2);

  MUX_2x1_4BIT s_mux(s_2, s_1, cin, out);
  MUX_2x1_1BIT c_mux(cout_2, cout_1, cin, cout);
endmodule

module CONCAT(
  output wire [7:0] concat_out,
  input wire [3:0] concat_in1,
  input wire [3:0] concat_in2
);
  assign concat_out = {concat_in1, concat_in2};
endmodule

module ENCRYPT(
  input wire [7:0] number,
  input wire [7:0] key,
  input wire clock,
  input wire reset,
  output wire [7:0] enc_number
);
  wire [7:0] num_out, key_out;
  REG_8BIT reg1(num_out, number, clock, reset);
  REG_8BIT reg2(key_out, key, clock, reset);

  wire [7:0] box_out;
  EXPANSION_BOX box(num_out[3:0], box_out);

  wire [7:0] xor_8_out;
  XOR_8BIT xor_8(xor_8_out, box_out, key_out);

  wire csa_cout;
  wire [3:0] csa_sum;
  CSA_4BIT csa(key_out[0], xor_8_out[7:4], xor_8_out[3:0], csa_cout, csa_sum);

  wire [3:0] xor_4_out;
  XOR_4BIT xor_4(xor_4_out, num_out[7:4], csa_sum);

  CONCAT concat(enc_number, xor_4_out, num_out[3:0]);
endmodule

module TESTBENCH();
  reg [7:0] num, key;
  reg clock, reset;
  wire [7:0] out;

  initial begin
    clock = 0;
  end;

  always begin
    #5 clock = ~clock;
  end

  ENCRYPT dut(num, key, clock, reset, out);

  initial begin
    num = 8'b0000_0000;
    key = 8'b0000_0000;
    reset = 1'b1;
    #12 reset = 1'b0;

    @(negedge clock);
    num = 8'b0100_0110; key = 8'b1001_0011;
    @(posedge clock); #1 $display("num: %b, key: %b, out: %b", num, key, out);

    num = 8'b1100_1001; key = 8'b1010_1100;
    @(posedge clock) #1 $display("num: %b, key: %b, out: %b", num, key, out);

    num = 8'b1010_0101; key = 8'b0101_1010;
    @(posedge clock) #1 $display("num: %b, key: %b, out: %b", num, key, out);

    num = 8'b1111_0000; key = 8'b1011_0001;
    @(posedge clock) #1 $display("num: %b, key: %b, out: %b", num, key, out);

    #10 $finish;
  end
endmodule
