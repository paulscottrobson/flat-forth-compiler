# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		processcore.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		22nd December 2018
#		Purpose :	Convert vocabulary.asm to assemblable file by adding marker labels.
#
# ***************************************************************************************
# ***************************************************************************************

#
#		Copy vocabulary.asm to __words.asm
#
hOut = open("__words.asm","w")
for l in [x.rstrip() for x in open("vocabulary.asm").readlines()]:
	hOut.write(l+"\n")
	#
	#		If ;; found insert a label which is generated using ASCII so all chars can be used
	#
	if l[:2] == ";;":
		name = "_".join([str(ord(x)) for x in l[2:].strip()])
		hOut.write("core_{0}:\n".format(name))
hOut.close()