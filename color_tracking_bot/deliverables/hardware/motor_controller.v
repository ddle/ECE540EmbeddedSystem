`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Motor controller unit for driving the famous L289N Dual H-bridge
// 
// Copyright by Dung Le
//  
// Create Date:    01:04:24 10/27/2012 
// Design Name: 
// Module Name:    motor_controller 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//   Driving mechanism is as follow
//   + direction: pin In1/In2 (motorA) 0/1 or 1/0; pin In3/In4 (motorB) 0/1 or 1/0
//   + speed: PWM on ENA or ENB pin
//   This module is parameterized for 
//   + max speed limit
//   + pulse frequency
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module motor_controller(
	//
	////////////////////////////////////////////////////////////////////////////
	// INPUT
	////////////////////////////////////////////////////////////////////////////
	//
	// from picoblaze
	input wire        direction,
	input       [4:0] speed,           // velocity control, 5-bit resolution
	input wire  [1:0] motor_select,	   // 4 motors supported
	input             clk,
	// from encoders
	input       [7:0] encoders,        // currently unsued
	// from system reset
	input             reset,
	//
	////////////////////////////////////////////////////////////////////////////
	// OUTPUT
	////////////////////////////////////////////////////////////////////////////	
	//
	output reg [3:0] motor_pulse = 0,            // PWM outputs, registered		
	output reg [7:0] motor_direction = 0,        // direction outputs, registered		
	output     [7:0] debug_led
   );
	//
	////////////////////////////////////////////////////////////////////////////
	// DESIGN PARAMETERS
	////////////////////////////////////////////////////////////////////////////
	//
	// divide the clock to get 2.5us tick at 100MHz
	parameter ClkDiv = 250;
	// make sure we dont overload our motors. 100% duty cycle is at step 31
	parameter max_speed = 28;
	// period length = 2^(period_count+1) x tick resolution
	parameter period_count = 4;
	//
	////////////////////////////////////////////////////////////////////////////
	// SIGNALS
	//////////////////////////////////////////////////////////////////////////// 
	//
	// array of 4 motor speed regs, with 5-bit resolution each
	reg [4:0] motor_speed_regs [0:3];	
	reg [3:0] motor_direction_regs;
	// resolution TICKS WITH PERIOD 1ms/40 = 25us 
	reg ClkTick = 0;
	// 5-bit counter that increments at every 2.5us tick, rolls-over every 80us
	// => PWM period = 80us => f = 12.5kHz
	reg [period_count:0] PulseCount = 0;
	// counter for resolution tick
	reg [11:0] ClkCount = 0;
	//
	
	//
	////////////////////////////////////////////////////////////////////////////
	// CONTINUOUS SIGNAL ASSIGNMENTS
	//////////////////////////////////////////////////////////////////////////// 
	//
	assign debug_led[7:0] = {motor_select,direction,speed};	
	//
	////////////////////////////////////////////////////////////////////////////
	// GENERATE resolution tick
	//////////////////////////////////////////////////////////////////////////// 
	//
	always @(posedge clk)
		if(reset) 
			ClkTick <= 0;
		else
			ClkTick <= (ClkCount == ClkDiv);
	
	always @(posedge clk) begin
		if(reset)
			ClkCount <= 0;
		else if (ClkTick) 
			ClkCount <= 0; 
		else 
			ClkCount <= ClkCount + 1;
	end
	//
	////////////////////////////////////////////////////////////////////////////
	// GENERATE PWM 
	//////////////////////////////////////////////////////////////////////////// 
	//	
	//
	always @(posedge clk) begin
		if(ClkTick) begin
			PulseCount <= PulseCount + 1;
		end	
	end
	//
	// recalculate motor speed, pulse width is PulseCount x speed
	//
	reg [4:0] reg_speed;
	always @(posedge clk)
		if (reset)
			reg_speed <= 0;
		else if (speed > max_speed)
			reg_speed <= max_speed;
		else
			reg_speed <= speed;
	//
	always @(posedge clk) begin
		if (reset) begin
			motor_speed_regs[0] <= 0;	
			motor_speed_regs[1] <= 0;	
			motor_speed_regs[2] <= 0;	
			motor_speed_regs[3] <= 0;	
			motor_direction_regs <= 0;
		end
		else begin
			motor_speed_regs[motor_select] <= reg_speed;	
			motor_direction_regs[motor_select] <= direction;
		end
	end
	//
	// drive PMW outputs
	//
	always @(posedge clk) begin
		motor_pulse[0] <= (PulseCount < motor_speed_regs[0]);
		motor_pulse[1] <= (PulseCount < motor_speed_regs[1]);
		motor_pulse[2] <= (PulseCount < motor_speed_regs[2]);
		motor_pulse[3] <= (PulseCount < motor_speed_regs[3]);
		motor_direction[1:0] <= motor_direction_regs[0] ? (2'b01) : (2'b10);
		motor_direction[3:2] <= motor_direction_regs[1] ? (2'b01) : (2'b10);
		motor_direction[5:4] <= motor_direction_regs[2] ? (2'b01) : (2'b10);
		motor_direction[7:6] <= motor_direction_regs[3] ? (2'b01) : (2'b10);
	end
	//
	////////////////////////////////////////////////////////////////////////////

endmodule

