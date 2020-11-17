!IFDEF NDEBUG
DEBUG=
!ELSE # DEBUG
DEBUG=d
!ENDIF # ?NDEBUG
RM=del /F
AR=xilib.exe
ARFLAGS=-qnoipo -lib /NOLOGO /VERBOSE
FC=ifort
FORFLAGS=/nologo /fpp /DUSE_INTEL /DUSE_X64 /Qopenmp /standard-semantics
!IFDEF NDEBUG
OPTFLAGS=/O$(NDEBUG) /QxHost
DBGFLAGS=/DNDEBUG /Qopt-report:5 /traceback
FPUFLAGS=/fp:source /Qfma /Qftz- /Qcomplex-limited-range- /Qfast-transcendentals- /Qprec-div /Qprec-sqrt
LIBFLAGS=/Qmkl /libs:dll /threads
LDFLAGS=/link /RELEASE
!ELSE # DEBUG
OPTFLAGS=/O$(DEBUG) /QxHost
DBGFLAGS=/debug:full /debug:inline-debug-info /debug-parameters:all /check:all /warn:all /traceback
FPUFLAGS=/fp:source /Qfma /Qftz- /Qcomplex-limited-range- /Qfast-transcendentals- /Qprec-div /Qprec-sqrt #/fp:strict /assume:ieee_fpe_flags /Qfp-stack-check
LIBFLAGS=/Qmkl /libs:dll /threads /dbglibs
LDFLAGS=/link /DEBUG
!ENDIF # ?NDEBUG
FFLAGS=$(OPTFLAGS) $(DBGFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFLAGS)

all: tatf.exe tatp.exe ttol.exe gen108.exe

help:
	@echo "nmake.exe [NDEBUG=0|1|2|3|4|5] [all|clean|help]"

tatf.exe: tatf.obj atf.obj bio.obj Makefile
	$(FC) $(FFLAGS) /Fe$@ tatf.obj atf.obj bio.obj $(LDFLAGS)

tatp.exe: tatp.obj atf.obj bio.obj Makefile
	$(FC) $(FFLAGS) /Fe$@ tatp.obj atf.obj bio.obj $(LDFLAGS)

ttol.exe: ttol.obj atf.obj bio.obj Makefile
	$(FC) $(FFLAGS) /Fe$@ ttol.obj atf.obj bio.obj $(LDFLAGS)

gen108.exe: gen108.obj Makefile
	$(FC) $(FFLAGS) /Fe$@ gen108.obj $(LDFLAGS)

atf.obj atf.mod: atf.F90 Makefile
	$(FC) $(FFLAGS) /c atf.F90

bio.obj bio.mod: bio.F90 Makefile
	$(FC) $(FFLAGS) /c bio.F90

tatf.obj: tatf.F90 atf.mod bio.mod Makefile
	$(FC) $(FFLAGS) /c tatf.F90

tatp.obj: tatp.F90 atf.mod bio.mod Makefile
	$(FC) $(FFLAGS) /c tatp.F90

ttol.obj: ttol.F90 atf.mod bio.mod Makefile
	$(FC) $(FFLAGS) /c ttol.F90

gen108.obj: gen108.F90 Makefile
	$(FC) $(FFLAGS) /c gen108.F90

clean:
	-$(RM) *.exe
	-$(RM) *.mod
	-$(RM) *.obj
	-$(RM) *.optrpt
	-$(RM) *__genmod.f90
	-$(RM) *__genmod.mod
