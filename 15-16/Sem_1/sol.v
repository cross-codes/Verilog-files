module ENTRIES_16(
  input wire [3:0] X,
  output wire [8:0] R
);
  assign R = 25 * X;
endmodule

module Adder_Register(
  output wire [12:0] res,
  input wire acc_rst1,
  input wire acc_rst2,
  input wire CLK,
  input [8:0] mux_res
);
  reg[12:0] acc;

  initial begin
    acc = 13'b0;
  end

  always @(posedge CLK) begin
    if (acc_rst1 == 1) begin
      acc = acc + {4'b0, mux_res};
    end else begin
      acc = acc;
    end
  end

  always @(posedge acc_rst2 or negedge acc_rst2) begin
    acc = 13'b0;
  end

  assign res = acc;
endmodule

module DFF(
  input wire D,
  input wire CLK,
  input wire RST,
  output reg Q,
  output reg QBAR
);
  always @(posedge CLK or RST) begin
    if (RST == 1) begin
      Q <= 1'b0;
      QBAR <= 1'b1;
    end else begin
      Q <= D;
      QBAR <= ~Q;
    end

  end
endmodule

module ACC_RST(
  input wire CLK,
  input wire RST,
  output wire acc_rst1,
  output wire acc_rst2
);
  wire [3:0] Q, QBAR;

  DFF dff1(QBAR[0], CLK, RST, Q[0], QBAR[0]);
  DFF dff2(QBAR[1], Q[0], RST, Q[1], QBAR[1]);
  DFF dff3(QBAR[2], Q[1], RST, Q[2], QBAR[2]);
  DFF dff4(QBAR[3], Q[2], RST, Q[3], QBAR[3]);

  assign acc_rst1 = Q[2];
  assign acc_rst2 = Q[3];
endmodule

module INTG(
  input wire [3:0] X,
  input wire CLK,
  input wire RST,
  output wire [12:0] Y
);
  wire acc_rst1, acc_rst2;
  ACC_RST acc_rst(CLK, RST, acc_rst1, acc_rst2);

  wire [8:0] mux_out;
  ENTRIES_16 mult(X, mux_out);

  Adder_Register addreg(Y, acc_rst1, acc_rst2, CLK, mux_out);
endmodule

module TESTBENCH();
  reg [3:0] X;
  reg CLK, RST;
  wire [12:0] Y;

  INTG dut(X, CLK, RST, Y);

  initial begin
    #0 CLK = 1'b0;
    #0 RST = 1'b1;
    #0 X = 4'd0;
    #16 RST = 1'b0;

    #8  X = 4'd10;
    #16 X = 4'd5;
    #16 X = 4'd12;
    #16 X = 4'd1;

    #16 X = 4'd13;
    #16 X = 4'd7;
    #16 X = 4'd9;
    #16 X = 4'd2;

    #16 X = 4'd11;
    #16 X = 4'd5;
    #16 X = 4'd4;
    #16 X = 4'd2;
    #200 $finish;
  end

  always begin
    #8 CLK = ~CLK;
  end

  initial begin
    $dumpfile("file.vcd");
    $dumpvars;
  end
endmodule

