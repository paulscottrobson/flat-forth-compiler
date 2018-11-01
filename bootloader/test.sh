sh build.sh
#
#		Create a dummy boot.img file to run.
#
python makesimpleimage.py
#
#		Run it
#
if [ -e  bootloader.sna	]
then
	wine ../bin/CSpect.exe -zxnext -cur -brk  bootloader.sna 2>/dev/null
fi


