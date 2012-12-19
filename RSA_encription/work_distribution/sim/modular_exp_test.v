`define BITS 4


module modular_exp_test();

reg [`BITS-1:0]M;
reg [`BITS-1:0]E;
reg [`BITS-1:0]N;

reg GO;

modular_exp sut (
    .clk(), 
    .go(GO), 
    .m(M), 
    .e(E), 
    .n(N), 
    .r(), 
    .d()
    );

initial begin
	M = 0;
	E = 0;
	N = 0;
	GO = 0;
	
	# 10
	GO = 1;
	
		M = 4;
		E = 13;
		N = 7;
		#10;
		
		M = 5;
		E = 2;
		N = 9;
		#10;
		
		M = 6;
		E = 3;
		N = 13;
		#10;
		
		M = 3;
		E = 7;
		N = 8;
		#10;
		
		M = 9;
		E = 3;
		N = 13;
		#10;
		
		M = 5;
		E = 5;
		N = 7;
		#10;		

	# 10 $finish;
end
endmodule
