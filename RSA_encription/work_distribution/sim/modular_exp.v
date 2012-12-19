//ENCRIPTION.v - This is the encription hardware for project 3.
//
// Created By:	Jesse Inkpen
// Date:	30-October-2012
//
///////////////////////////////////////////////////////////////////////////

`define BITS 4

module modular_exp(
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

	always @*
		if (go)
		begin
			mr = m;
			for(i = 0; i < `BITS+1; i = i+1)
			begin
				mr = (mr*mr) % n;
				if (e[i])
					mr = (mr*m) % n;
			end
						
			$display("actual = %d  calculated = %d", (m^e)%n, mr);

		end
		
endmodule
		
		
	
