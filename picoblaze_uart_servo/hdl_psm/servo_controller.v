`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Servo controller unit, currently support both continuous (full) rotation
// servo and normal (0-180 degree) servo.
// 
// Copyright by Dung Le
// 
// Create Date:    00:49:25 10/22/2012 
// Design Name: 
// Module Name:    servo_controller 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
// - Servo control register definition:
//   + bit [5-0]: speed, 64 steps
//   + bit 6: direction bit
//   + bit 7: servo select bit
// - The output pulse width from servo_controller unit are 0.5 - 2.5 ms for normal 
//   servo, 1 - 2 ms for full rotation servo. PWM period is 16ms (fpga board run at 10MHZ)
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module servo_controller(
	////////////////////////////////////////////////////////////////////////////
	// -- INPUT
	////////////////////////////////////////////////////////////////////////////
	input wire      direction,
	input [5:0] speed_angle,      // pwm control, 6-bit resolution
	input wire      servo_select,	       // servo select, 2 servos supported
	input       clk,
	////////////////////////////////////////////////////////////////////////////
	// -- OUTPUT
	////////////////////////////////////////////////////////////////////////////	
	output reg FullRot_RCServo_pulse,            // 2 PWM outputs		
	output reg Normal_RCServo_pulse,
	output [7:0]  debug_led
   );
	
	assign debug_led = {servo_select, direction, speed_angle};
	// Normal servos operation:
	// - The PWM control pulse length needs to be anywhere from 1ms to 2ms.
	//   A pulse of 1.5ms rotates the axis in the middle of its rotation range.
	// - A new pulse needs to be sent regularly (every 10 to 20ms), even if the 
	//   angular position doesn't need to be changed, or the servo will stop 
	//   trying to hold it.
	// Full rotation servos operation:
	// - 
	//	
	// To support all servos we define PWM width setup as:
	// pwm_width == 0      :   no PWM (relax)
	// pwm_width == 1 - 30 :   30 steps of 0.1ms
	// pwm_width == 31     :   long PWM width (hold)
	// 
	reg [6:0] speed = 0;	// 127 max 
	reg [7:0] angle = 0;	// 255 max
	//reg direction;
	//reg servo_select;	       // servo select, 2 servos supported

 
	// divide the clock
	// parameter ClkDiv = 391;  // 100000000/1000/256 = 390.6
	// pulse from 1ms (0) to 2ms (255), with a resolution of 1ms/256=3.9us.
	// generate a "tick" of period as close as possible to 3.9us.
	parameter   simulate = 0;

	parameter ClkDiv = simulate ? 3            // simulating clock
	                            : 391;
	reg [9:0] ClkCount = 0;
	reg ClkTick = 0;
	
	always @(posedge clk) 
		ClkTick <= (ClkCount==ClkDiv-2);
	always @(posedge clk) 
		if(ClkTick) 
			ClkCount <= 0; 
		else 
			ClkCount <= ClkCount + 1;

	////////////////////////////////////////////////////////////////////////////
	// 12-bits counter that increments at every "3.9us" tick,rolls-over every 16ms
	reg [11:0] PulseCount = 0;
	always @(posedge clk) 
		if(ClkTick) 
			PulseCount <= PulseCount + 1;

	// make sure the RCServo_position is stable while the pulse is generated
	reg [9:0] RCServo_angle = 10'd384; // center = 384, range 128 - 639
	reg [9:0] RCServo_speed = 10'd384; // stop = 384, range 256 - 511
	always @(posedge clk) begin
		speed <= {speed_angle, 1'b0};
		angle <= {speed_angle, 2'b0};
	end

	always @(posedge clk) 
		if(PulseCount == 0) begin
			if (servo_select == 1'b0) begin // full rotation servo
				if (direction == 1'b0)       // right turn
					RCServo_speed <= 10'd384 - speed;
				else
					RCServo_speed <= 10'd384 + speed;
			end
			else begin                      // normal servo
				if (direction == 1'b0)       // 
					RCServo_angle <= 10'd384 - angle;
				else
					RCServo_angle <= 10'd384 + angle;
			end
		end
			
		
	// We start each pulse when "PulseCount" equals 0.
	// We end each pulse when "PulseCount" is somewhere between 256 and 511. 
	// That generates the pulse between 1ms and 2ms.
	// "RCServo_position" is the 8 bits position value (from 0 to 255), we concatenate
	// a "0001" in front of it to create a 12 bits value ranging from 256 ot 511
	//reg FullRot_RCServo_pulse = 0;  
	//reg Normal_RCServo_pulse = 0 ;

	always @(posedge clk) begin
		FullRot_RCServo_pulse <= (PulseCount < RCServo_speed);
		Normal_RCServo_pulse <= (PulseCount < RCServo_angle);
	end

endmodule
