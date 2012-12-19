`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:42:31 11/15/2012 
// Design Name: 
// Module Name:    MontgomeryMultiplier 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This module does (A*B mod M). Magic! 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define BITS 4
module MontgomeryMultiplier(
	input [`BITS-1:0] A,
	input [`BITS-1:0] B,
	input [`BITS-1:0] M,
	input clk,
	input go,
	
	output reg done,
	output reg [`BITS-1:0] S
	
);

	parameter index_width = 5;
	
	reg [`BITS-1:0] first_sum = 0;
	reg [`BITS-1:0] S_reg = 0;
	reg [index_width : 0] i = 0;

	
	always @(posedge clk) begin
		if (~go) begin              // waiting for signal go
			i = 0;
			S_reg = 0;
			done = 0;
		end
		else if (i == `BITS) begin  // completing for loop
			done = 1;
			S = S_reg;			
		end
		else begin                  // repeat this until done		
			first_sum = B[i] ? (S_reg + A) : S_reg;					
			S_reg = ( first_sum[0] ? ( first_sum + M ) : first_sum ) >> 1;	
			i = i + 1;
		end		
	end
	
endmodule
