// Top level CPU unit. This is where you instantiate and interconnect all modules
// in library.v and fsm.v

module cpu(input clock, input reset);
 reg [31:0] PC; 
 wire [31:0] instr, ALUInA, ALUInB, rdB, ALUOut, signExtend, wRegData, PCIncr, DMemOut;
 wire [3:0] ALUOp;
 wire Zero, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Branch, BranchBNE, PCSrc, renInstr, wenInstr;
 wire [5:0] opcode, func;
 wire [4:0] instr_rs, instr_rt, instr_rd;
 wire [4:0] wRegAddr;
 wire [15:0] imm;
 

 always @(posedge clock or negedge reset)
  begin 
// PC implementation. Do not forget the reset signal
	if (reset)
	    if (PCSrc)
		PC <= PC + 4 + PCIncr*4;
	    else begin
		PC <= PC + 4;
	    end
	else
	   PC <= -4;
  end
  
// Aliases
assign opcode = instr[31:26];
assign instr_rs = instr[25:21];
assign instr_rt = instr[20:16];
assign instr_rd = instr[15:11];
assign func = instr[5:0];
assign imm = instr[15:0];

assign renInstr = reset;
assign wenInstr = 0;

assign signExtend = {{16{imm[15]}}, imm};
assign wRegAddr = (RegDst == 1'b0) ? instr_rt : instr_rd;
assign ALUInB = (ALUSrc == 1'b0) ? rdB : signExtend;
assign PCSrc = (Zero & Branch) | (~Zero & BranchBNE);
assign PCIncr = signExtend; 
assign wRegData = (MemToReg == 0) ? ALUOut : DMemOut;

// MIPS ALU
ALU  #(.N(32)) cpu_alu(ALUOut, Zero, ALUInA, ALUInB, ALUOp);

// Register file
RegFile cpu_regs (clock, reset, instr_rs,
			instr_rt, wRegAddr, RegWrite,
			wRegData, ALUInA, rdB);

// Instruction memory 1KB
Memory cpu_IMem (clock, reset, renInstr, wenInstr, PC>>2, , instr);

// Data memory 1KB
Memory cpu_DMem (clock, reset, MemRead, MemWrite, ALUOut, rdB, DMemOut);  // tsekare giati einai to MemToReg edw
// tsekare wRegData, wRegAddr kai ALUInBtemp

//(MemRead, MemWrite, DMemOut, ALUOut, wRegData)

// Control Unit 
fsm ctrl_unit(RegDst, Branch, BranchBNE, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, ALUOp, opcode, func);

endmodule
