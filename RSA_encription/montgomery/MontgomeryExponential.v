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
`define BITS 64
`define DOUBLEBITS 128
module MontgomeryExponential(

	input [`BITS-1:0] X,
	input [`BITS-1:0] E,
	input [`BITS-1:0] M,
	input clk,
	input go,
	
	output reg done,
	output reg [`BITS-1:0] Z
);
	parameter index_width = 9;

	parameter RESET  = 6'b000001;
	parameter INIT_0 = 6'b000010;
	parameter INIT_1 = 6'b000100;
	parameter LOOP   = 6'b001000;
	parameter WAIT   = 6'b010000;
	parameter DONE   = 6'b100000;
	
	//
	//
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
	
	//reg [`DOUBLEBITS:0] modY_reg = 0;
	//reg [`DOUBLEBITS:0] modX_reg = 0;
	
	wire [`BITS-1:0] modR;
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
	always @(*)	begin
		case (current_state)
			RESET:  if (go) 
			          next_state = INIT_0; 
			        else 
			          next_state = RESET; 
			INIT_0: if (mod_done)
			          next_state = INIT_1;
			        else 
			          next_state = INIT_0; 
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
	//
	//
	always @(posedge clk) begin
		//go_0 <= 0;
		//go_1 <= 0;
		
		mod_go <= 0;
		case (current_state)
			RESET:  //
				begin			
					done <= 0;
					Z <= 0;	
					go_0 <= 0;					
					go_1 <= 0;
					mod_go <= 0;
               i <= 0;						
				end					
			INIT_0: // Nr = 2^2n mod M ; (2n + 1) bits
				begin							
					mod_go <= 1;						
					if(mod_done) begin
						//Nr_reg <= 128'h3ff0631f602009fe007ce704ffffb;
						//Nr_reg <= 64'd231201614748858675;
                        Nr_reg <= modR;
						mod_go <= 0;
					end					
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
			LOOP: // 
				begin
					// Pi+1 = MontProd(Pi,Pi,M)					
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
				Z <= 32'hFFFF;
				done <= 1;
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
	.Y({1'b1, `DOUBLEBITS'b0}),
	.X({`BITS'b0,1'b0,M}),
	.clk(clk),
	.go(mod_go),

	.R(modR),
	.done(mod_done)
	);
endmodule
