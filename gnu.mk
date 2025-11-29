SHELL=/bin/bash
ARCH=$(shell uname)
ifndef ABI
ABI=lp64
endif # !ABI
RM=rm -rfv
AR=ar
ARFLAGS=rsv
PVNDIR=$(realpath ../libpvn/src)
PVNEXE=$(PVNDIR)/pvn.exe
FC=$(shell $(PVNEXE) -F)
FFLAGS=$(shell $(PVNEXE) -f) $(shell $(PVNEXE) -i) -DUSE_GNU -DUSE_X64
ifeq ($(ABI),ilp64)
FFLAGS += -fdefault-integer-8 -DMKL_ILP64
endif # ilp64
FFLAGS += -pedantic -Wall -Wextra -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
LDFLAGS=$(shell $(PVNEXE) -L)
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
LDFLAGS += $(shell $(PVNEXE) -l)
