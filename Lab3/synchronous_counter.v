module JKFF(J, K, CLK, Q, QBAR);
  input wire J, K, CLK;
  output reg Q;
  output wire QBAR;

  initial begin
    Q = 0;
  end

  assign QBAR = ~Q;

  always @(posedge CLK) begin
    case ({J, K})
      2'b00: begin
        Q <= Q;
      end
      2'b01: begin
        Q <= 0;
      end
      2'b10: begin
        Q <= 1;
      end
      2'b11: begin
        Q <= ~Q;
      end
    endcase
  end
endmodule

module SYNCHRONUS_COUNTER(clk, Q);
  input wire clk;
  output wire [3:0] Q, QBAR;
  wire Q2IM, Q3IM;

  assign Q2IM = Q[0] & Q[1];
  assign Q3IM = Q2IM & Q[2];

  JKFF FFA(1'd1, 1'd1, clk, Q[0], QBAR[0]);
  JKFF FFB(Q[0], Q[0], clk, Q[1], QBAR[1]);
  JKFF FFC(Q2IM, Q2IM, clk, Q[2], QBAR[2]);
  JKFF FFD(Q3IM, Q3IM, clk, Q[3], QBAR[3]);

endmodule

module testbench;
  reg clk;
  wire [3:0] Q;

  SYNCHRONUS_COUNTER cnt(clk, Q);

  always @(posedge clk) begin
    $monitor($time, "Q: %b", Q);
  end

  initial begin
    forever begin
      #0 clk = 1;
      #5 clk = 0;
      #5 clk = 1;
    end
  end

  initial begin
    #100 $finish;
  end
endmodule
