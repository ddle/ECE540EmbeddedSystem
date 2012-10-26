///////////////////////////////////////////////////////////////////////////////////////////
//
// Picoblaze with uart, spi, servo controller
//
// Copyright by Dung Le, 2012
// KCPSM6 design reference by Ken Chapman - Xilinx Ltd.
//
// This reference design provides a simple UART communication example. 
// Please see 'UART6_User_Guide_30April12.pdf'  for more detailed descriptions.
// 
//////////////////////////////////////////////////////////////////////////////////////////-
//
//

module picoblaze_uart_servo_spi (  
	////////////////////////////////////////////////////////////////////////////
	// -- INPUT
	////////////////////////////////////////////////////////////////////////////
	input   uart_rx,
	input   clk100,
	input   spi_sdo,
		
	////////////////////////////////////////////////////////////////////////////
	// -- OUTPUT
	////////////////////////////////////////////////////////////////////////////	
	output           uart_tx,
	output reg       spi_cs,	
	output reg       spi_sdi,
	output reg       spi_clk,
	output reg [7:0] output_port_a,
	output           servo_0,
	output           servo_1,
	output wire [7:0] LED
	);

	//
	////////////////////////////////////////////////////////////////////////////
	// Signals
	////////////////////////////////////////////////////////////////////////////
	//
	// Signals used to create 50MHz clock from 200MHz differential clock
	//
	//wire          clk100;
	wire          clk;
	assign clk = clk100;
	//
	// Signals used to connect KCPSM6
	//
	wire [11:0] address;
	wire [17:0]	instruction;
	wire        bram_enable;
	reg  [7:0]  in_port;
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
	//wire			cpu_reset;
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
	reg [7:0]    servo_in_port;

	//
	////////////////////////////////////////////////////////////////////////////
	//
	// Start of circuit description
	//
	////////////////////////////////////////////////////////////////////////////
	//

	////////////////////////////////////////////////////////////////////////////
	// Create 50MHz clock from 100MHz differential clock
	////////////////////////////////////////////////////////////////////////////

	//  IBUFGDS diff_clk_buffer(
	//      .I(clk100_p),
	//      .IB(clk100_n),
	//      .O(clk100));

	  // BUFR used to divide by 2 and create a regional clock 

	//  BUFR #(
	//      .BUFR_DIVIDE("2"),
	//      .SIM_DEVICE("SPARTAN6"))
	//  clock_divide ( 
	//      .I(clk100),
	//      .O(clk),
	//      .CE(1'b1),
	//      .CLR(1'b0));

	////////////////////////////////////////////////////////////////////////////
	// Instantiate KCPSM6 and connect to program ROM
	////////////////////////////////////////////////////////////////////////////
	//
	// The generics can be defined as required. In this case the 'hwbuild' value is used to 
	// define a version using the ASCII code for the desired letter. 
	//

	kcpsm6 #(
	.interrupt_vector	(12'h3FF),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h00))            // 42 hex is ASCII Character "B"
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
	// Reset connected to JTAG Loader enabled Program Memory
	//
	assign kcpsm6_reset = rdl;

	//
	// Unused signals tied off until required.
	//
	assign kcpsm6_sleep = 1'b0;
	assign interrupt = interrupt_ack;

	//
	// Development Program Memory 
	// JTAG Loader enabled for rapid code development. 
	//
	uart_control #(
	.C_FAMILY		   ("S6"),  
	.C_RAM_SIZE_KWORDS	(1),  
	.C_JTAG_LOADER_ENABLE	(1))
	program_rom (
	.rdl 			(rdl),
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(clk));


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


	servo_controller sv(
		.direction(servo_in_port[6]),
		.speed_angle(servo_in_port[5:0]),
		.servo_select(servo_in_port[7]),
		.FullRot_RCServo_pulse(servo_0),
		.Normal_RCServo_pulse(servo_1),
		.debug_led(LED),
		.clk(clk));

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
	// General Purpose Input Ports. 
	////////////////////////////////////////////////////////////////////////////
	//
	// Two input ports are used with the UART macros. The first is used to monitor the flags
	// on both the transmitter and receiver. The second is used to read the data from the 
	// receiver and generate the 'buffer_read' pulse.
	//

	always @ (posedge clk)
	begin
		case (port_id[1:0]) 
		  // Read UART status at port address 00 hex
		  2'b00 : in_port <= { 2'b00,
									 uart_rx_full,
									 uart_rx_half_full,
									 uart_rx_data_present,
									 uart_tx_full, 
									 uart_tx_half_full,
									 uart_tx_data_present };
									 
		  // Read UART_RX6 data at port address 01 hex
		  // (see 'buffer_read' pulse generation below) 
		  2'b01 : in_port <= uart_rx_data_out; // this is from buffer, 8 bits
		  // Read UART_RX6 data at port address 02 hex, bit 7
		  2'b10 : in_port <= {spi_sdo, 7'b0000000};
		  default : in_port <= 8'bXXXXXXXX ;  
		endcase;
		//
		// Generate 'buffer_read' pulse following read from port address 01
		//
		if ((read_strobe == 1'b1) && (port_id[0] == 1'b1)) begin
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
	// In this simple example there is only one output port and that it involves writing 
	// directly to the FIFO buffer within 'uart_tx6'. As such the only requirements are to 
	// connect the 'out_port' to the transmitter macro and generate the write pulse.
	// 
	// adding the output registers 
	always @(posedge clk) begin
	 if(write_strobe == 1'b1) begin
		// SPI data output at address 02 hex
		if(port_id[1]  == 1'b1) begin
		  spi_sdi <= out_port[7];		 // we 'll do left shift, so use bit 7 
		end
		
		// SPI control (clk,chip select) output at address 04 hex
		if(port_id[2]  == 1'b1) begin
		  spi_cs    <= out_port[1];		  
		  spi_clk  <= out_port[0];		  
		end
		
		// general output PORT A at address 08 hex
		// bit 0 - 
		// bit 1 - 
		// bit 2 - 
		// bit 3 - 
		// bit 4 - 
		// bit 5 - 
		// bit 6 - 
		// bit 7 - 		
		if(port_id[3]  == 1'b1) begin
		  output_port_a <= out_port;		  
		end
		
		// servo controller register port
		if(port_id[4] == 1'b1) begin
			servo_in_port <= out_port;
		end
	 end
	end
	// it is a little bit strange : uart output is wired directly to outport
	assign uart_tx_data_in = out_port;
	assign write_to_uart_tx = write_strobe & port_id[0];

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
		if (port_id[0] == 1'b1) begin
			 uart_tx_reset <= out_port[0];
			 uart_rx_reset <= out_port[1];
		end
	 end
	end

	////////////////////////////////////////////////////////////////////////////
	endmodule
