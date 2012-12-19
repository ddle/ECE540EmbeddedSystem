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
module nexys3fpga(
	//
	////////////////////////////////////////////////////////////////////////////
	// INPUT
	////////////////////////////////////////////////////////////////////////////
	//
	input        clk100,
	input        btnl,
	input        btnu,
	input        btnr,
	input        btnd,
	input        btns,
	input  [7:0] sw,
	input        uart_rx,
	output       uart_tx,
	//
	////////////////////////////////////////////////////////////////////////////
	// OUTPUT
	////////////////////////////////////////////////////////////////////////////	
	//
	// output [3:0] JA,
	output [7:0] seg,
	output [3:0] an,
	output [7:0] led,
	//
	// VGA
	//
	output [2:0] vgaRed,
	output [2:0] vgaGreen,
	output [2:1] vgaBlue,
	output       Hsync,
	output       Vsync
	);

	//
	////////////////////////////////////////////////////////////////////////////
	// Signals
	////////////////////////////////////////////////////////////////////////////
	//
	// Signals used to connect KCPSM6
	//
	wire [11:0] address;
	wire [17:0]	instruction;
	wire        bram_enable;
	wire [7:0]  in_port;
	wire [7:0]  out_port;
	wire [7:0]  port_id;
	wire        write_strobe;
	wire        k_write_strobe;
	wire        read_strobe;
	wire        interrupt;   
	wire        interrupt_ack;
	wire        kcpsm6_sleep;  
	wire        kcpsm6_reset;
	wire        rdl;
	//
	// Signals used to connect between botsim and bot interface
	//
	wire  [7:0] motctl;                       // motor control
	wire  [7:0] locX;
	wire  [7:0] locY;
	wire  [7:0] botinfo;
	wire  [7:0] sensors;
	wire        upd_sysregs;
	//
	// other internal variables
	//
	wire			sys_reset;                    // system reset signal
	wire [7:0]  db_sw;                        // debounced switches
	wire [4:0]  db_btns;	                     // debounced buttons
	wire [4:0]	dig3, dig2,	dig1, dig0;	      // display digits
	wire [3:0]	decpts;                       // decimal points	
	wire [31:0] digits_out;				// ASCII digits (Only for Simulation)
	wire clkfb_in, clk0_buf, clk;
	//
	// VGA signals
	//
	wire [9:0]  vid_row;
	wire [9:0]  vid_col;
	wire        video_on;
	wire [1:0]  vid_pixel_out;
	wire [7:0]  icon_pixel_out;
	//
	//
	////////////////////////////////////////////////////////////////////////////
	// Continuous Signal Assignments
	////////////////////////////////////////////////////////////////////////////
	//
	// Reset connected to JTAG Loader enabled Program Memory
	//
	assign sys_reset = db_btns[0];
	assign kcpsm6_reset = rdl | sys_reset;
	//assign JA = {clk, sys_reset, 2'b0};	
	//
	// Unused signals tied off until required.
	//
	assign kcpsm6_sleep = 1'b0;
	//assign decpts = 4'b0000;         // all decimal points off
	
	
	// generate 5-bit speed signal used to set motion threshold of BotSim
	reg [4:0] speed;
	
	always @*
		case	(db_sw[7:2])
			5'd0, 5'd1, 5'd2, 5'd3: speed = 5'd4;
			default: speed = db_sw[7:2];
		endcase
	//
	////////////////////////////////////////////////////////////////////////////
	// Instantiate KCPSM6 and connect to program ROM
	////////////////////////////////////////////////////////////////////////////
	//
	// In this case the 'hwbuild' value is used to define a version using the 
	// ASCII code for the desired letter. 
	//
	kcpsm6 #(
	.interrupt_vector	(12'h3FF),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h00))           
	processor (
	.address 		(address),
	.instruction 	(instruction),
	.bram_enable 	(bram_enable),
	.port_id 		(port_id),
	.write_strobe 	(write_strobe),
	.k_write_strobe 	(k_write_strobe),
	.out_port 		(out_port),
	.read_strobe 	(read_strobe),
	.in_port 		(in_port),
	.interrupt 		(interrupt),
	.interrupt_ack 	(interrupt_ack),
	.reset 		(kcpsm6_reset),
	.sleep		(kcpsm6_sleep),
	.clk 			(clk)); 
	//
	// Development Program Memory, JTAG Loader enabled 
	//
	bot_control #(
	.C_FAMILY		   ("S6"),  
	.C_RAM_SIZE_KWORDS	(2),  
	.C_JTAG_LOADER_ENABLE	(1))
	program_rom (
	.rdl 			(rdl),
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(clk));
	//
	////////////////////////////////////////////////////////////////////////////
	// Instantiate Seven segment unit
	////////////////////////////////////////////////////////////////////////////
	//
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
	.clk(clk),
	.reset(kcpsm6_reset),
	// ouput for simulation only
	.digits_out(digits_out)
	);
	//
	////////////////////////////////////////////////////////////////////////////
	// Instantiate Debounce unit
	////////////////////////////////////////////////////////////////////////////
	//
	debounce DB (
	.clk(clk),	
	.pbtn_in({btnl,btnu,btnr,btnd,btns}),
	.switch_in(sw),
	.pbtn_db(db_btns),
	.swtch_db(db_sw)
	);
	//
	////////////////////////////////////////////////////////////////////////////
	// Instantiate nexys3_bot_if interface unit
	////////////////////////////////////////////////////////////////////////////
	//
	nexys3_bot_if BOT_IF (
	//
	// picoblaze connections
	//
	.port_id(port_id),
	.out_port(out_port),
	.k_write_strobe(k_write_strobe),
	.write_strobe(write_strobe),
	.read_strobe(read_strobe),
	.interrupt_ack(interrupt_ack),	
	.interrupt(interrupt),
	.in_port(in_port),
	.uart_rx(uart_rx),
	.uart_tx(uart_tx),	
	//	
	// BotSim connections
	//
	.locX(locX),
	.locY(locY),
	.botinfo(botinfo),
	.sensors(sensors),
	.upd_sysregs(upd_sysregs),
	.motctl(motctl),
	//
	// peripheral connections
	//
	.db_btns(db_btns[4:1]),
	.db_sw(db_sw),
	.dig0(dig0),
	.dig1(dig1),
	.dig2(dig2),
	.dig3(dig3),
	.dp(decpts),
	.LEDS(led),
	.clk(clk)
	);
	//
	////////////////////////////////////////////////////////////////////////////
	// Instantiate BotSim module 
	////////////////////////////////////////////////////////////////////////////
	//
	
	bot BotSim (
	// system interface registers
	.MotCtl_in(motctl),
	.LocX_reg(locX),
	.LocY_reg(locY),
	.Sensors_reg(sensors),
	.BotInfo_reg(botinfo),
	.Bot_Config_reg({2'b00, 
							speed,
					1'b1}),
	
	//.LMDist_reg,
	//.RMDist_reg,
	//	
	// interface to the video logic
	//
	.vid_row(vid_row),
	.vid_col(vid_col),
	.vid_pixel_out(vid_pixel_out),
	//
	// interface to the system
	//
	.clk(clk),
	.reset(kcpsm6_reset),
	.upd_sysregs(upd_sysregs)
	);
	//
	////////////////////////////////////////////////////////////////////////////
	// instantiate a DCM_SP and clock feedback buffer. 
	////////////////////////////////////////////////////////////////////////////
	//
	// The DCM is configured to generate a divide-by-four clock output.
	//
   
	assign clk = clkfb_in;
	// DCM clock feedback buffer
	BUFG CLK0_BUFG_INST (.I(clk0_buf), .O(clkfb_in));

	// DCM_SP: Digital Clock Manager Circuit
	// Spartan-3E/3A, Spartan-6
	// Xilinx HDL Libraries Guide, version 11.2

	DCM_SP #(
	.CLKDV_DIVIDE(4.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
	// 7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
	.CLKFX_DIVIDE(1), // Can be any integer from 1 to 32
	.CLKFX_MULTIPLY(4), // Can be any integer from 2 to 32
	.CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
	.CLKIN_PERIOD(10.0), // Specify period of input clock
	.CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE, FIXED or VARIABLE
	.CLK_FEEDBACK("1X"), // Specify clock feedback of NONE, 1X or 2X
	.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
	// an integer from 0 to 15
	.DLL_FREQUENCY_MODE("LOW"), // HIGH or LOW frequency mode for DLL
	.DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
	.PHASE_SHIFT(0), // Amount of fixed phase shift from -255 to 255
	.STARTUP_WAIT("FALSE") // Delay configuration DONE until DCM LOCK, TRUE/FALSE
	) DCM_SP_inst (
	.CLK0(clk0_buf), // 0 degree DCM CLK output
	.CLK180(), // 180 degree DCM CLK output
	.CLK270(), // 270 degree DCM CLK output
	.CLK2X(), // 2X DCM CLK output
	.CLK2X180(), // 2X, 180 degree DCM CLK out
	.CLK90(), // 90 degree DCM CLK output
	.CLKDV(clk25), // Divided DCM CLK out (CLKDV_DIVIDE)
	.CLKFX(), // DCM CLK synthesis out (M/D)
	.CLKFX180(), // 180 degree CLK synthesis out
	.LOCKED(), // DCM LOCK status output
	.PSDONE(), // Dynamic phase adjust done output
	.STATUS(), // 8-bit DCM status bits output
	.CLKFB(clkfb_in), // DCM clock feedback
	.CLKIN(clk100), // Clock input (from IBUFG, BUFG or DCM)
	.PSCLK(1'b0), // Dynamic phase adjust clock input
	.PSEN(1'b0), // Dynamic phase adjust enable input
	.PSINCDEC(1'b0), // Dynamic phase adjust increment/decrement
	.RST(1'b0) // DCM asynchronous reset input
	);
	// End of DCM_SP_inst instantiation
	//
	////////////////////////////////////////////////////////////////////////////
	// instantiate display timing generator
	////////////////////////////////////////////////////////////////////////////
	//
	dtg dtg1(
	.clock(clk25), 
	.rst(kcpsm6_reset),
	.horiz_sync(Hsync),
	.vert_sync(Vsync), 
	.video_on(video_on),		
	.pixel_row(vid_row), 
	.pixel_column(vid_col)
	);
	//
	////////////////////////////////////////////////////////////////////////////
	// instantiate icon module
	////////////////////////////////////////////////////////////////////////////
	//
	Icon icn(
	//	
	.clk(clk), 
	.LocX(locX),	
	.LocY(locY),
	.BotInfo(botinfo),
	.pixel_row(vid_row), 
	.pixel_col(vid_col),
	//
	.icon(icon_pixel_out)
	);
	//
	////////////////////////////////////////////////////////////////////////////
	// instantiate colorizer module
	////////////////////////////////////////////////////////////////////////////
	//
	colorizer clr(
   .clk(clk),
   .World(vid_pixel_out),
   .Icon(icon_pixel_out),
	.video_on(video_on),
   .Color({vgaRed,vgaGreen,vgaBlue})
    );
	
	////////////////////////////////////////////////////////////////////////////
endmodule
