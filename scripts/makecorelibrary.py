# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		makecorelibrary.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		22nd December 2018
#		Purpose :	Create Python core code library.
#
# ***************************************************************************************
# ***************************************************************************************

from labels import *
#
#		Get binary code
#
binary = [x for x in open("core.bin","rb").read(-1)]
#
#		Create Python header
#
hOut = open("corewords.py","w")
hOut.write("#\n# *** Automatically Generated ***\n#\n")
hOut.write("class CoreWords(object):\n")
hOut.write("\tdef get(self):\n")
#
#		Get all labels that are core words and sort into code order
#
lbl = LabelExtractor("core.bin.vice").getLabels()
coreWords = [x for x in lbl.keys() if x[:5] == "core_"]
coreWords.sort(key = lambda x:lbl[x])
#
#		Do each word, the last one is a marker to get the length.
#
for i in range(0,len(coreWords)-1):
	#
	#		Rip information
	#
	name = "".join([chr(int	(x)) for x in coreWords[i][5:].split("_")])
	offset = lbl[coreWords[i]]
	size = lbl[coreWords[i+1]]-offset 
	assert size > 0 and size < 32
	#
	#		Get binary code and convert to Python
	#
	code = binary[offset:offset+size]
	hOut.write("\t\tcore[\"{0}\"] = {1}\n".format(name,code))
hOut.write("\treturn core\n\n")
hOut.close()