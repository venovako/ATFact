SHELL=/bin/bash
ARCH=$(shell uname)
ifneq ($(ARCH),Linux)
$(error PGI is supported on Linux only)
endif # Darwin
ifdef NDEBUG
DEBUG=
else # DEBUG
DEBUG=g
endif # ?NDEBUG
RM=rm -rfv
AR=ar
ARFLAGS=rsv
FC=pgfortran
CPUFLAGS=-DUSE_PGI -DUSE_X64 -DOLD_OMP -m64 -mp -KPIC -Mframe -Meh_frame -Minfo -Mnollvm
FORFLAGS=$(CPUFLAGS) -Mdclchk -Mlarge_arrays -Mrecursive -Mstack_arrays
FPUFLAGS=-Kieee -Mfma -Mnodaz -Mnoflushz -Mnofpapprox -Mnofprelaxed
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG)
OPTFFLAGS=$(OPTFLAGS)
DBGFLAGS=-DNDEBUG
DBGFFLAGS=$(DBGFLAGS)
FPUFFLAGS=$(FPUFLAGS)
else # DEBUG
OPTFLAGS=-O0
OPTFFLAGS=$(OPTFLAGS)
DBGFLAGS=-g -Mbounds -Mchkstk -traceback
DBGFFLAGS=$(DBGFLAGS)
FPUFFLAGS=$(FPUFLAGS)
endif # ?NDEBUG
LIBFLAGS=-D_GNU_SOURCE -DUSE_MKL -I${MKLROOT}/include/intel64/lp64 -I${MKLROOT}/include
LDFLAGS=-L${MKLROOT}/lib/intel64 -Wl,-rpath=${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -pgf90libs -lpthread -lm -ldl $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
