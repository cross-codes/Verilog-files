module BIT3_COUNTER(
  output reg [2:0] B_out,
  input wire CLK
);
  initial begin
    B_out = 4'b0000;
  end

  always @(posedge CLK) begin
    B_out <= B_out + 1;
  end
endmodule

module DECO(
  output reg [7:0] O_8,
  input wire A2,
  input wire A1,
  input wire A0,
  input wire EN
);
  always @(*) begin
    case ({A2, A1, A0})
      3'b000: begin
        if (EN == 1) begin
          O_8 = 8'b0000_0001;
        end else begin
          O_8 = 8'b0000_0000;
        end
      end
      3'b001: begin
        if (EN == 1) begin
          O_8 = 8'b0000_0010;
        end else begin
          O_8 = 8'b0000_0000;
        end
      end
      3'b010: begin
        if (EN == 1) begin
          O_8 = 8'b0000_0100;
        end else begin
          O_8 = 8'b0000_0000;
        end
      end
      3'b011: begin
        if (EN == 1) begin
          O_8 = 8'b0000_1000;
        end else begin
          O_8 = 8'b0000_0000;
        end
      end
      3'b100: begin
        if (EN == 1) begin
          O_8 = 8'b0001_0000;
        end else begin
          O_8 = 8'b0000_0000;
        end
      end
      3'b101: begin
        if (EN == 1) begin
          O_8 = 8'b0010_0000;
        end else begin
          O_8 = 8'b0000_0000;
        end
      end
      3'b110: begin
        if (EN == 1) begin
          O_8 = 8'b0100_0000;
        end else begin
          O_8 = 8'b0000_0000;
        end
      end
      3'b111: begin
        if (EN == 1) begin
          O_8 = 8'b1000_0000;
        end else begin
          O_8 = 8'b0000_0000;
        end
      end
      default: begin
        if (EN == 1) begin
          O_8 = 8'bxxxx_xxxx;
        end else begin
          O_8 = 8'b0000_0000;
        end
      end
    endcase
  end
endmodule

module MUX_8(
  output wire Y,
  input wire [7:0] I_8,
  input wire [2:0] S_3
);
  assign Y = I_8[S_3];
endmodule

module INTG(
  output wire [7:0] O_8,
  input wire CLK,
  input wire [7:0] D_8
);
  wire [2:0] B;
  BIT3_COUNTER cnt(B, CLK);

  wire Y;
  MUX_8 mux(Y, D_8, B);
  DECO decoder(O_8, B[2], B[1], B[0], Y);
endmodule

module TESTBENCH();
  wire [7:0] O;
  reg CLK;
  reg [0:7] D;

  INTG dut(O, CLK, D);

  always begin
    #5 CLK = ~CLK;
  end

  integer i = 0;
  initial begin
    #0 CLK = 1'b1;

    @(negedge CLK) #1 D = 8'b1010_1010;
    $display("16 cycles for D: %b", D);

    for (i = 0; i < 16; i = i + 1) begin
      @(posedge CLK) #1 $display($time, " B: %b, Y: %b, O: %b", dut.B, dut.Y, O);
    end

    @(negedge CLK) #1 D = 8'b1011_0100;
    $display("16 cycles for D: %b", D);

    for (i = 0; i < 16; i = i + 1) begin
      @(posedge CLK) #1 $display($time, " B: %b, Y: %b, O: %b", dut.B, dut.Y, O);
    end

    #10 $finish;
  end

  initial begin
    $dumpfile("file.vcd");
    $dumpvars;
  end
endmodule
