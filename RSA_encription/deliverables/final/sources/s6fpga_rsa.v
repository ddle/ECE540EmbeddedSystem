// s3efpga.v - Top level module for digilent spartan 6 FPGA board as used in project 3
//
// Created By:	Jesse Inkpen
// Date:	30-October-2012
//
// Description:
// ------------
// Top level module for project 3 on the Digilent Nexys3 Spartan-6 
//
// Use the pushbuttons to control the encription logic:
//	btns		btn_center	reset
//	btnd		btn_down	load encription engine	
//	btnr 		btn_right	go, start the encription engine
//	btnu 		btn_up		stop the encription engine	
//	btnl 		btn_left        not used
//
// Use the switches to control the data that is loaded into the encription engine
//	SW 0 		_public key_ / private key
//	SW 1 - 7 	_plain text_ / encripted word pairs
//
//	LED light up for legitimate switch configurations.
//	
//	The Display shows the loaded message, and post processing message
///////////////////////////////////////////////////////////////////////////

`define BITS 128

module s6efpga (
	input 			clk100,          	// 100MHz clock from on-board oscillator
	input			btnl, btnr,		// pushbutton inputs - left and right
	input			btnu, btnd,		// pushbutton inputs - top and bottom
	input			btns,			// pushbutton inputs - center button
	input	[7:0]		sw,			// switch inputs
	
	output	[7:0]		led,  			// LED outputs	
	
	output 	[7:0]		seg,			// Seven segment display cathode pins
	output	[3:0]		an			// Seven segment display anode pins	
	
//	output	[3:0]		JA			// JA Header
); 


	// internal variables
	wire [7:0]		db_sw;			// debounced switches
	wire [4:0]		db_btns;		// debounced buttons
								
	wire			sysclk;			// 100MHz clock from on-board oscillator	
	wire			sysreset;		// system reset signal - asserted high to force reset
	
	wire [4:0]		dig3, dig2, dig1, dig0;	// display digits
	wire [3:0]		decpts;			// decimal points
	wire [7:0]		chase_segs;		// chase segments from Rojobot (debug)

	
	// RSA Hacks
	
	wire			d;			// result done signal
	wire [`BITS-1:0] 	r;			// output result
	wire [`BITS-1:0]	m;			// input message
	wire [`BITS-1:0]	e;			// exponent
	wire [`BITS-1:0]	n;			// modulous
	
	wire [`BITS-1:0]	M;			// input message
	wire [`BITS-1:0]	E;			// exponent
	wire [`BITS-1:0]	N;			// modulous
	wire 			GO;			// encription control signal
	wire 			RESET;			// RESET signal
	wire			LOAD;			// memory control signal
	wire			DONE;			// RESULT latched in memory signal
	wire [`BITS-1:0] 	RESULT;			// result in lelory for display
	
	wire [15:0]		display;		// lower 16 bits of result displayed  
	assign	dig3 = {1'b0,display[15:12]};
	assign	dig2 = {1'b0,display[11:8]};
	assign 	dig1 = {1'b0,display[7:4]};
	assign	dig0 = {1'b0,display[3:0]};
	assign	decpts = {4'b00,GO,DONE};		// display state as decimal points
	
/******************************************************************/
/* CHANGE THIS SECTION FOR YOUR PROJECT 3                            */
/******************************************************************/		


wire clk0_buf, clkfb_in;

BUFG CLK0_BUFG_INST (.I(clk0_buf), .O(clkfb_in));

// assign clk = clkfb_in;

  DCM_SP #(
      .CLKDV_DIVIDE(),                   // CLKDV divide value
                                            // (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      .CLKFX_DIVIDE(4),                     // Divide value on CLKFX outputs - D - (1-32)
      .CLKFX_MULTIPLY(7),                   // Multiply value on CLKFX outputs - M - (2-32)
      .CLKIN_DIVIDE_BY_2("FALSE"),          // CLKIN divide by two (TRUE/FALSE)
      .CLKIN_PERIOD(10.0),                  // Input clock period specified in nS
      .CLKOUT_PHASE_SHIFT("NONE"),          // Output phase shift (NONE, FIXED, VARIABLE)
      .CLK_FEEDBACK("1X"),                  // Feedback source (NONE, 1X, 2X)
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      .DLL_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .PHASE_SHIFT(0),                      // Amount of fixed phase shift (-255 to 255)
      .STARTUP_WAIT("FALSE")                // Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   DCM (
      .CLK0(clk0_buf),         // 1-bit output: 0 degree clock output
      .CLK180(),     // 1-bit output: 180 degree clock output
      .CLK270(),     // 1-bit output: 270 degree clock output
      .CLK2X(),       // 1-bit output: 2X clock frequency clock output
      .CLK2X180(), // 1-bit output: 2X clock frequency, 180 degree clock output
      .CLK90(),       // 1-bit output: 90 degree clock output
      .CLKDV(),       // 1-bit output: Divided clock output
      .CLKFX(sysclk),       // 1-bit output: Digital Frequency Synthesizer output (DFS)
      .CLKFX180(), // 1-bit output: 180 degree CLKFX output
      .LOCKED(),     // 1-bit output: DCM_SP Lock Output
      .PSDONE(),     // 1-bit output: Phase shift done output
      .STATUS(),     // 8-bit output: DCM_SP status output
      .CLKFB(clkfb_in),       // 1-bit input: Clock feedback input
      .CLKIN(clk100),       // 1-bit input: Clock input
      .DSSEN(1'b0),       // 1-bit input: Unsupported, specify to GND.
      .PSCLK(1'b0),       // 1-bit input: Phase shift clock input
      .PSEN(1'b0),         // 1-bit input: Phase shift enable
      .PSINCDEC(1'b0), // 1-bit input: Phase shift increment/decrement input
      .RST(1'b0)            // 1-bit input: Active high reset input
   );




	wire [31:0] digits_out;		// ASCII digits (Only for Simulation)
	
	// global assigns
	// assign	sysclk = clk100;
	assign 	sysreset = db_btns[0];
	// assign	JA = {sysclk, sysreset, 2'b0};
	
	
	//  pico blaze can intercept the inputs to the stim module, or it can replace the stim module
	 STIMULOUS stim(sysclk,db_btns,db_sw,GO,RESET,LOAD,M,E,N,RESULT,DONE,display,led);
	 
	 MEMORY mem(sysclk,RESET,LOAD,M,E,N,m,e,n,r,d,RESULT,DONE);
	  
	 //RSA encr(sysclk,GO,m,e,n,r,d);
	 MontgomeryExponential encr(
	.X(m),
	.E(e),
	.M(n),
	.clk(sysclk),
	.go(GO),	
	.done(d),
	.Z(r)
	);

/******************************************************************/
/* THIS SECTION SHOULDN'T HAVE TO CHANGE FOR PROJECT 3               */
/******************************************************************/			
	
	// instantiate the debounce module
	
	debounce 	DB (
		.clk(sysclk),	
		.pbtn_in({btnl,btnu,btnr,btnd,btns}),
		.switch_in(sw),
		.pbtn_db(db_btns),
		.swtch_db(db_sw)
	);	
	
		
// instantiate the 7-segment, 4-digit display
	SevenSegment SSB (
		// inputs for control signals
		.d0(dig0),
		.d1(dig1),
 		.d2(dig2),
		.d3(dig3),
		.dp(decpts),
		// outputs to seven segment display
		.seg(seg),			
		.an(an),				
		// clock and reset signals (100 MHz clock, active high reset)
		.clk(sysclk),	
		.reset(sysreset)
		// ouput for simulation only
		//.digits_out(digits_out)
	);
	
endmodule
	