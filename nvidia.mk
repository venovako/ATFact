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
FC=nvfortran
ifndef CPU
CPU=native
endif # !CPU
CPUFLAGS=-DUSE_NVIDIA -DUSE_X64 -m64 -mp -KPIC -Mframe -Meh_frame -Minfo -tp=$(CPU) -traceback
FORFLAGS=$(CPUFLAGS) -Mdclchk -Mlarge_arrays -Mrecursive -Mstack_arrays
ifeq ($(ABI),ilp64)
FORFLAGS += -i8
endif # ilp64
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
DBGFLAGS=-g -Mbounds -Mchkstk
DBGFFLAGS=$(DBGFLAGS)
FPUFFLAGS=$(FPUFLAGS)
endif # ?NDEBUG
LIBFLAGS=-D_GNU_SOURCE
LDFLAGS=-Wl,-E -lblas_$(ABI) -lpthread -lm -ldl $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
