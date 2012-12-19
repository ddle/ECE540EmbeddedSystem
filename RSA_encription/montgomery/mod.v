`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:28:48 11/20/2012 
// Design Name: 
// Module Name:    mod 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define BITS 64
`define DOUBLEBITS 128


module mod(
input [`DOUBLEBITS:0] X,
input [`DOUBLEBITS:0] Y,
input clk,
input go,

output reg [`BITS-1:0] R,
output reg done
);

	parameter RESET  = 4'b0001;
	parameter INIT = 4'b0010;	
	parameter LOOP   = 4'b0100;
	parameter DONE   = 4'b1000;
	
	reg [3:0] current_state, next_state = 0;

	
	reg [`DOUBLEBITS:0] Y_reg;
	reg [`DOUBLEBITS:0] P;

	always @( posedge clk ) begin
		if( ~go )
			current_state <= RESET;
		else
			current_state <= next_state;	
	end

	always @ (posedge clk) begin
		case (current_state)
			RESET:  //
				begin			
					done <= 0;
					R <= 0;					
					if (go) begin
						next_state <= INIT;
						P <= X;
						Y_reg <= Y;
					end
				end
			INIT:
				begin
					if (P < Y_reg) begin
						P <= P << 1;
						next_state <= INIT;
					end	
					else begin
						P <= P;
						next_state <= LOOP;						
					end
				end
			LOOP:
				begin
					if (P < X)
						next_state <= DONE;
					else begin
						if (Y_reg >= P) begin						
							Y_reg <= Y_reg - P;						
						end
						P <= P >> 1;
					end	
				end
			DONE:
				begin					
					done <= 1;
					R <= Y_reg[`BITS-1:0];
					if (~go)
						next_state <= RESET;
				end
			default:
				next_state <= RESET;
		endcase
	end


endmodule
