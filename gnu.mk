SHELL=/bin/bash
ARCH=$(shell uname)
ifndef ABI
ABI=lp64
endif # !ABI
RM=rm -rfv
AR=ar
ARFLAGS=rsv
include ../libpvn/src/tmp.mk
FC=$(PVN_FC)
FFLAGS=$(PVN_FCFLAGS) $(PVN_CPPFLAGS) -DUSE_GNU -DUSE_X64
ifeq ($(ABI),ilp64)
FFLAGS += -fdefault-integer-8 -DMKL_ILP64
endif # ilp64
FFLAGS += -pedantic -Wall -Wextra -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
LDFLAGS=$(PVN_LDFLAGS)
ifdef MKLROOT
FFLAGS += -DUSE_MKL -I${MKLROOT}/include/intel64/$(ABI) -I${MKLROOT}/include
ifeq ($(ARCH),Darwin)
LDFLAGS += -L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_$(ABI) -lmkl_sequential -lmkl_core
else # Linux
LDFLAGS += -L${MKLROOT}/lib -Wl,-rpath=${MKLROOT}/lib -lmkl_gf_$(ABI) -lmkl_sequential -lmkl_core
LDFLAGS += $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
endif # ?Darwin
else # !MKLROOT
ifndef LAPACK
LAPACK=$(HOME)/lapack-$(ABI)
endif # !LAPACK
LDFLAGS += -L$(LAPACK) -ltmglib -llapack -lrefblas
endif # ?MKLROOT
LDFLAGS += $(PVN_LIBS)
