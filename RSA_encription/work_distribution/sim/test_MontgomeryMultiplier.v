`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:15:41 11/17/2012
// Design Name:   MontgomeryMultiplier
// Module Name:   C:/Users/cob/Documents/My Dropbox/541-SoC/project/project3/RSAcode/sim/test_MontgomeryMultiplier.v
// Project Name:  RSAcode
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MontgomeryMultiplier
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`define BITS 4
module test_MontgomeryMultiplier;

	// Inputs
	reg [`BITS - 1:0] A;
	reg [`BITS - 1:0] B;
	reg [`BITS - 1:0] M;
	reg clk;
	reg go;

	// Outputs
	wire done;
	wire [`BITS - 1:0] S;

	// Instantiate the Unit Under Test (UUT)
	MontgomeryMultiplier uut (
		.A(A), 
		.B(B), 
		.M(M), 
		.clk(clk), 
		.go(go), 
		.done(done), 
		.S(S)
	);

	always #5 clk = ~clk; // 100 Mhz
	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		M = 0;		
		go = 0;
		clk = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
      A = 8;
		B = 4;
		M = 6;
		#20;	
		go = 1;
		
		// Add stimulus here

	end
      
endmodule

