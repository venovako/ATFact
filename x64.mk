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
FFLAGS=$(shell $(PVNEXE) -f) $(shell $(PVNEXE) -i) -DUSE_INTEL -DUSE_X64 -DUSE_MKL -I${MKLROOT}/include/intel64/$(ABI) -I${MKLROOT}/include
ifeq ($(ABI),ilp64)
FFLAGS += -i8 -DMKL_ILP64
endif # ilp64
LDFLAGS=$(shell $(PVNEXE) -L)
ifeq ($(ARCH),Darwin)
LDFLAGS += -L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_$(ABI) -lmkl_sequential -lmkl_core
else # Linux
LDFLAGS += -L${MKLROOT}/lib -Wl,-rpath=${MKLROOT}/lib -lmkl_intel_$(ABI) -lmkl_sequential -lmkl_core
LDFLAGS += $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
endif # ?Darwin
LDFLAGS += $(shell $(PVNEXE) -l)
