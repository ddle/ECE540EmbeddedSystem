

`define BITS 32
module mod_test();

mod_module SUT (
    .dividend(A), 
    .divisor(B), 
    .start(START), 
    .clk(clock), 
    .remainder(), 
    .done()
    );

	reg clock = 0;
	reg [2*`BITS-1:0] A;
	reg [`BITS-1:0] B;
	
	reg START;
		
	always #10 clock = ~clock;
	
	initial 
	begin
		START = 1'b0;
		A = 50003;
		B = 100;
	
	#50
		START = 1'b1;
	
	#1000 $finish;
	end
endmodule
		