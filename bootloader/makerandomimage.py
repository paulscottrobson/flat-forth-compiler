# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		makerandomimage.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		21st October 2018
#		Purpose :	Creates a dummy boot.img which has BRK at $8000
#
# ***************************************************************************************
# ***************************************************************************************

import random
memsize = (1+32)*16384								# 16k at $8000-$BFFF, 32 pages at $C000-$FFFF
memory = [ 0 ] * memsize							# fill memory with random numbers
for i in range(0,memsize):
	memory[i] = random.randint(0,255)
memory[0] = 0xDD 									# put break here (at $8000)
memory[1] = 0x01

h = open("boot.img","wb")							# write out the dummy boot image file
h.write(bytes(memory))
h.close()

print("Created {0}k image".format(memsize/1024))