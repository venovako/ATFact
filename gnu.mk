SHELL=/bin/bash
ARCH=$(shell uname)
ifdef NDEBUG
DEBUG=
else # DEBUG
DEBUG=g
endif # ?NDEBUG
RM=rm -rfv
AR=ar
ARFLAGS=rsv
FC=gfortran
CPUFLAGS=-DUSE_GNU -DUSE_X64 -fPIC -fexceptions -fno-omit-frame-pointer -fopenmp -rdynamic
FORFLAGS=-cpp $(CPUFLAGS) -ffree-line-length-none -fstack-arrays
ifeq ($(ARCH),Darwin)
OPTFLAGS += -Wa,-q
endif # ?Darwin
ifdef NDEBUG
OPTFLAGS += -O$(NDEBUG) -march=native -fgcse-las -fgcse-sm -fipa-pta -ftree-loop-distribution -ftree-loop-im -ftree-loop-ivcanon -fivopts -fvect-cost-model=unlimited -fvariable-expansion-in-unroller
DBGFLAGS=-DNDEBUG -fopt-info-optimized-vec -pedantic -Wall -Wextra
OPTFFLAGS=$(OPTFLAGS)
DBGFFLAGS=$(DBGFLAGS) -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
FPUFLAGS=-ffp-contract=fast
FPUFFLAGS=$(FPUFLAGS)
else # DEBUG
OPTFLAGS += -O$(DEBUG) -march=native
DBGFLAGS=-$(DEBUG) -pedantic -Wall -Wextra
OPTFFLAGS=$(OPTFLAGS)
DBGFFLAGS=$(DBGFLAGS) -fcheck=all -finit-local-zero -finit-real=snan -finit-derived -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
FPUFLAGS=-ffp-contract=fast
FPUFFLAGS=$(FPUFLAGS)
endif # ?NDEBUG
LIBFLAGS=-DUSE_MKL -I${MKLROOT}/include/intel64/lp64 -I${MKLROOT}/include
ifeq ($(ARCH),Darwin)
LDFLAGS=-L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -L${MKLROOT}/../compiler/lib -Wl,-rpath,${MKLROOT}/../compiler/lib -lmkl_intel_lp64 -lmkl_sequential -lmkl_core
else # Linux
LIBFLAGS += -D_GNU_SOURCE
LDFLAGS=-L${MKLROOT}/lib/intel64 -Wl,-rpath=${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_sequential -lmkl_core
endif # ?Darwin
LDFLAGS += -lpthread -lm -ldl $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
