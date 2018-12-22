# *********************************************************************************
# *********************************************************************************
#
#		File:		makecore.py
#		Purpose:	Creates core assembly file from CLI specification.
#		Date : 		22nd December 2018
#		Author:		paul@robsons.org.uk
#
# *********************************************************************************
# *********************************************************************************

import sys,os
eCount = 0
fCount = 0
xCount = 0
#
#		Get the list of components and check core is in it.
#
elements = [x.lower() for x in sys.argv[1:]]
if "core" not in elements:
	elements.append("core")
#
#		Look for dotted components, if they exist, include their parent.
#
for e in elements:
	if e.find(".") >= 0:
		parent = e.split(".")[0]
		if parent not in elements:
			elements.append(parent)
eCount = len(elements)
#
#		Open output file and work through code, getting the files we need, except
#		data.asm and kernel.asm in the core which go last and first.
#
asmFiles = []
for e in elements:
	for root,dirs,files in os.walk(e):
		for f in files:
			if root != "core" or (f != "data.asm" and f != "kernel.asm"):
				asmFiles.append(root+os.sep+f)
#
#		Add kernel first and data last
#			
asmFiles.sort()
asmFiles.append("core"+os.sep+"data.asm")
asmFiles.insert(0,"core"+os.sep+"kernel.asm")
fCount = len(asmFiles)
#
#		Create assembly file.
#
labelCount = 0
externals = {}
hOut = open("__core.asm","w")
for f in asmFiles:
	#
	#		Copy each line
	#
	for l in open(f).readlines():
		l = l.rstrip()
		#
		#		If it's a definition ;; <word> then allocate it a label number, create
		#		a label and store the reference in externals[]
		#
		if l[:2] == ";;":
			externals[l[2:].strip()] = "external_"+str(labelCount)
			hOut.write("external_{0}:\n".format(labelCount))
			labelCount += 1
			xCount += 1
		hOut.write(l+"\n")
hOut.close()
#
#		Create externals.inc file from the externals[] hash.
#
hOut = open("__externals.inc","w")
hOut.write(";\n; *** automatically generated ***\n;\n")
for k in externals.keys():
	hOut.write("\tdb\t{0},\"{1}\"\n".format(len(k),k))
	hOut.write("\tdw\t{0}\n".format(externals[k]))
hOut.write("\tdb\t0\n")
hOut.close()
#
print("Created {0} words from {1} files in {2} libraries.".format(xCount,fCount,eCount))
