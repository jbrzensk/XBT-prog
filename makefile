# Makefile for updated 2025 Fortran Files
# BY: Jared Brzenski
#
# This Makefile builds one executable per Fortran source file,
# unless a specific .mk file exists for that source file.
#
# It supports both .f and .F90 source files.
#
# Usage: run `make` to build all executables.
#        run `make clean` to remove all executables and object files.
#

# Customize the Fortran compiler and flags as needed.
FC      = gfortran
FFLAGS  ?= -O2 -Wall

# Collect sources ( but not the excluded ones, .o, only used in compilation)
SRC_F   := $(filter-out fertem.f rdcntrl.f rdxbtinfo1.f rdxbtinfo2.f, $(wildcard *.f))
SRC_F90 := $(wildcard *.F90)
SOURCES := $(SRC_F) $(SRC_F90)

# Executable names (.f -> .x, .F90 -> .x, all executables end with .x)
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
