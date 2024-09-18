SHELL=/bin/bash
ARCH=$(shell uname)
ifndef ABI
ABI=lp64
endif # !ABI
ifdef NDEBUG
DEBUG=
else # DEBUG
DEBUG=g
endif # ?NDEBUG
ifndef FP
FP=precise
endif # !FP
RM=rm -rfv
AR=xiar
ARFLAGS=-qnoipo -lib rsv
FC=ifx
ifndef MARCH
MARCH=common-avx512
endif # !MARCH
CPUFLAGS=-DUSE_INTEL -DUSE_X64 -fPIC -fexceptions -fno-omit-frame-pointer -qopenmp -x$(MARCH) -vec-threshold0 -traceback
FORFLAGS=$(CPUFLAGS) -standard-semantics -threads
ifeq ($(ABI),ilp64)
FORFLAGS += -i8
endif # ilp64
FPUFLAGS=-fp-model=$(FP) -fma -fprotect-parens -no-ftz -fimf-precision=high
FPUFFLAGS=$(FPUFLAGS)
ifeq ($(FP),strict)
FPUFFLAGS += -assume ieee_fpe_flags
endif # strict
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG) -fno-math-errno -inline-level=2
OPTFFLAGS=$(OPTFLAGS)
DBGFLAGS=-DNDEBUG -qopt-report=3
DBGFFLAGS=$(DBGFLAGS)
else # DEBUG
OPTFLAGS=-O0
OPTFFLAGS=$(OPTFLAGS)
DBGFLAGS=-$(DEBUG) -debug emit_column -debug extended -debug inline-debug-info -debug pubnames -debug parallel
DBGFFLAGS=$(DBGFLAGS) -debug-parameters all -check all -warn all
endif # ?NDEBUG
LIBFLAGS=-DUSE_MKL
ifeq ($(ABI),ilp64)
LIBFLAGS += -DMKL_ILP64
endif # ilp64
LIBFLAGS += -D_GNU_SOURCE -I${MKLROOT}/include/intel64/$(ABI) -I${MKLROOT}/include
LDFLAGS=-static-libgcc -rdynamic -L${MKLROOT}/lib/intel64 -Wl,-rpath=${MKLROOT}/lib/intel64 -lmkl_intel_$(ABI) -lmkl_sequential -lmkl_core -lpthread -lm -ldl -lmemkind
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
