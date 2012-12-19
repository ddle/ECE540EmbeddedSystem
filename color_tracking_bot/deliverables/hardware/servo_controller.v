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
//   servo, 1 - 2 ms for full rotation servo. PWM period is 16ms (fpga board run at 100MHZ)
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
	input             reset,
	////////////////////////////////////////////////////////////////////////////
	// -- OUTPUT
	////////////////////////////////////////////////////////////////////////////	
	output reg FullRot_RCServo_pulse,            // 2 PWM outputs		
	output reg Normal_RCServo_pulse,
	output [7:0]  debug_led
   );
	
	assign debug_led = {servo_select, direction, speed_angle};
	// servos operation:
	// - The PWM control pulse length needs to be anywhere from 0.5ms to 2.5ms 
	// ( 1ms-2ms for full rotational servo )
	// - for normal servo, a new pulse needs to be sent regularly, even if the 
	//   angular position doesn't need to be changed, or the servo will stop 
	//   trying to hold it.
	// 
	reg [6:0] speed = 0;	// 127 max 
	reg [7:0] angle = 0;	// 255 max

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
	
	// remapping the specified speed (0-63) to generate pulse width in the required range
	reg [9:0] RCServo_angle = 10'd384; // 0-180 rotational servo, center = 384, range 128 - 639
	reg [9:0] RCServo_speed = 10'd384; // full rotational servo, center = 384, range 256 - 511
	always @(posedge clk) begin
		if (reset) begin
			speed <= 0;
			angle <= 0;
		end
		begin 
			if (servo_select == 1'b0)
				speed <= {speed_angle, 1'b0};
			else	
				angle <= {speed_angle, 2'b0};
		end
	end
	
	always @(posedge clk) 
		if(PulseCount == 0) begin
			if (servo_select == 1'b0) begin // full rotation servo
				if (direction == 1'b0)       // right turn
					RCServo_speed <= 10'd384 - {3'b000, speed};
				else
					RCServo_speed <= 10'd384 + {3'b000, speed};
			end
			else begin                      // normal servo
				if (direction == 1'b0)       // 
					RCServo_angle <= 10'd384 - {2'b00, angle};
				else
					RCServo_angle <= 10'd384 + {2'b00, angle};
			end
		end
	//		
	// For Full- rotational servo:
	// We start each pulse when "PulseCount" equals 0.
	// We end each pulse when "PulseCount" is somewhere between 256 and 511. 
	// That generates the pulse between 1ms and 2ms.
	// 
	// Normal servo is done in similar term
	//
	always @(posedge clk) begin
		FullRot_RCServo_pulse <= (PulseCount < {2'b00, RCServo_speed} );
		Normal_RCServo_pulse <= (PulseCount < {2'b00, RCServo_angle} );
	end

endmodule
