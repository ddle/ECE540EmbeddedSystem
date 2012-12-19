`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Portland State University, ECE 540 Embedded System
// Project 2: RoJobot world
// Copyright by Dung Le & Eric Krause
// 
// Create Date:    18:46:52 10/26/2012 
// Design Name: 
// Module Name:    nexys3fpga 
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
module colorizer(
    input clk,
    input [1:0] World,
    input [7:0] Icon,
	input video_on,
    output reg [7:0] Color
    );
	
	parameter BLACK = 8'b00000000;
	parameter WHITE	= 8'b11111111;
	parameter GREY	= 8'b11011011;
	parameter RED	= 8'b11100000;
	parameter GREEN	= 8'b00011100;
	
	always @(posedge clk)
	begin
		if (video_on == 0)		// if video off, output black
			Color <= BLACK;
		
		else if (|Icon)			// if icon is any color but black, pass through
			Color <= Icon;
			
		else
			case (World)		// else, mux 2-bit World to determine 8-bit color
				2'b00	:	Color <= WHITE;	// background color
				2'b01	:	Color <= BLACK; // black line
				2'b10	:	Color <= RED;	// obstruction
				2'b11	:	Color <= GREY;	
			endcase
	end
endmodule
