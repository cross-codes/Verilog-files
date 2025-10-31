module JKFF(
  output reg Q,
  input wire J,
  input wire K,
  input wire CLK
);
  initial begin
    Q = 1'b1;
  end

  always @(posedge CLK) begin
    case({J, K})
      2'b00: begin
        Q <= Q;
      end
      2'b01: begin
        Q <= 1'b0;
      end
      2'b10: begin
        Q <= 1'b1;
      end
      2'b11: begin
        Q <= ~Q;
      end
    endcase
  end
endmodule

module BCD_COUNTER(
  output wire [3:0] Q_out,
  input wire CLK
);
  wire CLK1, J2, CLK2, CLK3, J4, CLK4;

  not(CLK1, CLK);
  not(J2, Q_out[3]);
  not(CLK2, Q_out[0]);
  not(CLK3, Q_out[1]);
  and(J4, Q_out[1], Q_out[2]);
  not(CLK4, Q_out[0]);

  JKFF ff1(Q_out[0], 1'b1, 1'b1, CLK1);
  JKFF ff2(Q_out[1], J2, 1'b1, CLK2);
  JKFF ff3(Q_out[2], 1'b1, 1'b1, CLK3);
  JKFF ff4(Q_out[3], J4, 1'b1, CLK4);
endmodule

module MEM_16(
  output reg [15:0] D_16,
  input wire [3:0] A_4
);
  always @(*) begin
    case (A_4)
      4'b0000: begin
        D_16 = 16'h0001;
      end
      4'b0001: begin
        D_16 = 16'h0002;
      end
      4'b0010: begin
        D_16 = 16'h0004;
      end
      4'b0011: begin
        D_16 = 16'h0008;
      end
      4'b0100: begin
        D_16 = 16'h0010;
      end
      4'b0101: begin
        D_16 = 16'h0020;
      end
      4'b0110: begin
        D_16 = 16'h0000;
      end
      4'b0111: begin
        D_16 = 16'h0000;
      end
      4'b1000: begin
        D_16 = 16'h0000;
      end
      4'b1001: begin
        D_16 = 16'h0000;
      end
      4'b1010: begin
        D_16 = 16'h0400;
      end
      4'b1011: begin
        D_16 = 16'h0800;
      end
      4'b1100: begin
        D_16 = 16'h1000;
      end
      4'b1101: begin
        D_16 = 16'h0000;
      end
      4'b1110: begin
        D_16 = 16'h0000;
      end
      4'b1111: begin
        D_16 = 16'h0000;
      end
      default: begin
        D_16 = 16'hxxxx;
      end
    endcase
  end
endmodule

module MUX_16(
  output wire O,
  input wire [15:0] I_16,
  input wire [3:0] S_4
);
  assign O = I_16[S_4];
endmodule

module INTG(
  output wire OUT,
  input wire CLK
);
  wire [3:0] cnt_out;
  BCD_COUNTER cnt(cnt_out, CLK);

  wire [15:0] mem_out;
  MEM_16 mem(mem_out, cnt_out);
  MUX_16 mux(OUT, mem_out, cnt_out);
endmodule

module TESTBENCH();
  wire OUT;
  reg CLK;

  INTG dut(OUT, CLK);

  initial begin
    $dumpfile("file.vcd");
    $dumpvars;
  end

  always begin
    #5 CLK = ~CLK;
  end

  initial begin
    #0 CLK = 1'b1; 

    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    @(posedge CLK) #1 $display($time, " CLK: %b, CNT: %b OUT: %b", CLK, dut.cnt_out, OUT);
    #240 $finish;
  end
endmodule
