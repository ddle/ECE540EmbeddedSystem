//MEMORY.v - memory interface for the hardware in project 3
//
// Created By:	Jesse Inkpen
// Date:	30-October-2012
//
///////////////////////////////////////////////////////////////////////////


`define BITS 128

module MEMORY(
	input			CLK,		// clock in
	input 			RESET,		// result memory reset
	input 			LOAD,		// load control 
	
	input  [`BITS-1:0]	M,		// message to load
	input  [`BITS-1:0]	E,		// exponent to load
	input  [`BITS-1:0]	N,		// modulous to load
		
	output reg [`BITS-1:0]	m,		// loaded message
	output reg [`BITS-1:0]	e,		// loaded exponent
	output reg [`BITS-1:0]	n,		// loaded modulous
	
	input [`BITS-1:0]	r,		// result input
	input 			done,		// done signal from hw
	
	output reg [`BITS-1:0]	RESULT,		// loaded result
	output reg		DONE		// loaded done
	);
	
	reg 			done1;		// temp 
		
	always @(posedge CLK) 
		if (LOAD) begin
			m <= M;
			e <= E;
			n <= N;
			end
			
	always @(posedge CLK) 
		if (RESET) RESULT <= 0;
		else begin
			done1 <= done;
			DONE <= done1;
			if (done && ~ DONE) RESULT <= r;
		end
	
endmodule
	
	
	
