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
FFLAGS=$(PVN_FCFLAGS) $(PVN_CPPFLAGS) -DUSE_INTEL -DUSE_X64 -DUSE_MKL -I${MKLROOT}/include/intel64/$(ABI) -I${MKLROOT}/include
ifeq ($(ABI),ilp64)
FFLAGS += -i8 -DMKL_ILP64
endif # ilp64
LDFLAGS=$(PVN_LDFLAGS)
ifeq ($(ARCH),Darwin)
LDFLAGS += -L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_$(ABI) -lmkl_sequential -lmkl_core
else # Linux
LDFLAGS += -L${MKLROOT}/lib -Wl,-rpath=${MKLROOT}/lib -lmkl_intel_$(ABI) -lmkl_sequential -lmkl_core
LDFLAGS += $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
endif # ?Darwin
LDFLAGS += $(PVN_LIBS)
