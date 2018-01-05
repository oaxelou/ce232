// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`timescale 1ns/1ps

module cpu_tb;

reg       clock, reset;    // Clock and reset signals
reg   [4:0] raA, raB, wa;
reg         wen;
reg   [31:0] wd;
wire  [31:0] rdA, rdB;
integer i;

// Instantiate regfile module
RegFile regs(clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

initial begin  // Ta statements apo ayto to begin mexri to "end" einai seiriaka
      
  // Initialize the module 
   clock = 1'b0;       
   reset = 1'b0;  // Apply reset for a few cycles
   #(4.25*`clock_period) reset = 1'b1;
   
   // Initialize Register File with "random" numbers
   for (i = 0; i < 32; i = i+1)
      regs.data[i] = i;   // Note that R0 = 0 in MIPS 
      
  // Now apply some inputs
   raA = 32'h1; raB = 32'h13; 
#(2*`clock_period)  
   raA = 32'hA; raB = 32'h1F; 
#(2*`clock_period)
   wa = 32'h0A; wd = 32'hAA; wen = 1'b1; 
end 

// Generate clock by inverting the signal every half of clock period
always 
   #(`clock_period / 2) clock = ~clock;  
   
endmodule
