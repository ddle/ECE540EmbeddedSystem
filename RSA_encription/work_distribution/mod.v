`define BITS 32

module mod_module(
	input [2*`BITS-1:0] dividend,
	input [`BITS-1:0] divisor,
	input start,
	input clk,
	output reg [`BITS-1:0] remainder,
	output reg done
	);
	
	reg in_process;
	reg [2*`BITS-1:0] dividend_reg;
	
	always @(posedge clk or posedge start)
	begin
		if (~start) 
		begin
			remainder <= `BITS'b0;
			done <= 1'b0;
			in_process <= 1'b0;
		end
		
		else
		begin
			if (in_process == 1'b0)
			begin
				dividend_reg <= dividend;
				in_process <= 1'b1;
			end
			
			else if (dividend > divisor)
			begin
				done <= 1'b0;
				dividend_reg <= dividend_reg - divisor;
				remainder	<= `BITS'b0;
			end
	
			else
			begin
				done <= 1'b1;
				remainder	<= dividend_reg;
			end
		end
	end
			
endmodule	
		