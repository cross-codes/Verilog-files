module DFF(
  output reg Q,
  input wire D,
  input wire CLK,
  input wire RST
);
  always @(posedge CLK or RST) begin
    if (RST == 0) begin
      Q = 1'b0;
    end else begin
      Q <= D;
    end
  end
endmodule

module REG_32BIT(
  output wire [31:0] Q,
  input wire [31:0] D,
  input wire CLK,
  input wire RST
);
  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin: gen_loop
      DFF dff(Q[i], D[i], CLK, RST);
    end
  endgenerate
endmodule

module TESTBENCH();
  reg [31:0] D;
  reg CLK, RST;

  wire [31:0] Q;

  REG_32BIT register(Q, D, CLK, RST);

  always begin
    #5 CLK = ~CLK;
  end

  initial begin
    #0 CLK = 1'b1;
    #0 RST = 1'b0;

    #20 RST = 1'b1;
    #18 D = 32'hAFAFAFAF;

    #7 $display("Q: %h", Q);
    #200 $finish;
  end
endmodule
