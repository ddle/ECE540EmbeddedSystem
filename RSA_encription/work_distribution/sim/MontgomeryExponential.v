`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:49:04 11/17/2012 
// Design Name: 
// Module Name:    MontgomeryExponential 
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
`define BITS 4
`define DOUBLEBITS `BITS*2
module MontgomeryExponential(

	input [`BITS-1:0] X,
	input [`BITS-1:0] E,
	input [`BITS-1:0] M,
	input clk,
	input go,
	
	output reg done,
	output reg [`BITS-1:0] Z
);
	parameter index_width = 6;

	parameter RESET  = 5'b00001;
	parameter INIT_0 = 5'b00010;
	parameter INIT_1 = 5'b00100;
	parameter LOOP   = 5'b01000;
	parameter DONE   = 5'b10000;
	//
	//
	//
	reg [index_width : 0] i = 0;

	reg [4:0] current_state, next_state = 0;
	
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
	
	reg [`BITS*2:0] modY_reg = 0;
	reg [`BITS*2:0] modX_reg = 0;
	wire [`BITS*2:0] modR;
	wire mod_done;
	reg mod_go;
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
	//
	//
	always @(posedge clk) begin
		//A0_reg <= 0;
		//B0_reg <= 0;
		//M0_reg <= 0;
		//go_0 <= 0;
		
		//A1_reg <= 0;
		//B1_reg <= 0;
		//M1_reg <= 0;
		//go_1 <= 0;
		//done <= 0;
		//Z <= 0;		
		
		case (current_state)
			RESET:  //
				begin			
					done <= 0;
					Z <= 0;	
					go_0 <= 0;					
					go_1 <= 0;
					mod_go <= 0;
					if (go) begin
						next_state <= INIT_0;
						
						//next_state <= LOOP;
						//Z_reg <= `BITS'b1;
						//P_reg <= X;
					end	
				end

			INIT_0: // Nr = 2^2n mod M ; (2n + 1) bits
				begin					
					if(mod_done) begin
						next_state <= INIT_1;
						Nr_reg <= modR[`BITS-1:0];
						mod_go <= 0;
					end
					else begin
						modY_reg <= 1 << `DOUBLEBITS; // 2^2n
						modX_reg <= M;					
						mod_go <= 1;						
					end					
				end
			INIT_1: // Z0 = MontProd(1,Nr,M), P0 = MontProd(X,Nr,M)
				begin	
					if(done_0 && done_1) begin
						next_state <= LOOP;
						Z_reg <= S0_out;
						P_reg <= S1_out;
						go_0 <= 0;
						go_1 <= 0;
					end
					else begin
						A0_reg <= 1;
						B0_reg <= Nr_reg;					
						go_0 <= 1;
						
						A1_reg <= X;
						B1_reg <= Nr_reg;					
						go_1 <= 1;
					end
						
				end
			LOOP: // 
				begin
					// Pi+1 = MontProd(Pi,Pi,M)					
					// Zi+1 = MontProd(Zi,Pi,M)
					if (done_0 && done_1) begin
						P_reg <= S0_out;
						
						if (E[i] == 1'b1)
							Z_reg <= S1_out;
						else 
							Z_reg <= Z_reg;
						
						go_0 <= 0;
						go_1 <= 0;
						
						i = i + 1;
						if( i == `BITS )
							next_state <= DONE;
					end
					else begin
						A0_reg <= P_reg;
						B0_reg <= P_reg;					
						go_0 <= 1;
						
						A1_reg <= Z_reg;
						B1_reg <= P_reg;					
						go_1 <= 1;
					end			
				end	
			DONE:
				begin	// Zn = MontProd(1,Zn,M)				
					if(done_0) begin
						Z <= S0_out;
						done <= 1;
					end
					else begin
						A0_reg <= 1'b1;
						B0_reg <= Z_reg;					
						go_0 <= 1;						
					end
					//Z <= Z_reg;
					//done <= 1;
					if(~go)
						next_state <= RESET;
				end
		endcase
	end
	//
	//
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
	mod mod0(
	.Y(modY_reg),
	.X(modX_reg),
	.clk(clk),
	.go(mod_go),

	.R(modR),
	.done(mod_done)
	);
endmodule
