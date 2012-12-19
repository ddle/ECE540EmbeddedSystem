`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:02:53 11/20/2012
// Design Name:   mod
// Module Name:   C:/Users/cob/Documents/My Dropbox/541-SoC/project/project3/RSAcode/test_mod.v
// Project Name:  RSAcode
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mod
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`define BITS 65
module test_mod;

reg [`BITS-1:0] X;
reg [`BITS-1:0] Y;
	reg clk;
	reg go;

	// Outputs
	wire [`BITS-1:0] M;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	mod uut (
		.X(X), 
		.Y(Y), 
		.clk(clk), 
		.go(go), 
		.M(M), 
		.done(done)
	);
	always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		X = 0;
		Y = 0;
		clk = 0;
		go = 0;

		// Wait 100 ns for global reset to finish
		#100;
      X = 4;
		Y = 21;		
		go = 1;  
		
		#300;
		go = 0;  
		#300;
      X = 1073602561;
		Y = 65'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;		
		go = 1;  
		// Add stimulus here

	end
      
endmodule

