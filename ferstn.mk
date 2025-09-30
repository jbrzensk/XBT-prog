ferstn.x: ferstn.o rdxbtinfo1.o
	gfortran -O -o ferstn.x ferstn.o rdxbtinfo1.o

ferstn.o: ferstn.f
	gfortran -O -c ferstn.f

rdxbtinfo1.o: rdxbtinfo1.f
	gfortran -O -c rdxbtinfo1.f
