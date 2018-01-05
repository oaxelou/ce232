

// Opcodes 
// R-format
`define R_FORMAT  6'b0
`define SLL 6'b000000
`define SRL 6'000010
`define SLLV 6'b000100
`define SRLV 6'b000110
`define ADD 6'b100000            
`define SUB 6'b100010
`define AND 6'b100100
`define OR  6'b100101
`define NOR 6'b100111
`define SLT 6'b101010

// I-format 

`define ADDI 6'b001000
`define LW  6'b100011 
`define SW  6'b101011 
`define BEQ  6'b000100 
`define BNE  6'b000101
`define NOP  32'b0000_0000_0000_0000_0000_0000_0000_0000
