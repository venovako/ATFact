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
RM=rm -rfv
AR=ar
ARFLAGS=rsv
FC=gfortran$(GNU)
CPUFLAGS=-DUSE_GNU -DUSE_X64 -fPIC -fexceptions -fasynchronous-unwind-tables -fno-omit-frame-pointer -fopenmp -fvect-cost-model=unlimited
FORFLAGS=-cpp $(CPUFLAGS) -ffree-line-length-none -fstack-arrays
ifeq ($(ABI),ilp64)
FORFLAGS += -fdefault-integer-8
endif # ilp64
ifeq ($(ARCH),Darwin)
OPTFLAGS += -Wa,-q
endif # ?Darwin
ifndef MARCH
ifeq ($(shell uname -m),ppc64le)
MARCH=mcpu=native -mpower8-fusion -mtraceback=full
else # !ppc64le
MARCH=march=native
endif # ?ppc64le
endif # !MARCH
ifdef NDEBUG
OPTFLAGS += -O$(NDEBUG) -$(MARCH) -fno-math-errno
DBGFLAGS=-DNDEBUG -pedantic -Wall -Wextra
OPTFFLAGS=$(OPTFLAGS)
DBGFFLAGS=$(DBGFLAGS) -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
FPUFLAGS=-ffp-contract=fast
FPUFFLAGS=$(FPUFLAGS)
else # DEBUG
OPTFLAGS += -O$(DEBUG) -$(MARCH)
DBGFLAGS=-$(DEBUG) -pedantic -Wall -Wextra
OPTFFLAGS=$(OPTFLAGS)
DBGFFLAGS=$(DBGFLAGS) -fcheck=all -finit-local-zero -finit-real=snan -finit-derived -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
FPUFLAGS=-ffp-contract=fast
FPUFFLAGS=$(FPUFLAGS)
endif # ?NDEBUG
LIBFLAGS=
ifeq ($(ARCH),Linux)
LIBFLAGS += -D_GNU_SOURCE
endif # Linux
ifeq ($(ABI),ilp64)
LIBFLAGS += -DMKL_ILP64
endif # ilp64
LDFLAGS=-rdynamic -static-libgcc -static-libgfortran -static-libquadmath # -static
ifdef MKLROOT
LIBFLAGS += -DUSE_MKL -I${MKLROOT}/include/intel64/$(ABI) -I${MKLROOT}/include
ifeq ($(ARCH),Darwin)
#-L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -L${MKLROOT}/../compiler/lib -Wl,-rpath,${MKLROOT}/../compiler/lib -lmkl_intel_$(ABI) -lmkl_sequential -lmkl_core
LDFLAGS += ${MKLROOT}/lib/libmkl_intel_$(ABI).a ${MKLROOT}/lib/libmkl_sequential.a ${MKLROOT}/lib/libmkl_core.a
else # Linux
#-L${MKLROOT}/lib/intel64 -Wl,-rpath=${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_$(ABI) -lmkl_sequential -lmkl_core
LDFLAGS += -Wl,--start-group ${MKLROOT}/lib/libmkl_gf_$(ABI).a ${MKLROOT}/lib/libmkl_sequential.a ${MKLROOT}/lib/libmkl_core.a -Wl,--end-group
LDFLAGS += $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
endif # ?Darwin
else # !MKLROOT
ifndef LAPACK
LAPACK=$(HOME)/lapack-$(ABI)
endif # !LAPACK
LDFLAGS += -L$(LAPACK) -ltmglib -llapack -lrefblas
endif # ?MKLROOT
LDFLAGS += -lpthread -lm -ldl
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
