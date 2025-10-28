module SHIFTREG(input wire EN, input wire in, input wire CLK, output reg [3:0] Q); 
  initial begin
    Q = 4'b1010;
  end

  always @(posedge CLK) begin
    if (EN) begin
      Q = {in, Q[3:1]};
    end
  end

endmodule

module FULL_ADDER(input wire x, input wire y, input wire cin, output wire s, output wire cout);
  assign {cout, s} = {1'b0, x} + {1'b0, y} + {1'b0, cin};
endmodule

module DFF(input wire D, input wire clk, input wire clear, output reg Q);
  initial begin
    Q <= 1'b0;
  end

  always @(posedge clk) begin
    if (clear == 0) begin
      Q <= 0;
    end else begin
      Q <= D;
    end
  end
endmodule;

module SERIAL_ADDER(
  input wire sh_cntl1,
  inout wire sh_inp1,
  input wire clk,
  input wire sh_cntl2,
  input wire sh_inp2,
  input wire clear,
  output wire [3:0] so1,
  output wire [3:0] so2
);
  assign sh_cntl1 = 1'b1;
  assign sh_cntl2 = 1'b1;

  SHIFTREG A(sh_cntl1, sh_inp1, clk, so1);
  SHIFTREG B(sh_cntl2, sh_inp2, clk, so2);

  wire and_res, fa_carry, dff_out;
  assign and_res = sh_cntl1 & clk;

  DFF dff(fa_carry, and_res, clear, dff_out);
  FULL_ADDER fa(so1[0], so2[0], dff_out, sh_inp1, fa_carry);
endmodule

module tb();
  // Adds 10 + 10, result after four clock cycles
  // Inputs: reg
  // Outputs/InOut: wire
  // No assign
  // Buf out first cycle
  reg sh_cntl1, sh_cntl2;
  reg sh_inp2, clear;
  wire [3:0] so1, so2;

  wire sh_inp1;
  reg clk;

  initial begin
    #0 sh_cntl1 = 1'b0;
    #0 sh_cntl2 = 1'b0;
    #0 clear = 1'b1;
    #0 sh_inp2 = 1'bx;
    #10 sh_cntl1 = 1'b1; sh_cntl2 = 1'b1;
    $monitor($time, " QA: %b", so1);
  end

  initial begin
    forever begin
      #0 clk = 1;
      #5 clk = 0;
      #5 clk = 1;
    end
  end

  SERIAL_ADDER sa(sh_cntl1, sh_inp1, clk, sh_cntl2, sh_inp2, clear, so1, so2);

  initial begin
    #100 $finish;
  end
endmodule
