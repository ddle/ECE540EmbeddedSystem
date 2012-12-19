Portland State University, ECE 540 Embedded System
Final Project: FPGA-based Color Tracking Bot
Copyright by Dung Le and Eric Krause

Archive Contents:

    docs - All documentation for project
    
    hardware - all hdl code for hardware interface
        - top module: picoblaze_uart_servo_motor.v
        - motor/servo controllers : servo_controler.v, motor_controller.v
        - picoblaze core: kcpsm6.v
        - picoblaze program rom: main.v
        - uart: uart_rx6.v, uart_tx6.v
        - debounce.v
        - ucf file
        - etc
    
    firmware - all picoblaze code and firmware loader
        - loader.bat - compiles and loads code w/ JTAG
        - main psm files: main.psm
        - psm includes (interfaces/drivers): 
            + delay.psm
            + motor_interface_routines.psm
            + servo_interface_routines.psm
            + ports_scratchpads.psm
            + uart_interface_routines.psm
        - compiled picoblaze verilog instantiation code
  
    