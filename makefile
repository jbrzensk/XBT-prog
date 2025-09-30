# --- Makefile: build one executable per Fortran source file ---

FC      = gfortran
FFLAGS  ?= -O2 -Wall

# Collect sources
SRC_F   := $(filter-out fertem.f rdcntrl.f rdxbtinfo1.f rdxbtinfo2.f, $(wildcard *.f))
SRC_F90 := $(wildcard *.F90)
SOURCES := $(SRC_F) $(SRC_F90)

# Executable names (.f -> .x, .F90 -> .x)
EXECS   := $(SOURCES:.f=.x)
EXECS   := $(EXECS:.F90=.x)

# Default target: build all executables
all: $(EXECS)

# Rule: if a .mk file exists for the source, delegate to it
%.x: %.mk
	$(MAKE) -f $<

# Rule: build .f file into .x (if no .mk file exists)
%.x: %.f
	$(FC) $(FFLAGS) -o $@ $<

# Rule: build .F90 file into .x (if no .mk file exists)
%.x: %.F90
	$(FC) $(FFLAGS) -o $@ $<

# Clean up everything
clean:
	rm -f $(EXECS) *.o

.PHONY: all clean

