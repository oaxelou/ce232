`include "constants.h"

/***********************************************************************************************/
/*********************************  MIPS 5-stage pipeline implementation ***********************/
/***********************************************************************************************/

module cpu(input clock, input reset);
 reg [31:0] PC; 
 reg [31:0] IFID_PCplus4;
 reg [31:0] IFID_instr;
 reg [31:0] IDEX_rdA, IDEX_rdB, IDEX_signExtend;
 reg [4:0]  IDEX_instr_rt, IDEX_instr_rs, IDEX_instr_rd, IDEX_instr_shamt;                            
 reg        IDEX_RegDst, IDEX_ALUSrc, IDEX_Shift;
 reg [1:0]  IDEX_ALUcntrl;
 reg        IDEX_Branch, IDEX_MemRead, IDEX_MemWrite; 
 reg        IDEX_MemToReg, IDEX_RegWrite;                
 reg [4:0]  EXMEM_RegWriteAddr, EXMEM_instr_rd; 
 reg [31:0] EXMEM_ALUOut;
 reg        EXMEM_Zero;
 reg [31:0] EXMEM_MemWriteData;
 reg        EXMEM_Branch, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite, EXMEM_MemToReg;
 reg [31:0] MEMWB_DMemOut;
 reg [4:0]  MEMWB_RegWriteAddr, MEMWB_instr_rd; 
 reg [31:0] MEMWB_ALUOut;
 reg        MEMWB_MemToReg, MEMWB_RegWrite;               
 wire [31:0] instr, ALUInA, ALUInB, ALUOut, rdA, rdB, signExtend, DMemOut, wRegData, PCIncr;
 wire Zero, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, Shift, RegWrite, Branch;
 wire [5:0] opcode, func;
 wire [4:0] instr_rs, instr_rt, instr_rd, instr_shamt, RegWriteAddr;
 wire [3:0] ALUOp;
 wire [1:0] ALUcntrl;
 wire [15:0] imm;
 wire [1:0] bypassA, bypassB;
 wire stall, PCWrite, ifid_write;
 wire [31:0] ALUInAtemp, ALUInBtemp;
 wire [31:0] writeData_DataMem;
 
 

/***************** Instruction Fetch Unit (IF)  ****************/
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0) begin    
       PC <= -1;
       
     end   
    else if (PC == -1)
       PC <= 0;
    else if (PCWrite == 1)
       PC <= PC + 4;
  end
  
  // IFID pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       IFID_PCplus4 <= 32'b0;    
       IFID_instr <= 32'b0;
       
    end 
    else if (ifid_write == 1)
      begin
       IFID_PCplus4 <= PC + 32'd4;
       IFID_instr <= instr;
    end
  end
  
// Instruction memory 1KB
Memory cpu_IMem(clock, reset, 1'b1, 1'b0, PC>>2, 32'b0, instr);

  
/***************** Instruction Decode Unit (ID)  ****************/
assign opcode = IFID_instr[31:26];
assign func = IFID_instr[5:0];
assign instr_rs = IFID_instr[25:21];
assign instr_rt = IFID_instr[20:16];
assign instr_rd = IFID_instr[15:11];
assign instr_shamt = IFID_instr[10:6];
assign imm = IFID_instr[15:0];
assign signExtend = {{16{imm[15]}}, imm};

// Register file
RegFile cpu_regs(clock, reset, instr_rs, instr_rt, MEMWB_RegWriteAddr, MEMWB_RegWrite, wRegData, rdA, rdB);

  // IDEX pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)
      begin
       IDEX_rdA <= 32'b0;    
       IDEX_rdB <= 32'b0;
       IDEX_signExtend <= 32'b0;
       IDEX_instr_rd <= 5'b0;
       IDEX_instr_rs <= 5'b0;
       IDEX_instr_rt <= 5'b0;
       IDEX_instr_shamt <= 5'b0;
       IDEX_RegDst <= 1'b0;
       IDEX_ALUcntrl <= 2'b0;
       IDEX_ALUSrc <= 1'b0;
       IDEX_Branch <= 1'b0;
       IDEX_MemRead <= 1'b0;
       IDEX_MemWrite <= 1'b0;
       IDEX_MemToReg <= 1'b0;                  
       IDEX_RegWrite <= 1'b0;
    end 
    else 
      begin
       IDEX_rdA <= rdA;
       IDEX_rdB <= rdB;
       IDEX_signExtend <= signExtend;
       IDEX_instr_rd <= instr_rd;
       IDEX_instr_rs <= instr_rs;
       IDEX_instr_rt <= instr_rt;
       IDEX_instr_shamt <= instr_shamt;

       if(stall == 1) begin
         IDEX_RegDst <= RegDst;
         IDEX_ALUcntrl <= ALUcntrl;
         IDEX_ALUSrc <= ALUSrc;
	 IDEX_Shift <= Shift;
         IDEX_Branch <= Branch;
         IDEX_MemRead <= MemRead;
         IDEX_MemWrite <= MemWrite;
         IDEX_MemToReg <= MemToReg;                  
         IDEX_RegWrite <= RegWrite;
      end
      else begin
         IDEX_RegDst <= 0;
         IDEX_ALUcntrl <= 0;
         IDEX_ALUSrc <= 0;
	 IDEX_Shift <= 0;
         IDEX_Branch <= 0;
         IDEX_MemRead <= 0;
         IDEX_MemWrite <= 0;
         IDEX_MemToReg <= 0;                  
         IDEX_RegWrite <= 0;
      end
    end
  end

// Main Control Unit 
control_main control_main (RegDst,
                  Branch,
                  MemRead,
                  MemWrite,
                  MemToReg,
                  ALUSrc,
		  Shift,
                  RegWrite,
                  ALUcntrl,
                  opcode,
                  func);
                  
// Instantiation of Control Unit that generates stalls goes here
control_stall_id hazard_unit(MemWrite, 
                         PCWrite,
			 ifid_write,
			 stall,
			 instr_rs,
			 instr_rt,
			 IDEX_MemRead,
			 IDEX_instr_rt);

                           
/***************** Execution Unit (EX)  ****************/
                 
//assign ALUInAtemp = IDEX_rdA;   //possibly we'll shove another mux here for shift instructions
//assign bypassA = 2'b00;
//assign bypassB = 2'b00;              

//multiplexers for bypass
assign ALUInAtemp = (bypassA == 2'b00) ? IDEX_rdA :
                    (bypassA == 2'b01) ? wRegData :
                    (bypassA == 2'b10) ? EXMEM_ALUOut : 32'bx;
                    
assign ALUInBtemp = (bypassB == 2'b00) ? IDEX_rdB :
                    (bypassB == 2'b01) ? wRegData :
                    (bypassB == 2'b10) ? EXMEM_ALUOut : 32'bx;

assign ALUInB = (IDEX_ALUSrc == 1'b0) ? ALUInBtemp : IDEX_signExtend;
assign ALUInA = (IDEX_Shift == 1'b0) ? ALUInAtemp : IDEX_instr_shamt;

//  ALU
ALU  #(.N(32)) cpu_alu(ALUOut, Zero, ALUInA, ALUInB, ALUOp);

assign RegWriteAddr = (IDEX_RegDst == 1'b0) ? IDEX_instr_rt : IDEX_instr_rd;

 // EXMEM pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       EXMEM_ALUOut <= 32'b0;    
       EXMEM_RegWriteAddr <= 5'b0;
       EXMEM_MemWriteData <= 32'b0;
       EXMEM_Zero <= 1'b0;
       EXMEM_Branch <= 1'b0;
       EXMEM_MemRead <= 1'b0;
       EXMEM_MemWrite <= 1'b0;
       EXMEM_MemToReg <= 1'b0;                  
       EXMEM_RegWrite <= 1'b0;
      end 
    else 
      begin
       EXMEM_ALUOut <= ALUOut;    
       EXMEM_RegWriteAddr <= RegWriteAddr;
       EXMEM_MemWriteData <= ALUInBtemp;
       EXMEM_Zero <= Zero;
       EXMEM_Branch <= IDEX_Branch;
       EXMEM_MemRead <= IDEX_MemRead;
       EXMEM_MemWrite <= IDEX_MemWrite;
       EXMEM_MemToReg <= IDEX_MemToReg;                  
       EXMEM_RegWrite <= IDEX_RegWrite;
       EXMEM_instr_rd <= IDEX_instr_rd;
      end
  end
  
  // ALU control
  control_alu control_alu(ALUOp, IDEX_ALUcntrl, IDEX_signExtend[5:0]);
  
  // Instantiation of control logic for Forwarding goes here
  control_bypass_ex forwarding_unit (MEMWB_MemToReg, MEMWB_RegWriteAddr, bypassA, bypassB, IDEX_instr_rs, IDEX_instr_rt, EXMEM_instr_rd, MEMWB_instr_rd, EXMEM_RegWrite, MEMWB_RegWrite);
  
  
  
/***************** Memory Unit (MEM)  ****************/  

assign writeData_DataMem = (MEMWB_MemToReg == 1 && EXMEM_MemWrite == 1 && MEMWB_RegWriteAddr == EXMEM_RegWriteAddr) ? MEMWB_DMemOut : EXMEM_MemWriteData;

// Data memory 1KB
Memory cpu_DMem(clock, reset, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_ALUOut, writeData_DataMem, DMemOut);

// MEMWB pipeline register
 always @(posedge clock or negedge reset)
  begin 
    if (reset == 1'b0)     
      begin
       MEMWB_DMemOut <= 32'b0;    
       MEMWB_ALUOut <= 32'b0;
       MEMWB_RegWriteAddr <= 5'b0;
       MEMWB_MemToReg <= 1'b0;                  
       MEMWB_RegWrite <= 1'b0;
      end 
    else 
      begin
       MEMWB_DMemOut <= DMemOut;
       MEMWB_ALUOut <= EXMEM_ALUOut;
       MEMWB_RegWriteAddr <= EXMEM_RegWriteAddr;
       MEMWB_MemToReg <= EXMEM_MemToReg;                  
       MEMWB_RegWrite <= EXMEM_RegWrite;
       MEMWB_instr_rd <= EXMEM_instr_rd;
      end
  end

  

/***************** WriteBack Unit (WB)  ****************/  
assign wRegData = (MEMWB_MemToReg == 1'b0) ? MEMWB_ALUOut : MEMWB_DMemOut;


endmodule
