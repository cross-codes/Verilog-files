module SEQ_DET(
  output reg Z1,
  input wire X,
  input wire CLK,
  input wire RST
);
  reg [2:0] cur_state;

  initial begin
    Z1 = 1'b0;
    cur_state = 3'b000;
  end

  always @(posedge CLK) begin
    case (cur_state)
      3'b000: begin
        if (RST == 1) begin
          cur_state <= 3'b000;
          Z1 <= 1'b0;
        end else begin
          if (X == 0) begin
            cur_state <= 3'b000;
            Z1 <= 1'b0;
          end else begin
            cur_state <= 3'b001;
            Z1 <= 1'b0;
          end
        end
      end
      3'b001: begin
        if (RST == 1) begin
          cur_state <= 3'b000;
          Z1 <= 1'b0;
        end else begin
          if (X == 0) begin
            cur_state <= 3'b010;
            Z1 <= 1'b0;
          end else begin
            cur_state <= 3'b001;
            Z1 <= 1'b0;
          end
        end
      end
      3'b010: begin
        if (RST == 1) begin
          cur_state <= 3'b000;
          Z1 <= 1'b0;
        end else begin
          if (X == 0) begin
            cur_state <= 3'b011;
            Z1 <= 1'b0;
          end else begin
            cur_state <= 3'b001;
            Z1 <= 1'b0;
          end
        end
      end
      3'b011: begin
        if (RST == 1) begin
          cur_state <= 3'b000;
          Z1 <= 1'b0;
        end else begin
          if (X == 0) begin
            cur_state <= 3'b000;
            Z1 <= 1'b0;
          end else begin
            cur_state <= 3'b100;
            Z1 <= 1'b1;
          end
        end
      end
      3'b100: begin
        if (RST == 1) begin
          cur_state <= 3'b000;
          Z1 <= 1'b0;
        end else begin
          if (X == 0) begin
            cur_state <= 3'b010;
            Z1 <= 1'b0;
          end else begin
            cur_state <= 3'b001;
            Z1 <= 1'b0;
          end
        end
      end
      default: begin
        cur_state <= 3'bxxx;
        Z1 <= 1'bx;
      end
    endcase
  end
endmodule

module BIN_Counter(
  output reg [2:0] Q_out,
  input wire CLR1,
  input wire CLR2,
  input wire CLK
);
  initial begin
    Q_out = 3'b000;
  end

  always @(posedge CLK) begin
    if (CLR1 == 1 || CLR2 == 1) begin
      Q_out <= 3'b000;
    end else if (Q_out != 3'b111) begin
      Q_out <= Q_out + 1;
    end else begin
      Q_out <= Q_out;
    end
  end
endmodule

module DEC_8(
  output reg [7:0] O_8,
  input wire [2:0] S_3
);
  initial begin
    O_8 = 8'b0000_0000;
  end

  always @(*) begin
    O_8 = 8'b0000_0000;
    O_8[S_3] = 1'b1;
  end
endmodule

module INTG(
  output wire Z1,
  output wire Z2,
  input wire X,
  input wire RST,
  input wire CLK
);
  SEQ_DET detector(Z1, X, CLK, RST);

  wire [2:0] cnt_out;
  BIN_Counter cnt(cnt_out, RST, Z2, Z1);

  wire [7:0] dec_out;
  DEC_8 decoder(dec_out, cnt_out);

  assign Z2 = dec_out[3];
endmodule

module TESTBENCH();
  reg X, RST, CLK;
  wire Z1, Z2;

  INTG arch(Z1, Z2, X, RST, CLK);

  initial begin
    CLK = 1;
  end

  always begin
    #5 CLK = ~CLK;
  end

  integer i = 0;

  always begin
    #10 i = i + 1;
  end

  initial begin
    RST = 1'b1;
    X = 1'b0;

    #10 RST = 0;
    X = 1;

    #10 X = 0;
    #10 X = 0;
    #10 X = 1;
    #10 X = 0;
    #10 X = 0;
    #10 X = 1;
    #10 X = 1;
    #10 X = 0;
    #10 X = 0;
    #10 X = 1;
    #10 X = 0;
    #10 X = 0;
    #10 X = 0;
    #10 X = 0;
    #10 X = 1;
    #10 X = 0;
    #10 X = 0;
    #10 X = 1;
    #10 X = 0;
    #10 X = 0;
    #10 X = 1;
    #10 X = 0;
    #10 X = 0;
    #10 X = 1;
    #10 $finish;
  end

  initial begin
    $monitor("Cycle#: %0d, time: %t, X: %b, Z1: %b, Z2: %b", i, $time, X, Z1, Z2);
  end
endmodule
