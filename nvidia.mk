SHELL=/bin/bash
ARCH=$(shell uname)
ifndef ABI
ABI=lp64
endif # !ABI
RM=rm -rfv
AR=ar
ARFLAGS=rsv
ifndef LIBPVN
LIBPVN=../libpvn
endif # !LIBPVN
include $(LIBPVN)/src/pvn.mk
FC=$(PVN_FC)
FFLAGS=$(PVN_FCFLAGS) $(PVN_CPPFLAGS) -DUSE_NVIDIA -DUSE_X64
ifeq ($(ABI),ilp64)
FFLAGS += -i8
endif # ilp64
LDFLAGS=$(PVN_LDFLAGS) -lblas_$(ABI) $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi) $(PVN_LIBS)
