`include "constants.h"

/************** Main control in ID pipe stage  *************/
module control_main(output reg RegDst,
                output reg [1:0] Branch,  
                output reg MemRead,
                output reg MemWrite,  
                output reg MemToReg,  
                output reg ALUSrc, 
		output reg Shift, 
                output reg RegWrite,  
                output reg [1:0] ALUcntrl,  
                output reg Jump,  
                input [5:0] opcode, 
                input [5:0] func);

  always @(*) 
   begin
     case (opcode)
      `R_FORMAT: 
          begin 
            RegDst = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
	    Jump = 1'b0;
	    if (func == 6'b000000)
	      Shift = 1'b1;
	    else
	      Shift = 1'b0;
            RegWrite = 1'b1;
            Branch = 2'b0;         
            ALUcntrl  = 2'b10; // R    
          end
       `LW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b1;
            MemWrite = 1'b0;
            MemToReg = 1'b1;
            ALUSrc = 1'b1;
	    Jump = 1'b0;
	    Shift = 1'b0;
            RegWrite = 1'b1;
            Branch = 2'b0;
            ALUcntrl  = 2'b00; // add
           end
        `SW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b1;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
	    Jump = 1'b0;
	    Shift = 1'b0;
            RegWrite = 1'b0;
            Branch = 2'b0;
            ALUcntrl  = 2'b00; // add
           end
       `BEQ:  
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
	    Jump = 1'b0;
	    Shift = 1'b0;
            RegWrite = 1'b0;
            Branch = 2'b01;
            ALUcntrl = 2'b01; // sub
           end
        `BNE:  
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
	    Jump = 1'b0;
	    Shift = 1'b0;
            RegWrite = 1'b0;
            Branch = 2'b10;
            ALUcntrl = 2'b01; // sub
           end
	6'b001000:  //ADDI
           begin      
            RegWrite = 1'b1;
	    MemRead = 1'b0;
            RegDst = 1'b0;
            ALUSrc = 1'b1; 
	    Jump = 1'b0;
	    Shift = 1'b0;
            Branch = 2'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUcntrl = 2'b00; 
         end
       6'b000010: //JUMP
	   begin
            RegWrite = 1'b0;
	    MemRead = 1'bx;
            RegDst = 1'bX;
            ALUSrc = 1'bX;
	    Jump = 1'b1; 
	    Shift = 1'bx;
            Branch = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'bx;
            ALUcntrl = 2'bxx;
	   end
       default:
           begin
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
	    Jump = 1'b0;
	    Shift = 1'b0;
            Branch = 2'b0;
            RegWrite = 1'b0;
            ALUcntrl = 2'b00; 
         end
      endcase
    end // always
endmodule


/**************** Module for Bypass Detection in EX pipe stage *********/
 module  control_bypass_ex(output reg [1:0] bypassA,
                       output reg [1:0] bypassB,
                       input [4:0] idex_rs,
                       input [4:0] idex_rt,
                       input [4:0] exmem_rd,
                       input [4:0] memwb_rd,
                       input       exmem_regwrite,
                       input       memwb_regwrite);
       

  always @(*)
        begin
		bypassA <= 2'b00;
		bypassB <= 2'b00;
          //Forward from EXMEM (previous instruction)
        if (exmem_regwrite == 1 && exmem_rd != 0 && exmem_rd == idex_rs)
              bypassA <= 2'b10;
        if (exmem_regwrite == 1 && exmem_rd != 0 && exmem_rd == idex_rt)
              bypassB <= 2'b10;

          //Forward from MEMWB (two instr before)    
        if ((memwb_regwrite == 1 && memwb_rd != 0 && memwb_rd == idex_rs)
              && (exmem_rd != idex_rs || exmem_regwrite == 0))
              bypassA <= 2'b01;
        if ((memwb_regwrite == 1 && memwb_rd != 0 && memwb_rd == idex_rt)
              && (exmem_rd != idex_rt || exmem_regwrite == 0))
              bypassB <= 2'b01;
          end
       
endmodule          
                       

/**************** Module for Stall Detection in ID pipe stage *********/
module control_stall_id(input MemWrite,
                         output reg PCWrite,
			 output reg ifid_write,
			 output reg stall,
			 input [4:0] ifid_rs,
			 input [4:0] ifid_rt,
			 input idex_memread,
			 input [4:0] idex_rt);

always @(*)
	  begin
		if (idex_memread == 1 && ((MemWrite == 1 && idex_rt == ifid_rs) || 
                (MemWrite == 0 && (idex_rt == ifid_rs || idex_rt == ifid_rt))))begin
	   	  stall <= 1'b1;
	   	  PCWrite <= 1'b1;
		  ifid_write <= 1'b1;
                end
		else begin
		  stall <= 1'b0;
		  PCWrite <= 1'b0;
		  ifid_write <= 1'b0;
		end
end
endmodule
                       
/************** control for ALU control in EX pipe stage  *************/
module control_alu(output reg [3:0] ALUOp,                  
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func)  
    begin
      case (ALUcntrl)
        2'b10: 
           begin
             case (func)
              6'b100000: ALUOp = 4'b0010; // add
              6'b100010: ALUOp = 4'b0110; // sub
              6'b100100: ALUOp = 4'b0000; // and
              6'b100101: ALUOp = 4'b0001; // or
              6'b100111: ALUOp = 4'b1100; // nor
              6'b101010: ALUOp = 4'b0111; // slt
	      6'b000000: ALUOp = 4'b1111; // sll
	      6'b000100: ALUOp = 4'b1111; // sllv
              6'b100110: ALUOp = 4'b0011; // xor
              default: ALUOp = 4'b0000;       
             endcase 
          end   
        2'b00: 
              ALUOp  = 4'b0010; // add
        2'b01: 
              ALUOp = 4'b0110; // sub
        default:
              ALUOp = 4'b0000;
     endcase
    end
endmodule
