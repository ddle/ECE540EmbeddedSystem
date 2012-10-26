::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Asembler and Loader script for our .psm program, using
:: JTag Loader Tool
:: Copyright by Dung Le
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: NOTE: set below with name of your .psm program
@ ECHO OFF
SET NAME=uart_servo_control
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:loop
@ ECHO ON
:: assembling...
kcpsm6.exe %NAME%

:: ask whether we should proceed
::@ ECHO OFF
::set /p DECISION= proceed wih Jtag Loader? (y/n)
:: Jtag loader
::IF %DECISION%==y 
JTAG_Loader_Win7_32.exe -l %NAME%.hex 

:: Done
@ ECHO OFF
ECHO.
ECHO ...done!
set /p DECISION= redo? (y/n)
:: Repeat until done
IF %DECISION%==y goto loop
