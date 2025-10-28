module CONTROL(
  input wire [5:0] op,
  output wire RegDst,
  output wire ALUSrc,
  output wire MemToReg,
  output wire RegWrite,
  output wire MemRead,
  output wire MemWrite,
  output wire Branch,
  output wire ALUOp0,
  output wire ALUOp1
);
  wire Rformat, lw, sw, beq;

  assign Rformat = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
  assign lw = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
  assign sw = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
  assign beq = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];

  assign RegDst = Rformat;
  assign ALUSrc = lw | sw;
  assign MemToReg = lw;
  assign RegWrite = Rformat | lw;
  assign MemRead = lw;
  assign MemWrite = sw;
  assign Branch = beq;
  assign ALUOp0 = Rformat;
  assign ALUOp1 = beq;

endmodule
