# SC126 Z180 LCD Display
This is simply a program to send two lines of text to a standard 1602 (Non-I2C) LCD Display.  Although the program works, I need to go back and calculate the initialization sequence timing to more closely resemble the specifications of the display.
At the bott of the program code, you will find the message to send.  The first 16 characters of this message appear on the first line of the LCD, and the next 16 characters will appear on the second line.
For this project, I'm using the prototype breakout module by Stephen Cousins (SC115).  This module is configured for ports 6&7.
-- Ricky Bryce
