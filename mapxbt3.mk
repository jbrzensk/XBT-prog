mapxbt3.x: mapxbt3.o fertem.o rdxbtinfo1.o
	gfortran -O -o mapxbt3.x mapxbt3.o fertem.o rdxbtinfo1.o

mapxbt3.o: mapxbt3.f
	gfortran -O -c mapxbt3.f

fertem.o: fertem.f
	gfortran -O -c fertem.f

rdxbtinfo1.o: rdxbtinfo1.f
	gfortran -O -c rdxbtinfo1.f
