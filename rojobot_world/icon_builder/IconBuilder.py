#!/usr/bin/python
# -*- coding: cp1252 -*-
#
# ROM icon builder - This script generates rom icon images to use
# with RoJobot World's Icon module. A standard format image is translated to array of
# 8-bit RGB pixels (true color). The script is also packing 2 translated images into
# single .coe file: original orientation image and 45 clockwise rotated image.
# .coe file can be used during core generator wizard.
#
# copyright by Dung Le
# 
# 1. Image Library links
# http://www.geeks3d.com/20100930/tutorial-first-steps-with-pil-python-imaging-library/
# http://effbot.org/downloads/PIL-1.1.7.win32-py2.7.exe
# 
# 2. coeficient file format
# memory_initialization_radix=16;
# memory_initialization_vector= 80, 0F, 00, 0B, 00, 0C, …, 81;
#
# USAGE: change input params and run!!!
# 

from PIL import Image
import array, csv
#============================ INPUT PARAMS ================================
# FIX THIS WITH YOUR INPUT ICON

icon = "Bee.png"
outputName = "Bee"

#============================ FUNCTION DEFINITIONS ================================

# Brief: Make raw array of 1 byte true color RGB
# Param:
#   image : 3-byte "RGB" converted Image object
#   name  : output .coe file name
# Return: compressed 1-byte RGB pixel array
#
# Note: 8-bit true color for VGA
# Bit    7  6  5  4  3  2  1  0
# Data   R  R  R  G  G  G  B  B
def convertRGBTrueColor (image,name):
    lst = list(image.getdata())     
    data = array.array('B')
    Imagesize = len(lst)
    fo2 = open (name+".coe","w")
    #fo3 = open (name+".mif","w")
    fo2.write("memory_initialization_radix=10;\n")
    fo2.write("memory_initialization_vector=\n")

    x = 0
    while (x < Imagesize):
        byte = ((((lst[x][0]) >> 5) << 5) + (((lst[x][1]) >> 5) << 2) + (((lst[x][2]) >> 6)))
        data.append((byte))
        x = x + 1
        if x < Imagesize:
            fo2.write(str(byte)+ ",")
            #fo3.write("{0:08b}".format(byte) + "\n")
        else:
            fo2.write(str(byte)+ ";")
            #fo3.write("{0:08b}".format(byte))
   # fo3.close()
    fo2.close()
    return data
#
# Brief: simple print out of monochrome version of image
#
def printIMG(image):
    pr_lst = list(image.getdata())     
    print "size =", len(pr_lst)
    print
    loc = 0
    while (loc < 256):
        if pr_lst[loc][0] > 1:        
            print "1",
        else:
            print " ",
        loc = loc + 1
        if loc%16 == 0:
            print
    return

#================================= MAIN ==================================
im = Image.open(icon)
# rotate and convert to 3 bytes RGB images
im0 = im.rotate(45)
im0 = im0.convert("RGB")
# display
printIMG(im0)
# get the first image array, original orientation
hex0 = convertRGBTrueColor(im0,outputName + "0")
# rotate and convert to 3 bytes RGB images 
im1 = im.rotate(0)
im1 = im1.convert("RGB")
# display
printIMG(im1)
# get the second image array, 45 degree clock wise orientation
hex1 = convertRGBTrueColor(im1,outputName + "45")
# packing two arrays to single .coe file
combinedCoeFile = open(outputName + "Combined.coe", "w")
combinedCoeFile.write("memory_initialization_radix=10;\n")
combinedCoeFile.write("memory_initialization_vector=\n")
i = 0
while i < hex0.buffer_info()[1] :
    combinedCoeFile.write(str(hex0[i])+ ",")
    i = i + 1
i = 0
while i < hex1.buffer_info()[1] - 1 :
    combinedCoeFile.write(str(hex1[i])+ ",")
    i = i + 1
combinedCoeFile.write(str(hex1[i])+ ";")
combinedCoeFile.close()
#================================= DONE ==================================
