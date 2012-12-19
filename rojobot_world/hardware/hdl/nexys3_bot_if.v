`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Portland State University, ECE 540 Embedded System
// Project 2: RoJobot world
// Copyright by Dung Le
//
// Create Date:    18:35:17 10/26/2012 
// Design Name: 
// Module Name:    nexys3_bot_if 
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

module nexys3_bot_if(
	////////////////////////////////////////////////////////////////////////////
	// picoblaze connections
	////////////////////////////////////////////////////////////////////////////
	//
	input  [7:0] port_id,
	input  [7:0] out_port,
	input        k_write_strobe,
	input        write_strobe,
	input        read_strobe,
	input        interrupt_ack,	
	output reg      interrupt,
	output reg [7:0] in_port,
	input        uart_rx,
	output       uart_tx,
	//
	////////////////////////////////////////////////////////////////////////////
	// BotSim connections
	////////////////////////////////////////////////////////////////////////////
	//
	input  [7:0] locX,
	input  [7:0] locY,
	input  [7:0] botinfo,
	input  [7:0] sensors,
	input        upd_sysregs,
	output reg [7:0] motctl,
	//
	////////////////////////////////////////////////////////////////////////////
	// peripheral connections
	////////////////////////////////////////////////////////////////////////////	
	//
	input        clk,
	input  [4:1] db_btns,
	input  [7:0] db_sw,
	output reg [4:0] dig0,
	output reg [4:0] dig1,
	output reg [4:0] dig2,
	output reg [4:0] dig3,
	output reg [3:0] dp,
	output reg [7:0] LEDS	
	);
	
	//
	////////////////////////////////////////////////////////////////////////////
	// Signals
	////////////////////////////////////////////////////////////////////////////
	//
	// Signals used to connect UART_TX6
	//
	wire [7:0]  uart_tx_data_in;
	wire        write_to_uart_tx;
	wire        uart_tx_data_present;
	wire        uart_tx_half_full;
	wire        uart_tx_full;
	reg         uart_tx_reset;
	//
	// Signals used to connect UART_RX6
	//
	wire [7:0]  uart_rx_data_out;
	reg         read_from_uart_rx;
	wire        uart_rx_data_present;
	wire        uart_rx_half_full;
	wire        uart_rx_full;
	reg         uart_rx_reset;
	//
	// Signals used to define baud rate
	//
	reg [5:0]   baud_count;
	reg         en_16_x_baud;
	//

//	reg       interrupt;
//	reg [7:0] in_port;	
//	reg [7:0] LEDS;	
//	reg [4:0] dig0;	
//	reg [4:0] dig1;	
//	reg [4:0] dig2;	
//	reg [4:0] dig3;
//	reg [3:0] dp;
//	reg [7:0] motctl;
	//
	////////////////////////////////////////////////////////////////////////////
	// UART Transmitter with integral 16 byte FIFO buffer
	////////////////////////////////////////////////////////////////////////////
	//
	// Write to buffer in UART Transmitter at port address 01 hex
	// 
	uart_tx6 tx(
		.data_in(uart_tx_data_in),
		.en_16_x_baud(en_16_x_baud),
		.serial_out(uart_tx),
		.buffer_write(write_to_uart_tx),
		.buffer_data_present(uart_tx_data_present),
		.buffer_half_full(uart_tx_half_full ),
		.buffer_full(uart_tx_full),
		.buffer_reset(uart_tx_reset),              
		.clk(clk));

	////////////////////////////////////////////////////////////////////////////
	// UART Receiver with integral 16 byte FIFO buffer
	////////////////////////////////////////////////////////////////////////////
	//
	// Read from buffer in UART Receiver at port address 01 hex.
	//
	// When KCPMS6 reads data from the receiver a pulse must be generated so that the 
	// FIFO buffer presents the next character to be read and updates the buffer flags.
	// 
	uart_rx6 rx(
		.serial_in(uart_rx),
		.en_16_x_baud(en_16_x_baud ),
		.data_out(uart_rx_data_out ),
		.buffer_read(read_from_uart_rx ),
		.buffer_data_present(uart_rx_data_present ),
		.buffer_half_full(uart_rx_half_full ),
		.buffer_full(uart_rx_full ),
		.buffer_reset(uart_rx_reset ),              
		.clk(clk ));
	//
	//
	////////////////////////////////////////////////////////////////////////////
	// RS232 (UART) baud rate 
	////////////////////////////////////////////////////////////////////////////
	//
	// To set serial communication baud rate to 115,200 then en_16_x_baud must pulse 
	// High at 1,843,200Hz which is every 27.13 cycles at 50MHz. In this implementation 
	// a pulse is generated every 27 cycles resulting is a baud rate of 115,741 baud which
	// is only 0.5% high and well within limits.
	//

	always @ (posedge clk )
	begin
	 if (baud_count == 6'd53) begin       // counts 54 states including zero
		baud_count <= 6'd0;
		en_16_x_baud <= 1'b1;                 // single cycle enable pulse
	 end
	 else begin
		baud_count <= baud_count + 6'd1;
		en_16_x_baud <= 1'b0;
	 end
	end
	//
	////////////////////////////////////////////////////////////////////////////
	// interrupt controller
	////////////////////////////////////////////////////////////////////////////
	//
	always @(posedge clk) begin
		if (interrupt_ack)
			interrupt <= 1'b0;
		else if (upd_sysregs)
			interrupt <= 1'b1;
		else
			interrupt <= interrupt;
	end
	//
	////////////////////////////////////////////////////////////////////////////
	// General Purpose Input Ports. 
	////////////////////////////////////////////////////////////////////////////
	//
	always @ (posedge clk)	begin
		case (port_id[3:0]) 
		  // Read 4 pushbuttons status at port address 00 hex
		  4'h00 : in_port <= { 4'b0000, db_btns };									 
		  // Read slide switches status at port address 01 hex
		  4'h01 : in_port <= db_sw; 
		  // Read X coordinate at port address 0A hex
		  4'h0A : in_port <= locX;
		  // Read Y coordinate at port address 0B hex
		  4'h0B : in_port <= locY;
		  // Read botinfo  at port address 0C hex
		  4'h0C: in_port <= botinfo;
		  // Read sensors at port address 0D hex
		  4'h0D : in_port <= sensors;
		  // uart status
		  4'h0E : in_port <= { 2'b00,
									 uart_rx_full,
									 uart_rx_half_full,
									 uart_rx_data_present,
									 uart_tx_full, 
									 uart_tx_half_full,
									 uart_tx_data_present };
									 
		  // Read UART_RX6 data at port address 0F hex
		  // (see 'buffer_read' pulse generation below) 
		  4'h0F : in_port <= uart_rx_data_out; // this is from buffer, 8 
		  default : in_port <= 8'bXXXXXXXX;  
		endcase;
		//
		// Generate 'buffer_read' pulse following read from port address 01
		//
		if ((read_strobe == 1'b1) && (port_id[3:0] == 4'h0F)) begin
		  read_from_uart_rx <= 1'b1;
		end
		else begin
		  read_from_uart_rx <= 1'b0;
		end
	end
	//
	////////////////////////////////////////////////////////////////////////////
	// General Purpose Output Ports 
	////////////////////////////////////////////////////////////////////////////
	//
	always @(posedge clk) begin
		if(write_strobe == 1'b1) begin	
			case (port_id[3:0]) 			
				// LEDs output at address 02 hex
				4'h02: LEDS <= out_port;
				
				// Digit 3 output at address 03 hex
				4'h03: dig3 <= out_port[4:0];
				
				// Digit 2 output at address 04 hex
				4'h04: dig2 <= out_port[4:0];
				
				// Digit 1 output at address 05 hex
				4'h05: dig1 <= out_port[4:0];
				
				// Digit 0 output at address 06 hex
				4'h06: dig0 <= out_port[4:0];
				
				// Digit dp output at address 07 hex
				4'h07: dp <= out_port[3:0];
				
				// Motor control output at address 09 hex
				4'h09: motctl <= out_port;

			 // default :    

			endcase
		end
	end
	//
	////////////////////////////////////////////////////////////////////////////
	// Constant-Optimised Output Ports 
	////////////////////////////////////////////////////////////////////////////
	//
	// One constant-optimised output port is used to facilitate resetting of the UART macros.
	//

	always @ (posedge clk)
	begin
	 if (k_write_strobe == 1'b1) begin
		if (port_id[3:0] == 4'b1111) begin
			 uart_tx_reset <= out_port[0];
			 uart_rx_reset <= out_port[1];
		end
	 end
	end
	
	assign uart_tx_data_in = out_port;
	assign write_to_uart_tx = write_strobe & port_id[0] & port_id[1] & port_id[2] & port_id[3];
	
endmodule
