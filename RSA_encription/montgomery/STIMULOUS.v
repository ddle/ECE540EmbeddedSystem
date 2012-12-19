//STIMULOUS.v - state machine that interfaces the hw in project 3
//
// Created By:	Jesse Inkpen
// Date:	11-November-2012
//
///////////////////////////////////////////////////////////////////////////

`define BITS 64

module STIMULOUS(
	input 				CLK,		// clock
	input [4:0]			PB,		// push buttons
	input [7:0]			SW,		// swithches
	
	output  reg			GO,		// generated GO signal
	output  reg 			RESET,		// system reset generate
	output  reg			LOAD,		// memory control signal - load data
	output  reg [`BITS-1:0]	M,			// message
	output  reg [`BITS-1:0]	E,			// exponent
//	output  reg [`BITS-1:0]	N  = `BITS'd1189,	// 16 bit modulous
//	output  reg [`BITS-1:0]	N  = `BITS'd1073602561,	// 32 bit modulous 
	output  reg [`BITS-1:0]	N  = `BITS'd288230439905132863 ,	// 64 bit modulous 
//	output  reg [`BITS-1:0]	N  = `BITS'd20769187434139322034329832130609147 ,	// 128 bit modulous 
	input	[`BITS-1:0]		RESULT,		// result from memory
	input				DONE,		// RESULT clock into memory
	
	output reg [15:0]  		display,	// information to be displayed
	output reg [7:0]   		led		// LED light to illuminate
	);

	reg			STOP;

// depending on how things go, I will add real 16 bit, 32 bit, and 64 bit numbers here
	always @(*) 			// mux the message 
		case (SW) // switch pos	 	message	   	led code	// Hex
			8'b00000010: begin M = `BITS'd190; 	led = 2; end	// BE
			8'b00000100: begin M = `BITS'd514; 	led = 4; end	// 202
			8'b00001000: begin M = `BITS'd40;  	led = 8; end	// 28
			8'b00010000: begin M = `BITS'd21349; 	led = 16; end	// 5365		32 bit
			8'b00100000: begin M = `BITS'd28260; 	led = 32; end	// 6e64		32 bit
			8'b01000000: begin M = `BITS'd21349; 	led = 64; end	// 5365		64 bit
			8'b10000000: begin M = `BITS'd28260; 	led = 128; end	// 6e64		64 bit
			
			8'b00000011: begin M = `BITS'd848;  	led = 3; end	// 350
			8'b00000101: begin M = `BITS'd1054; 	led = 5; end 	// 41E
			8'b00001001: begin M = `BITS'd983;  	led = 9; end	// 3D7
			8'b00010001: begin M = `BITS'd868359270; led = 17; end	// 1C66  	32 bit
			8'b00100001: begin M = `BITS'd680289476;  led = 33; end // 64C4		32 bit
			8'b01000001: begin M = `BITS'd225812834077651631 ;  led = 65; end    // 64 bit
			8'b10000001: begin M = `BITS'd196459766959145158;  led = 129; end    // 64 bit			
			
			default: begin M = `BITS'hffffffff; led = 0; end
		endcase
			// 16 bit expooents 3, 187
			// 32 bit exponents 11, 390350291
			// 64 bit exponents 5, 172938262574058869
			// # 128bit key.
			// #public ( 17, 20769187434139322034329832130609147 )
			// #private ( 18325753618358223281893785584271353, 20769187434139322034329832130609147 )
	always @(*)  // mux the exponent.  no need to worry about N now
		case (SW[0:0])
			1'b0: E = `BITS'd5;
			1'b1: E = `BITS'd172938262574058869;
			//1'b0: E = `BITS'd17;
			//1'b1: E = `BITS'd18325753618358223281893785584271353;
			
			//1'b0: E = `BITS'd3;
			//1'b1: E = `BITS'd187;
			//1'b0: E = `BITS'd11;
			//1'b1: E = `BITS'd390350291;
			default: E = `BITS'hffffffff;
		endcase

		// here is a pretty sloppy state machine to display results...
		
	always @(posedge CLK)
		if (RESET||STOP) begin GO <= 0; RESET <= 0; STOP <= 0; display <= 0; end
		else case (PB)
			5'b00001: 	begin RESET <= 1; display <= 1; end
			5'b00010: 	begin LOAD <= 1; display <= 2; end
			5'b00100: 	begin if (!DONE) GO <= 1; display <= 3; end
			5'b01000: 	begin STOP <= 1; display <= 4; end
//			5'b10000;	begin if (DONE) GO <= 0; display <= 5; end
			default: 	begin
					if (LOAD) begin LOAD <= 0; display <= M; end
					else if (DONE) begin GO <= 0; display <= RESULT; end
					else if (GO) display <= M;
					else display <= display;
					end
		endcase
					
endmodule
	
		
		
	
	
