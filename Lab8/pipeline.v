module BIT_8_ENCODER(input wire [7:0] funct, output reg [2:0] ctrl);
	always @(*) begin
		case(funct)
			8'b0000_0001: begin
				ctrl = 3'b000;
			end
			8'b0000_0010: begin
				ctrl = 3'b001;
			end
			8'b0000_0100: begin
				ctrl = 3'b010;
			end
			8'b0000_1000: begin
				ctrl = 3'b011;
			end
			8'b0001_0000: begin
				ctrl = 3'b100;
			end
			8'b0010_0000: begin
				ctrl = 3'b101;
			end
			8'b0100_0000: begin
				ctrl = 3'b110;
			end
			8'b1000_0000: begin
				ctrl = 3'b111;
			end
			default: begin
				ctrl = 3'bxxx;
			end
		endcase
	end
endmodule

module BIT_4_ALU(
	input wire [3:0] A,
	input wire [3:0] B,
	input wire [2:0] opcode,
	output wire [3:0] x
);
	assign x = (opcode == 3'b000) ? A + B :
			   (opcode == 3'b001) ? A - B :
			   (opcode == 3'b010) ? A ^ B :
			   (opcode == 3'b011) ? A | B :
			   (opcode == 3'b100) ? A & B :
			   (opcode == 3'b101) ? ~(A | B) :
			   (opcode == 3'b110) ? ~(A & B) :
			   (opcode == 3'b111) ? ~(A ^ B) :
			   4'bxxxx;
endmodule

module BIT_4_EVEN_PARITY_GENERATOR(
	input wire [3:0] X,
	output wire res
);
	assign res = X[0] ^ X[1] ^ X[2] ^ X[3];
endmodule

module BIT_4_DFF(
	input wire [3:0] D,
	input wire clk,
	output reg [3:0] Q
);
	initial begin
		Q = 4'b0000;
	end
	
	always @(posedge clk) begin
		Q <= D;
	end
endmodule;

module PIPELINE(
	input wire [7:0] funct,
	input wire [3:0] A,
	input wire [3:0] B,
	input wire clk,
	output wire [3:0] alu_out,
	output wire res
);
	wire [2:0] encoder_out;
	BIT_8_ENCODER encoder_inst(funct, encoder_out);
	
	wire [3:0] ctrl_out;
	wire [3:0] A_out, B_out;
	BIT_4_DFF ctrl_dff({1'b0, encoder_out}, clk, ctrl_out);
	BIT_4_DFF A_dff(A, clk, A_out);
	BIT_4_DFF B_dff(B, clk, B_out);
	
	BIT_4_ALU alu_inst(A_out, B_out, ctrl_out[2:0], alu_out);
	
	wire [3:0] X_out;
	
	BIT_4_DFF X_dff(alu_out, clk, X_out);
	
	BIT_4_EVEN_PARITY_GENERATOR gen_inst(X_out, res);
endmodule;
	
module tb();
	reg [7:0] funct;
	wire [3:0] A, B;
	reg clk;
	
	wire res;
	wire [3:0] alu_out;
	initial begin
		forever begin
			#0 clk = 0;
			#1 clk = 1;
			#1 clk = 0;
		end
	end
	
	assign A = 4'b0011;
	assign B = 4'b0101;
	
	PIPELINE aarch(funct, A, B, clk, alu_out, res);
	
	initial begin
		#0 funct = 8'b0000_0001; // 4'b1000
		#20 $display($time, " ADD  funct: %b, A : %b, B: %b, alu: %b res: %b", funct, A, B, alu_out, res);
		funct = 8'b0000_0010; // 4'b1110
		#20 $display($time, " SUB  funct: %b, A : %b, B: %b, alu: %b res: %b", funct, A, B, alu_out, res);
		funct = 8'b0000_0100; // 4'b0110
		#20 $display($time, " XOR  funct: %b, A : %b, B: %b, alu: %b res: %b", funct, A, B, alu_out, res);
		funct = 8'b0000_1000; // 4'b0111
		#20 $display($time, " OR   funct: %b, A : %b, B: %b, alu: %b res: %b", funct, A, B, alu_out, res);
		funct = 8'b0001_0000; // 4'b0001
		#20 $display($time, " AND  funct: %b, A : %b, B: %b, alu: %b res: %b", funct, A, B, alu_out, res);
		funct = 8'b0010_0000; // 4'b1000
		#20 $display($time, " NOR  funct: %b, A : %b, B: %b, alu: %b res: %b", funct, A, B, alu_out, res);
		funct = 8'b0100_0000; // 4'b1110
		#20 $display($time, " NAND funct: %b, A : %b, B: %b, alu: %b res: %b", funct, A, B, alu_out, res);
		funct = 8'b1000_0000; // 4'b1001
		#2s0 $display($time, " XNOR funct: %b, A : %b, B: %b, alu: %b res: %b", funct, A, B, alu_out, res);
		#100 $finish;
	end
endmodule
