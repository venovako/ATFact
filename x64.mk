SHELL=/bin/bash
ARCH=$(shell uname)
ifdef NDEBUG
DEBUG=
else # DEBUG
DEBUG=g
endif # ?NDEBUG
RM=rm -rfv
AR=xiar
ARFLAGS=-qnoipo -lib rsv
FC=ifort
CPUFLAGS=-DUSE_INTEL -DUSE_X64 -fPIC -fexceptions -fno-omit-frame-pointer -qopenmp -rdynamic
FORFLAGS=$(CPUFLAGS) -standard-semantics -threads
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG) -xHost
OPTFFLAGS=$(OPTFLAGS)
DBGFLAGS=-DNDEBUG -qopt-report=5 -traceback -diag-disable=10397
DBGFFLAGS=$(DBGFLAGS)
FPUFLAGS=-fma -fp-model source -no-ftz -no-complex-limited-range -no-fast-transcendentals -prec-div -prec-sqrt -fimf-precision=high -fimf-use-svml=true
FPUFFLAGS=$(FPUFLAGS)
else # DEBUG
OPTFLAGS=-O0 -xHost
OPTFFLAGS=$(OPTFLAGS)
DBGFLAGS=-$(DEBUG) -debug emit_column -debug extended -debug inline-debug-info -debug pubnames -traceback -diag-disable=10397
ifneq ($(ARCH),Darwin)
DBGFLAGS += -debug parallel
endif # !Darwin
DBGFFLAGS=$(DBGFLAGS) -debug-parameters all -check all -warn all
FPUFLAGS=-fp-model strict -fp-stack-check -fma -no-ftz -no-complex-limited-range -no-fast-transcendentals -prec-div -prec-sqrt -fimf-precision=high
FPUFFLAGS=$(FPUFLAGS) -assume ieee_fpe_flags
endif # ?NDEBUG
LIBFLAGS=-DUSE_MKL -I${MKLROOT}/include/intel64/lp64 -I${MKLROOT}/include
ifeq ($(ARCH),Darwin)
LDFLAGS=-L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_lp64 -lmkl_sequential -lmkl_core
else # Linux
LIBFLAGS += -D_GNU_SOURCE
LDFLAGS=-L${MKLROOT}/lib/intel64 -Wl,-rpath=${MKLROOT}/lib/intel64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core
endif # ?Darwin
LDFLAGS += -lpthread -lm -ldl
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
