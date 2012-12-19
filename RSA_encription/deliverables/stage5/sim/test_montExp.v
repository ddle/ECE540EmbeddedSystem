`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:57:26 11/18/2012
// Design Name:   MontgomeryExponential
// Project Name:  RSAcode
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MontgomeryExponential
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`define BITS 32

module test_montExp;

	// Inputs
	reg [`BITS-1:0] X;
	reg [`BITS-1:0] E;
	reg [`BITS-1:0] M;
	reg clk;
	reg go;

	// Outputs
	wire done;
	wire [`BITS-1:0] Z;

	// Instantiate the Unit Under Test (UUT)
	MontgomeryExponential uut (
		.X(X), 
		.E(E), 
		.M(M), 
		.clk(clk), 
		.go(go), 
		.done(done), 
		.Z(Z)
	);

	always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		X = 0;
		E = 0;
		M = 0;
		clk = 0;
		go = 0;

		// Wait 100 ns for global reset to finish
		#100;
   
		X = 456;
		E = 3;
		M = 1189;
		go = 1;	
		
		#1000000
		X = Z;
		E = 187;
		M = 1189;
		go = 0;
		
		#100	
		go = 1;	
		
		// Add stimulus here

	end
      
endmodule

