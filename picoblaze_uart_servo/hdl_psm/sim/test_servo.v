`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:10:30 10/25/2012
// Design Name:   servo_controller
// Module Name:   C:/Users/cob/Documents/My Dropbox/541-SoC/project/project2/picoblazeExample/hdl_psm/sim/test_servo.v
// Project Name:  picoblazeExample
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: servo_controller
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_servo;

	// Inputs
	reg direction;
	reg [5:0] speed_angle;
	reg servo_select;
	reg clk;

	// Outputs
	wire FullRot_RCServo_pulse;
	wire Normal_RCServo_pulse;
	
	defparam    uut.simulate = 0;
	
	// Instantiate the Unit Under Test (UUT)
	servo_controller uut (
		.direction(direction), 
		.speed_angle(speed_angle), 
		.servo_select(servo_select), 
		.clk(clk), 
		.FullRot_RCServo_pulse(FullRot_RCServo_pulse), 
		.Normal_RCServo_pulse(Normal_RCServo_pulse)
	);

    always #5 clk = ~clk;


	initial begin
		// Initialize Inputs
		direction = 0;
		speed_angle = 0;
		servo_select = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
      direction = 1;
		speed_angle = 63;
		servo_select = 0;
		 

		#20000000;
      direction = 1;
		speed_angle = 63;
		servo_select = 1;		 
		// Add stimulus here
		#1000000000 $stop;
	end
      
endmodule

