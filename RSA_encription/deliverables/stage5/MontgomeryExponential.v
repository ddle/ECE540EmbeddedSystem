`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Portland State University, ECE 540 Embedded System
// Project 3: RSA Encryption 
// Copyright by Dung Le
// 
// Create Date:    23:49:04 11/17/2012 
// Design Name: 
// Module Name:    MontgomeryExponential 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This module does X^E mod M
//
// Algorithm
//    Nr = (1 << (2*bits))% M
//    Z = MontProd(1,Nr,M)    
//    P = MontProd(X,Nr,M)
//    i = 0
//    while i < bits:        
//        if (ei == 1):
//            Z = MontProd(Z,P,M)
//        P = MontProd(P, P, M)
//        i = i + 1
//    Z = MontProd(1,Z,M)
//    return Z
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define BITS 128

module MontgomeryExponential(

	input [`BITS-1:0] X,
	input [`BITS-1:0] E,
	input [`BITS-1:0] M,
	input clk,
	input go,
	
	output reg done,
	output reg [`BITS-1:0] Z
);
	
	// counter width
	parameter index_width = 9;	
	// state encoding
	parameter RESET  = 6'b000001;
	parameter INIT_0 = 6'b000010;
	parameter INIT_1 = 6'b000100;
	parameter LOOP   = 6'b001000;
	parameter WAIT   = 6'b010000;
	parameter DONE   = 6'b100000;
	//
	// registers for fully piped FSM
	//
	reg [index_width : 0] i = 0;
	reg [5:0] current_state, next_state;	
	reg [`BITS-1:0] A0_reg = 0;
	reg [`BITS-1:0] B0_reg = 0;
	reg [`BITS-1:0] M0_reg = 0;
	reg go_0 = 0;	
	wire done_0;
	wire [`BITS-1:0] S0_out;	
	reg [`BITS-1:0] A1_reg = 0;
	reg [`BITS-1:0] B1_reg = 0;
	reg [`BITS-1:0] M1_reg = 0;
	reg go_1 = 0;	
	wire done_1;	
	wire [`BITS-1:0] S1_out;
	reg [`BITS-1:0] Z_reg = 0;
	reg [`BITS-1:0] P_reg = 0;
	reg [`BITS-1:0] Nr_reg = 0;
	//
	//
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
			          next_state = INIT_0; 
			        else 
			          next_state = RESET; 
			INIT_0: next_state = INIT_1;
			INIT_1: if(done_0 && done_1)
			          next_state = WAIT;
			        else 
			          next_state = INIT_1;
			WAIT: if(done_0 || done_1)
			          next_state = WAIT;
			        else 
			          next_state = LOOP;
			LOOP:   if (i == `BITS-1) 
			          next_state = DONE;
			        else if(done_0 && done_1)
			          next_state = WAIT;  					
					  else
					    next_state = LOOP;
			DONE:   if (~go) 
			          next_state = RESET;
			        else
			          next_state = DONE; 
			default:
					next_state = RESET;

		endcase
	end
	//
	// montgomery exponential FSM translated, see above algorithm
	//
	always @(posedge clk) begin
		case (current_state)
			RESET:  //
				begin			
					done <= 0;
					Z <= 0;	
					go_0 <= 0;					
					go_1 <= 0;
					i <= 0;						
				end					
			INIT_0: // Nr = 2^2n mod M ; pre-calculated with given M
				begin
					Nr_reg <= 128'd20749395855681433554012913154392059;
				end
			INIT_1: // Z0 = MontProd(1,Nr,M), P0 = MontProd(X,Nr,M)
				begin	
					A1_reg <= 1;
					B1_reg <= Nr_reg;					
					go_1 <= 1;						
					A0_reg <= X;
					B0_reg <= Nr_reg;			
					go_0 <= 1;
					if(done_0 && done_1) begin						
						Z_reg <= S1_out;
						P_reg <= S0_out;						
						go_0 <= 0;
						go_1 <= 0;						
					end		
				end
			WAIT: begin
					go_0 <= 0;
					go_1 <= 0;
				end
			LOOP:     // repeat the following until done:
				begin // Pi+1 = MontProd(Pi,Pi,M)					
					  // Zi+1 = MontProd(Zi,Pi,M)
					A0_reg <= P_reg;
					B0_reg <= P_reg;					
					go_0 <= 1;					
					A1_reg <= Z_reg;
					B1_reg <= P_reg;					
					go_1 <= 1;
					if (done_0 && done_1) begin
						P_reg <= S0_out;						
						go_0 <= 0;
						go_1 <= 0;					
						i <= i + 1'b1;
						if (E[i] == 1'b1)
							Z_reg <= S1_out;
						else 
							Z_reg <= Z_reg;
					end						
				end	
			DONE:
				begin	// Zn = MontProd(1,Zn,M)
					A1_reg <= 1;
					B1_reg <= Z_reg;					
					go_1 <= 1;						
					if(done_1) begin
						Z <= S1_out;
						done <= 1;
					end
				end
			default: begin // debug state
				Z <= 32'hFA11;
				done <= 1;
			end
		endcase
	end
	//
	// instantiate two Multipliers to reduce latency
	//
	MontgomeryMultiplier MontProd0(
		.A(A0_reg),
		.B(B0_reg),
		.M(M),
		.clk(clk),
		.go(go_0),	
		.done(done_0),
		.S(S0_out)	
	);

	MontgomeryMultiplier MontProd1(
		.A(A1_reg),
		.B(B1_reg),
		.M(M),
		.clk(clk),
		.go(go_1),	
		.done(done_1),
		.S(S1_out)	
	);

endmodule
