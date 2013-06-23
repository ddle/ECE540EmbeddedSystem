Portland State University, ECE 540 Embedded System
Project 3: RSA Encryption
Copyright by Dung Le and Eric Krause

We  designed  a  functional  hardware  encryption  engine,  implemented  using  the Spartan-6-driven  Nexys3  Development  board.    Throughout  the  design  process,  maximum  clock  speed was consistently the primary goal of all code written and all optimizations performed.  

-    Functionally verified 128-bit encryption/decryption 
-    Maximum operational frequency of 175MHZ 
-    Encrypts/Decrypts 7 custom generated 128-bit "Messages" 
-    Implements Montgomery Math algorithms for exponentiation and multiplication. 
-    Uses pre-calculated Nr = 2^2n mod M values for Montgomery Math  
-    Python script for verifying algorithm and calculating Nr values for any bit width 
-    Encryption in approximately 285us for 128 bits (~50,000 clock cycles at 175MHZ) 