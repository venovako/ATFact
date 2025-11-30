RM=del /F
AR=lib.exe
ARFLAGS=/NOLOGO /VERBOSE
!IFNDEF ABI
ABI=ilp64
!ENDIF # !ABI
!INCLUDE ..\libpvn\src\pvn.mk
FC=$(PVN_FC)
!IF "$(ABI)"=="ilp64"
FCFLAGS=$(PVN_FCFLAGS) $(PVN_CPPFLAGS) /4I8 /DMKL_ILP64 /Qmkl-ilp64:sequential
!ELSE # lp64
FCFLAGS=$(PVN_FCFLAGS) $(PVN_CPPFLAGS) /Qmkl:sequential
!ENDIF # ilp64
LDFLAGS=$(PVN_LDFLAGS)

all: tatf.exe tatp.exe ttol.exe gen108.exe

help:
	@echo "nmake.exe [ABI=lp64|ilp64] [all|clean|help]"

tatf.exe: tatf.obj atf.obj bio.obj Makefile
	$(FC) $(FCFLAGS) /Fe$@ tatf.obj atf.obj bio.obj $(LDFLAGS)

tatp.exe: tatp.obj atf.obj bio.obj Makefile
	$(FC) $(FCFLAGS) /Fe$@ tatp.obj atf.obj bio.obj $(LDFLAGS)

ttol.exe: ttol.obj atf.obj bio.obj Makefile
	$(FC) $(FCFLAGS) /Fe$@ ttol.obj atf.obj bio.obj $(LDFLAGS)

gen108.exe: gen108.obj Makefile
	$(FC) $(FCFLAGS) /Fe$@ gen108.obj $(LDFLAGS)

atf.obj atf.mod: atf.F90 Makefile
	$(FC) $(FCFLAGS) /c atf.F90

bio.obj bio.mod: bio.F90 Makefile
	$(FC) $(FCFLAGS) /c bio.F90

tatf.obj: tatf.F90 atf.mod bio.mod Makefile
	$(FC) $(FCFLAGS) /c tatf.F90

tatp.obj: tatp.F90 atf.mod bio.mod Makefile
	$(FC) $(FCFLAGS) /c tatp.F90

ttol.obj: ttol.F90 atf.mod bio.mod Makefile
	$(FC) $(FCFLAGS) /c ttol.F90

gen108.obj: gen108.F90 Makefile
	$(FC) $(FCFLAGS) /c gen108.F90

clean:
	-$(RM) *.exe
	-$(RM) *.mod
	-$(RM) *.obj
	-$(RM) *.optrpt
	-$(RM) *.pdb
