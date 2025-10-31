module MUX4_1(
  output reg [31:0] out,
  input wire [31:0] data1,
  input wire [31:0] data2,
  input wire [31:0] data3,
  input wire [31:0] data4,
  input wire [1:0] reg_no
);
  always @(*) begin
    case(reg_no)
      2'b00: begin
        out = data1;
      end
      2'b01: begin
        out = data2;
      end
      2'b10: begin
        out = data3;
      end
      2'b11: begin
        out = data4;
      end
      default: begin
        out = 32'hxxxxxxxx;
      end
    endcase
  end
endmodule

module MUX32_1(
  output wire [31:0] out,
  input wire [32*32-1:0] data_flat,
  input wire [4:0] reg_no
);
  wire [31:0] data [0:31];
  genvar i;
  generate
    for (i=0; i<32; i=i+1) begin
      assign data[i] = data_flat[(i+1)*32-1 : i*32];
    end
  endgenerate

  assign out = data[reg_no];
endmodule

module DECODER2_4(
  output wire [3:0] register,
  input wire [1:0] reg_no
);
  assign register = 4'h1 << reg_no;
endmodule

module DECODER5_32(
  output wire [31:0] register,
  input wire [4:0] reg_no
);
  assign register = 32'h0000_0001 << reg_no;
endmodule
