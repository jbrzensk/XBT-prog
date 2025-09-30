cruisehtml.x: cruisehtml.o rdxbtinfo1.o
	gfortran -O -o cruisehtml.x cruisehtml.o rdxbtinfo1.o

cruisehtml.o: cruisehtml.f
	gfortran -O -c cruisehtml.f

rdxbtinfo1.o: rdxbtinfo1.f
	gfortran -O -c rdxbtinfo1.f
