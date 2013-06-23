//ENCRIPTION.v - This is the encription hardware for project 3.
//
// Created By:	Jesse Inkpen
// Date:	30-October-2012
//
///////////////////////////////////////////////////////////////////////////

`define BITS 16

module RSA(
	input				clk,		// clock
	input				go,		// hardware go go go
	input	[`BITS-1:0]		m,		// message
	input	[`BITS-1:0]		e,		// exponent
	input	[`BITS-1:0]		n,		// modulous
			
	output	reg [`BITS-1:0]		r,		// post processing result
	output	reg			d		// done signal
	);
	
	reg 	[`BITS*2-1:0]		mr;		// message register
	reg	[`BITS-1:0]		i;		// index

	reg	[5:0] state, next;
	reg mod_inputs_valid;
	wire mod_done;
	wire [`BITS-1:0] mod_output;
	reg	mod_reset;
	
	parameter RESET 	= 6'b000001;
	parameter CHECK_MR 	= 6'b000010;
	parameter CHECK_EXP	= 6'b000100;
	parameter MOD 		= 6'b001000;
	parameter MULT 		= 6'b010000;
	parameter DONE 		= 6'b100000;
	
	/* always @(posedge clk or negedge go)
	begin
		if (~go)	state <= RESET;
		else		state <= next;
	end

	always	@*
	begin
		next = 6'bxxxxxx;
		case (state)
			RESET:	begin
						if (~go)	next = RESET;
						else		next = CHECK_MR;	
					end
					
			CHECK_MR: begin
						if (mr<n) 	next = CHECK_EXP;
						else		next = MOD;
					end
					
			CHECK_EXP: begin
						if (i==e)	next = DONE;
						else		next = MULT;
					end
			
			MULT:	begin
									next = CHECK_MR;
					end
					
			MOD:	begin
						if (mod_done) next = CHECK_MR;
						else		  next = MOD;
					end
					
			DONE:	begin
						next = DONE;
					end
		endcase
	end
	
	always @(posedge clk or negedge go)
	begin
		if (~go)
		begin
			i 	<= 0;
			mr 	<= 1;
			d 	<= 0;
			mod_inputs_valid <= 1'b0;
			r <= 0;
		end
		
		else
		begin
			// default outputs
			mod_inputs_valid 	<= 1'b0;
			d 					<= 0;
			mr					<= mr;
			i					<= i;
			r					<= 0;
			mod_reset			<= 1'b0;
			
			case (next)
				CHECK_MR, CHECK_EXP: ;	// default outputs;
				
				MULT:	begin	
							mr <= mr[`BITS-1:0] * m;
							i <= i+1'b1;
						end
						
				MOD:	begin
							mod_reset			<= 1'b1;
							mod_inputs_valid 	<= 1'b1;
							if (mod_done) mr 	<= mod_output;
						end
						
				DONE:	begin
							r <= mr[`BITS-1:0];
							d <= 1;
						end
			endcase
		end
	end */
							
	

	
	always @(posedge clk) begin
		if (~ go) begin
			i <= 0;
			mr <= 1;
			d <= 0;
			end
		else if (mr<n ) begin
			if (i==e) begin
				d <= 1;
				r <= mr[`BITS-1:0];
				end
			else begin
				mr <= mr[`BITS-1:0] * m;
				i <= i+1;
				end
			end
		else
		begin
			mr <= mr % n;
		end
	end

// mod_ip_core MODULUS (
  // .aresetn(mod_reset), // input aresetn
  // .aclk(clk), // input aclk
  // .s_axis_divisor_tvalid(mod_inputs_valid), // input s_axis_divisor_tvalid
  // .s_axis_divisor_tdata(n), // input [31 : 0] s_axis_divisor_tdata
  // .s_axis_dividend_tvalid(mod_inputs_valid), // input s_axis_dividend_tvalid
  // .s_axis_dividend_tdata(mr), // input [63 : 0] s_axis_dividend_tdata
  // .m_axis_dout_tvalid(mod_done), // output m_axis_dout_tvalid
  // .m_axis_dout_tdata(mod_output) // output [95 : 0] m_axis_dout_tdata	
// );
  endmodule
		
		
	
