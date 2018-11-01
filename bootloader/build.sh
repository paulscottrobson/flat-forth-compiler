#
#	#ove SNA files
#
rm bootloader.sna 
rm ../files/bootloader.sna
#
#	Build SNA file
#
zasm -buw bootloader.asm -o bootloader.sna
#
#	Copy to files area if successful.
#
if [ -e  bootloader.sna	]
then
	cp bootloader.sna ../files 
fi


