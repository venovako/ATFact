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
FFLAGS=$(shell $(PVNEXE) -f) $(shell $(PVNEXE) -i) -DUSE_NVIDIA -DUSE_X64
ifeq ($(ABI),ilp64)
FFLAGS += -i8
endif # ilp64
LDFLAGS=$(shell $(PVNEXE) -L) -lblas_$(ABI) $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi) $(shell $(PVNEXE) -l)
