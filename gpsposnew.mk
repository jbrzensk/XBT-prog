gpsposnew.x: gpsposnew.o rdcntrl.o
	gfortran -O -o gpsposnew.x gpsposnew.o rdcntrl.o

gpsposnew.o: gpsposnew.f
	gfortran -O -c gpsposnew.f

rdcntrl.o: rdcntrl.f
	gfortran -O -c rdcntrl.f
