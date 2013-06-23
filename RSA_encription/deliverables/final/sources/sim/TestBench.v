//testbench.v - testbench to simulate the hardware in project 3
//
// Created By:	Jesse Inkpen
// Date:	30-October-2012
//
///////////////////////////////////////////////////////////////////////////


`timescale  1 ns / 1 ns
`define BITS 128

module testbench;
	
	wire			d;			// result done signal
	wire [`BITS-1:0] 	r;			// output result
	wire [`BITS-1:0]	m;			// input message
	wire [`BITS-1:0]	e;			// exponent
	wire [`BITS-1:0]	n;			// modulous
	
	
	reg [7:0]		db_sw;			// debounced switches
	reg [4:0]		db_btns;		// debounced buttons
	wire [`BITS-1:0]	M;			// input message
	wire [`BITS-1:0]	E;			// exponent
	wire [`BITS-1:0]	N;			// modulous
	wire 			GO;			// encription control signal
	wire 			RESET;			// RESET signal
	wire			LOAD;			// memory control signal
	wire			DONE;			// RESULT latched in memory signal
	wire [`BITS-1:0] 	RESULT;			// result in lelory for display
	
	wire [15:0]		display;		// lower 16 bits of result displaye
	wire [7:0]		led;
	
	reg clock = 0;
	always #10 clock = ~clock;
	// set simulation mode using "defparm"
	
	// define stimulus interval
	//parameter IVL = 5000;
	
	 // instantiate FPGA (
	 
	 STIMULOUS stim(clock,db_btns,db_sw,GO,RESET,LOAD,M,E,N,RESULT,DONE,display,led);
	 
	 MEMORY mem(clock,RESET,LOAD,M,E,N,m,e,n,r,d,RESULT,DONE);
	  
	 //RSA encr(clock,GO,m,e,n,r,d);
	 MontgomeryExponential encr(

	.X(m),
	.E(e),
	.M(n),
	.clk(clock),
	.go(GO),
	
	.done(d),
	.Z(r)
	); 
	 
	initial begin
	 // alter number so that they are real ASCII and RSA. 
	  #0 db_btns = 0;
	  #0 db_sw = 0;
	  #40 db_btns = 5'b00001;
	  #40 db_btns = 5'b00000;
	  #40 db_sw = 8'b00000010;
	  #40 db_btns = 5'b00010;
	  #40 db_btns = 5'b00000;
	  #40 db_btns = 5'b00100;
	  #40 db_btns = 5'b00000;
//	  #500 db_sw = 8'b00000011;
//	  #40 db_btns = 5'b00010;
//	  #40 db_btns = 5'b00000;
//	  #40 db_btns = 5'b00100;
//	  #40 db_btns = 5'b00000;
//	  #10000 $stop;
	  
	  end
	  
	  
endmodule

