SHELL=/bin/bash
ARCH=$(shell uname)
ifneq ($(ARCH),Linux)
$(error NVIDIA HPC SDK is supported on Linux only)
endif # !Linux
ifdef NDEBUG
DEBUG=
else # DEBUG
DEBUG=g
endif # ?NDEBUG
RM=rm -rfv
AR=ar
ARFLAGS=rsv
FC=nvfortran
CPUFLAGS=-DUSE_NVIDIA -DUSE_X64 -DOLD_OMP -m64 -mp -KPIC -Mframe -Meh_frame -Minfo
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
LIBFLAGS=-D_GNU_SOURCE
LDFLAGS=-L$(NVCOMPILERS)/Linux_x86_64/20.7/compilers/lib -lblas -lpthread -lm -ldl $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
