!IFNDEF ABI
ABI=lp64
!ENDIF # !ABI
!IFDEF NDEBUG
DEBUG=
!ELSE # DEBUG
DEBUG=d
!ENDIF # ?NDEBUG
RM=del /F
AR=xilib.exe
ARFLAGS=-qnoipo -lib /NOLOGO /VERBOSE
!IFNDEF FORT
FORT=ifort
!ENDIF # !FORT
FC=$(FORT).exe
FORFLAGS=/nologo /fpp /DUSE_INTEL /DUSE_X64 /Qopenmp /standard-semantics
LIBFLAGS=/I"$(MKLROOT)\include\intel64\$(ABI)" /I"$(MKLROOT)\include" /libs:dll /threads
!IF "$(ABI)"=="ilp64"
FORFLAGS=$(FORFLAGS) /4I8
LIBFLAGS=$(LIBFLAGS) /DMKL_ILP64
!ENDIF # ilp64
LIBS=/LIBPATH:"$(MKLROOT)\lib\intel64_win" mkl_intel_$(ABI)_dll.lib mkl_intel_thread_dll.lib mkl_core_dll.lib
!IFDEF NDEBUG
OPTFLAGS=/O$(NDEBUG) /QxHost /Qvec-threshold:0
DBGFLAGS=/DNDEBUG /traceback
FPUFLAGS=/fp:precise /Qprotect-parens /Qfma /Qftz-
!IF "$(FORT)"=="ifort"
OPTFLAGS=$(OPTFLAGS) /Qopt-multi-version-aggressive
DBGFLAGS=$(DBGFLAGS) /Qopt-report:5
FPUFLAGS=$(FPUFLAGS) /Qcomplex-limited-range- /Qfast-transcendentals- /Qprec-div /Qprec-sqrt
!ELSE # ifx
DBGFLAGS=$(DBGFLAGS) /Qopt-report:3
!ENDIF # ?FORT
LDFLAGS=/link /RELEASE $(LIBS)
!ELSE # DEBUG
OPTFLAGS=/O$(DEBUG) /QxHost
DBGFLAGS=/debug:full /debug:inline-debug-info /debug-parameters:all /check:all /warn:all /traceback
FPUFLAGS=/fp:precise /Qprotect-parens /Qfma /Qftz- #/fp:strict /assume:ieee_fpe_flags
!IF "$(FORT)"=="ifort"
OPTFLAGS=$(OPTFLAGS) /Qopt-multi-version-aggressive
FPUFLAGS=$(FPUFLAGS) /Qcomplex-limited-range- /Qfast-transcendentals- /Qprec-div /Qprec-sqrt /Qfp-stack-check
!ENDIF # ifort
LIBFLAGS=$(LIBFLAGS) /dbglibs
LDFLAGS=/link /DEBUG $(LIBS)
!ENDIF # ?NDEBUG
FFLAGS=$(OPTFLAGS) $(DBGFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFLAGS)

all: tatf.exe tatp.exe ttol.exe gen108.exe

help:
	@echo "nmake.exe [FORT=ifort|ifx] [NDEBUG=0|1|2|3|4|5] [ABI=lp64|ilp64] [all|clean|help]"

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
