`include "constants.h"

module fsm(output reg RegDst,
           output reg Branch,
	   output reg BranchBNE, 
           output reg MemRead,
           output reg MemWrite,  
           output reg MemToReg,  
           output reg ALUSrc,
           output reg RegWrite,  
           output reg [3:0] ALUOp,  
           input [5:0] opcode, 
           input [5:0] func);

  always @(*) 
   begin
     case (opcode)
      `R_FORMAT: 
          begin 
            ALUSrc = 1'b0;
            RegDst = 1'b1;
	    case (func)
		6'b100_000: ALUOp = 4'b0010; //ADD
		6'b100_010: ALUOp = 4'b0110; //SUB
		6'b100_100: ALUOp = 4'b0000; //AND
		6'b100_101: ALUOp = 4'b0001; // OR
		6'b101_010: ALUOp = 4'b0111; //SLT
		default:    ALUOp = 4'bx;
	    endcase
	    MemRead = 1'b0;
	    Branch = 1'b0;
            BranchBNE = 1'b0;
	    MemWrite = 1'b0;    
	    RegWrite = 1'b1;
	    MemToReg = 1'b0;	   
          end
       `LW :
	 begin 
            RegDst = 1'b0;
	    RegWrite = 1'b1;
	    MemRead = 1'b1; 
	    ALUSrc = 1'b1;
	    Branch = 1'b0;
            BranchBNE = 1'b0;
	    MemWrite = 1'b0; 
	    MemToReg = 1'b1;
	    ALUOp = 4'b0010;
          end

        `SW :
	  begin
            ALUOp = 4'b0010;
            ALUSrc = 1'b1;
            RegDst = 1'bx;
	    RegWrite = 1'b0;
	    MemRead = 1'b0;
	    Branch = 1'b0;
            MemToReg = 1'bx;
	    MemWrite = 1'b1;
       	  end

       `BEQ :
	begin
	    RegDst = 1'bx;
	    RegWrite = 1'b0;
	    MemRead = 1'b0;
	    ALUSrc = 1'b0;
	    Branch = 1'b1;
            BranchBNE = 1'b0;
	    MemWrite = 1'b0;
	    MemToReg = 1'bx;
	    ALUOp = 4'b0110;
	end
        
       `BNE:
	begin
	    RegDst = 1'bx;
	    RegWrite = 1'b0;
	    MemRead = 1'b0;
	    ALUSrc = 1'b0;
	    Branch = 1'b0;
	    BranchBNE = 1'b1;
	    MemWrite = 1'b0;
	    MemToReg = 1'bx;
	    ALUOp = 4'b0110;
	end

         `ADDI:  
         begin      
           RegWrite = 1'b1;
           RegDst = 1'b0;
           ALUSrc = 1'b1; 
           Branch = 0'b0;
           BranchBNE = 1'b0;
           MemWrite = 1'b0;
           MemToReg = 0'b0;
           ALUOp = 4'b0010; 
         end
	`NOP:
	 begin
	    RegDst = 1'b0;
	    RegWrite = 1'b0;
	    MemRead = 1'b0;
	    ALUSrc = 1'b0;
	    Branch = 1'b0;
	    BranchBNE = 1'b0;
	    MemWrite = 1'b0;
	    MemToReg = 1'b0;
	    ALUOp = 4'bx;
	 end

	default:
	begin
	    RegDst = 1'bx;
	    RegWrite = 1'b0;
	    MemRead = 1'bx;
	    ALUSrc = 1'bx;
	    Branch = 1'bx;
	    BranchBNE = 1'bx;
	    MemWrite = 1'b0;
	    MemToReg = 1'bx;
	    ALUOp = 4'b0;
	end
      endcase
    end // always
    
endmodule
