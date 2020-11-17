SHELL=/bin/bash
ARCH=$(shell uname)
ifdef NDEBUG
DEBUG=
else # DEBUG
DEBUG=g
endif # ?NDEBUG
ifndef FP
ifdef NDEBUG
FP=source
else # DEBUG
FP=strict
endif # ?NDEBUG
endif # !FP
RM=rm -rfv
AR=xiar
ARFLAGS=-qnoipo -lib rsv
FC=ifort
CPUFLAGS=-DUSE_INTEL -DUSE_X200 -fPIC -fexceptions -fno-omit-frame-pointer -qopenmp -rdynamic
FORFLAGS=$(CPUFLAGS) -standard-semantics -threads
FPUFLAGS=-fp-model $(FP) -fma -no-ftz -no-complex-limited-range -no-fast-transcendentals -prec-div -prec-sqrt -fimf-precision=high
ifeq ($(FP),strict)
FPUFLAGS += -fp-stack-check -fimf-arch-consistency=true
else # !strict
FPUFLAGS += -fimf-use-svml=true
endif # ?strict
FPUFFLAGS=$(FPUFLAGS)
ifeq ($(FP),strict)
FPUFFLAGS += -assume ieee_fpe_flags
endif # strict
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG) -xHost -qopt-zmm-usage=high
OPTFFLAGS=$(OPTFLAGS)
DBGFLAGS=-DNDEBUG -qopt-report=5 -traceback -diag-disable=10397
DBGFFLAGS=$(DBGFLAGS)
else # DEBUG
OPTFLAGS=-O0 -xHost -qopt-zmm-usage=high
OPTFFLAGS=$(OPTFLAGS)
DBGFLAGS=-$(DEBUG) -debug emit_column -debug extended -debug inline-debug-info -debug parallel -debug pubnames -traceback -diag-disable=10397
DBGFFLAGS=$(DBGFLAGS) -debug-parameters all -check all -warn all
endif # ?NDEBUG
LIBFLAGS=-D_GNU_SOURCE -DUSE_MKL -I${MKLROOT}/include/intel64/lp64 -I${MKLROOT}/include
LDFLAGS=-L${MKLROOT}/lib/intel64 -Wl,-rpath=${MKLROOT}/lib/intel64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl -lmemkind
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
