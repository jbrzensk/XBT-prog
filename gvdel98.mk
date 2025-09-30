gvdel98.x: gvdel98.o rdxbtinfo2.o
	gfortran -O -o gvdel98.x gvdel98.o rdxbtinfo2.o

gvdel98.o: gvdel98.f
	gfortran -O -c gvdel98.f

rdxbtinfo2.o: rdxbtinfo2.f
	gfortran -O -c rdxbtinfo2.f
