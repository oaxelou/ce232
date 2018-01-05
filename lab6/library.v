
`include "constants.h"
`timescale 1ns/1ps

// Small ALU. Inputs: inA, inB. Output: out. 
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU #(parameter N = 32) (out, zero, inA, inB, op);
  output [N-1:0] out;
  output zero;
  input  [N-1:0] inA, inB;
  input  [3:0] op;

  assign out = 
			(op == 4'b0000) ? inA & inB :
			(op == 4'b0001) ? inA | inB :
			(op == 4'b0010) ? inA + inB : 
			(op == 4'b0110) ? inA - inB : 
			(op == 4'b0111) ? ((inA < inB)?1:0) : 
			(op == 4'b1100) ? ~(inA | inB) :
			(op == 4'b1111) ? inB << inA :
			'bx;

  assign zero = (out == 0);
endmodule


// Memory (active 1024 words, from 10 address lsbs).
// Read : disable wen, enable ren, address addr, data dout
// Write: enable wen, disable ren, address addr, data din.
module Memory (clock, reset, ren, wen, addr, din, dout);
  input  clock, reset;
  input  ren, wen;
  input  [31:0] addr, din;
  output [31:0] dout;

  reg [31:0] data[4095:0];
  wire [31:0] dout;

  always @(ren or wen)
    if (ren & wen)
      $display ("\nMemory ERROR (time %0d): ren and wen both active!\n", $time);

  always @(posedge ren or posedge wen) begin
    if (addr[31:10] != 0)
      $display("Memory WARNING (time %0d): address msbs are not zero\n", $time);
  end  

  assign dout = ((wen==1'b0) && (ren==1'b1)) ? data[addr[9:0]] : 32'bx;
  
  /* Write memory in the negative edge of the clock */
   always @(negedge clock)
   begin
    if (reset == 1'b1 && wen == 1'b1 && ren==1'b0)
        data[addr[9:0]] = din;
   end

endmodule


// Register File. Read ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
  input clock, reset;
  input   [4:0] raA, raB, wa;
  input         wen;
  input  [31:0] wd;
  output [31:0] rdA, rdB;
  integer   i;
  reg [31:0] data[31:0];
  
  wire [31:0] rdA = data[raA];
  wire [31:0] rdB = data[raB];
  
  always @(negedge reset)
    for (i = 0; i < 32; i = i+1)
      data[i] = i;  
  
  // Make sure  that register file is only written at the negative edge of the clock 
  always @(negedge clock)
   begin
    if (reset == 1'b1 && wen == 1'b1 && wa != 5'b0)
        data[wa] =  wd;
   end

endmodule

