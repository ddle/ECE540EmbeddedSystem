`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Portland State University, ECE 540 Embedded System
// Project 3: RSA Encryption 
// Copyright by Dung Le
//
// Create Date:    22:42:31 11/15/2012 
// Design Name: 
// Module Name:    MontgomeryMultiplier 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This module gives S = (A*B 2^-n mod M).
//
// Algorithm:
//    S = 0
//    i = 0
//   while i < bits:
//        q = (S + bi*A) % 2       
//        S = ( S + q*M + bi*A ) / 2
//        i = i + 1
//    if S >= M :
//        return S - M
//    else :       
//       return S
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define BITS 128

module MontgomeryMultiplier(
	input [`BITS-1:0] A,
	input [`BITS-1:0] B,
	input [`BITS-1:0] M,
	input clk,
	input go,
	
	output reg done,
	output reg [`BITS-1:0] S
	
);
	// state encoding
	parameter RESET  = 5'b00001;
	parameter LOOP_0 = 5'b00010;
	parameter LOOP_1 = 5'b00100;
	parameter LOOP_2 = 5'b01000;	
	parameter DONE   = 5'b10000;
	// counter width
	parameter index_width = 9;
	//
	// registers for fully piped FSM
	//
	reg [5:0] current_state, next_state = 0;	
	reg [`BITS:0] first_sum = 0;
	reg [`BITS:0] second_sum = 0;
	reg [`BITS-1:0] S_reg = 0;
	reg [index_width : 0] i = 0;
	//
	always @( posedge clk ) begin
		if( ~go )
			current_state <= RESET;
		else
			current_state <= next_state;	
	end
	//
	// next state logic
	//
	always @(*)	begin
		case (current_state)
			RESET:  if (go) 
			          next_state = LOOP_0; 
			        else 
			          next_state = RESET; 
			LOOP_0: next_state = LOOP_1;			        
			LOOP_1: next_state = LOOP_2; 
			LOOP_2: if (i == `BITS-1) 			          			        
			          next_state = DONE;			 
					  else
					    next_state = LOOP_0;
			DONE:   if (~go) 
			          next_state = RESET;
			        else
			          next_state = DONE; 
			default:
			        next_state = RESET; 
		endcase
	end
	//
	// montgomery multiplier FSM translated, see above algorithm 
	//
	always @(posedge clk) begin
		case (current_state)
			RESET:  //
				begin			
					i <= 0;
					S_reg <= 0;
					S <= 0;
					done <= 0;
					first_sum <= 0;
					second_sum <= 0;					
				end
			LOOP_0:  //
				begin					
					first_sum <= B[i] ? ( S_reg + A ) : S_reg;					
				end
			LOOP_1:  //
				begin					
					second_sum <= first_sum[0] ? ( first_sum + M ) : first_sum ;					
				end
			LOOP_2:  //
				begin					
					S_reg <=  second_sum[`BITS:1] ;
					i <= i + 1'b1;
				end
			DONE:  //
				begin					
					if(S_reg >= M)
						S <= S_reg - M;
					else
						S <= S_reg;			
					done <= 1;
				end
		endcase
	end	
endmodule
