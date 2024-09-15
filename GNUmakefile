ifndef COMPILER
COMPILER=gnu
endif # !COMPILER
include $(COMPILER).mk
MKFS=GNUmakefile $(COMPILER).mk

.PHONY: all help clean

all: tatf.exe tatp.exe ttol.exe gen108.exe

help:
	@echo "make [COMPILER=gnu|x64x|x200|nvidia] [CPU=...] [NDEBUG=0|1|2|3|4|5] [ABI=ilp64|lp64] [all|clean|help]"

tatf.exe: tatf.o atf.o bio.o $(MKFS)
	$(FC) $(FFLAGS) -o $@ $< atf.o bio.o $(LDFLAGS)

tatp.exe: tatp.o atf.o bio.o $(MKFS)
	$(FC) $(FFLAGS) -o $@ $< atf.o bio.o $(LDFLAGS)

ttol.exe: ttol.o atf.o bio.o $(MKFS)
	$(FC) $(FFLAGS) -o $@ $< atf.o bio.o $(LDFLAGS)

gen108.exe: gen108.o $(MKFS)
	$(FC) $(FFLAGS) -o $@ $< $(LDFLAGS)

atf.o atf.mod: atf.F90 $(MKFS)
	$(FC) $(FFLAGS) -c $<

bio.o bio.mod: bio.F90 $(MKFS)
	$(FC) $(FFLAGS) -c $<

tatf.o: tatf.F90 atf.mod bio.mod $(MKFS)
	$(FC) $(FFLAGS) -c $<

tatp.o: tatp.F90 atf.mod bio.mod $(MKFS)
	$(FC) $(FFLAGS) -c $<

ttol.o: ttol.F90 atf.mod bio.mod $(MKFS)
	$(FC) $(FFLAGS) -c $<

gen108.o: gen108.F90 $(MKFS)
	$(FC) $(FFLAGS) -c $<

clean:
	-$(RM) *.exe
	-$(RM) *.mod
	-$(RM) *.o
	-$(RM) *.optrpt
	-$(RM) *.opt.yaml
	-$(RM) *__genmod.f90
	-$(RM) *__genmod.mod
	-$(RM) *.dSYM
