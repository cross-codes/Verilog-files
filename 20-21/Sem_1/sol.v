module SRFF(
  input wire S,
  input wire R,
  input wire RST,
  input wire CLK,
  output reg Q
);
  initial begin
    Q <= 1'b0;
  end

  always @(posedge CLK) begin
    case ({S, R})
      2'b00: begin
        if (RST == 1) begin
          Q <= 1'b0;
        end else begin
          Q <= Q;
        end
      end
      2'b01: begin
        if (RST == 1) begin
          Q <= 1'b0;
        end else begin
          Q <= 1'b0;
        end
      end
      2'b10: begin
        if (RST == 1) begin
          Q <= 1'b0;
        end else begin
          Q <= 1'b1;
        end
      end
      2'b11: begin
        if (RST == 1) begin
          Q <= 1'b0;
        end else begin
          Q <= 1'bx;
        end
      end
    endcase
  end
endmodule

module DFF(
  input wire D,
  input wire CLK,
  input wire RST,
  output wire Q,
  output wire QBAR
);
  assign QBAR = ~Q;
  SRFF ff(D, ~D, RST, CLK, Q);
endmodule

module Ripple_Counter(
  input wire CLK,
  input wire Reset,
  output wire [3:0] Q
);

  wire [3:0] QBAR;
  DFF dff1(QBAR[0], CLK, RST, Q[0], QBAR[0]);
  DFF dff2(QBAR[1], QBAR[0], RST, Q[1], QBAR[1]);
  DFF dff3(QBAR[2], QBAR[1], RST, Q[2], QBAR[2]);
  DFF dff4(QBAR[3], QBAR[2], RST, Q[3], QBAR[3]);
endmodule

module MEM1(
  input wire [2:0] addr,
  output reg [7:0] memory,
  output wire parity
);
  always @(*) begin
    case(addr)
      3'b000: begin
        memory = 8'b0001_1111;
      end
      3'b001: begin
        memory = 8'b0011_0001;
      end
      3'b010: begin
        memory = 8'b0101_0011;
      end
      3'b011: begin
        memory = 8'b0111_0101;
      end
      3'b100: begin
        memory = 8'b1001_0111;
      end
      3'b101: begin
        memory = 8'b1011_1001;
      end
      3'b110: begin
        memory = 8'b1101_1011;
      end
      3'b111: begin
        memory = 8'b1111_1101;
      end
    endcase
  end

  assign parity = 1'b1;
endmodule

module MEM2(
  input wire [2:0] addr,
  output reg [7:0] memory,
  output wire parity
);
  always @(*) begin
    case(addr)
      3'b000: begin
        memory = 8'b0000_0000;
      end
      3'b001: begin
        memory = 8'b0010_0010;
      end
      3'b010: begin
        memory = 8'b0100_0100;
      end
      3'b011: begin
        memory = 8'b0110_0110;
      end
      3'b100: begin
        memory = 8'b1000_1000;
      end
      3'b101: begin
        memory = 8'b1010_1010;
      end
      3'b110: begin
        memory = 8'b1100_1100;
      end
      3'b111: begin
        memory = 8'b1110_1110;
      end
    endcase
  end

  assign parity = 1'b0;
endmodule

module MUX2TO1(
  input wire A,
  input wire B,
  input wire S,
  output wire R
);
  assign R = (S == 1'b1) ? B : A;
endmodule;

module MUX16TO8(
  input wire [7:0] A,
  input wire [7:0] B,
  input wire S,
  output wire [7:0] R
);
  MUX2TO1 m1(A[0], B[0], S, R[0]);
  MUX2TO1 m2(A[1], B[1], S, R[1]);
  MUX2TO1 m3(A[2], B[2], S, R[2]);
  MUX2TO1 m4(A[3], B[3], S, R[3]);
  MUX2TO1 m5(A[4], B[4], S, R[4]);
  MUX2TO1 m6(A[5], B[5], S, R[5]);
  MUX2TO1 m7(A[6], B[6], S, R[6]);
  MUX2TO1 m8(A[7], B[7], S, R[7]);
endmodule

module Fetch_Data(
  input wire [3:0] select,
  output wire [7:0] data,
  output wire parity
);
  wire [7:0] mem1, mem2;
  wire parity1, parity2;
  MEM1 bank1(select[2:0], mem1, parity1);
  MEM2 bank2(select[2:0], mem2, parity2);

  MUX16TO8 data_select(mem1, mem2, select[3], data);
  MUX2TO1 parity_select(parity1, parity2, select[3], parity);
endmodule

module Parity_Checker(
  input wire [7:0] stream,
  input wire expected_parity,
  output wire match
);
  wire parity;
  assign parity = stream[0] ^ stream[1] ^ stream[2] ^ stream[3] ^ stream[4] ^ stream[5] ^ stream[6] ^ stream[7];
  assign match = (parity == expected_parity) ? 1'b1 : 1'b0;
endmodule

module Design(
  input wire CLK,
  input wire RST,
  output wire match
);
  wire [3:0] cnt_out;
  Ripple_Counter cnt(CLK, RST, cnt_out);

  wire [7:0] data;
  wire parity;
  Fetch_Data fd(cnt_out, data, parity);
  Parity_Checker pc(data, parity, match);
endmodule

module TestBench();
  reg CLK, RST;
  wire match;

  Design DUT(CLK, RST, match);

  initial begin
    forever begin
      #0 CLK = 1'b1;
      #5 CLK = 1'b0;
      #5 CLK = 1'b1;
    end
  end

  initial begin
    #0 RST = 1;
    #5 RST = 0;
  end

  integer i = 0;
  initial begin
    #1
    for (i = 1; i <= 16; i = i + 1) begin
      #10 $display("cnt: %b match: %b", DUT.cnt_out, match);
    end
  end

  initial begin
    #250 $finish;
  end
endmodule
