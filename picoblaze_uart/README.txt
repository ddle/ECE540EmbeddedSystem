Picoblaze and Uart example, Dung Le 2012
-------------------------------------------------------------------------------
Hardware : Nexys 3 FPGA board, serial port at jumper JD1 and JD7
How to:
- synthesize it 
- configure the device with the bit file generated
- run the batch file loader.bat to assembling and upload psm code to picoblaze.
  Uploading code is done via Jtag Loader
- now we should be able to type into a serial terminal and observe the feedback
-------------------------------------------------------------------------------
Note : JTAG LOADER for PicoBlaze
    * set up
        * copy JTAG_Loader...exe to the working dir
        * copy the assembler kcpsm6.ece to the working dir
        * add environment vars:
            * PATH variable 
                * F:\Xilinx\14.2\ISE_DS\common\lib\nt;
                * F:\Xilinx\14.2\ISE_DS\ISE\bin\nt; 
                * F:\Xilinx\14.2\ISE_DS\ISE\lib\nt
            * add new XILINX variable: 
                * F:\Xilinx\14.2\ISE_DS\ISE
    With this set up, to assembling and upload psm code to picoblaze
    we only need to:
        * modify the psm
        * run the batch file loader.bat to 


