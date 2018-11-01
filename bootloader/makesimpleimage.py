# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		makesimpleimage.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		1st November 2018
#		Purpose :	Creates a dummy boot.img which has BRK at $8000
#
# ***************************************************************************************
# ***************************************************************************************

memory = [ 0xDD,0x01 ] 								# tiny boot.img containing CSpect break

h = open("boot.img","wb")							# write out the dummy boot image file
h.write(bytes(memory))
h.close()
print("Created dummy image")