SHELL = /bin/sh
CC    = gcc
INSTALL = install
PREFIX ?= /usr/local
BINDIR = $(DESTDIR)$(PREFIX)/bin
LIBEXECDIR = $(DESTDIR)$(PREFIX)/libexec/livepatch-build-tools

.PHONY: all install clean
.DEFAULT: all

CFLAGS  += -Iinsn -Wall -g
LDFLAGS = -lelf

TARGETS = create-diff-object prelink
CREATE_DIFF_OBJECT_OBJS = create-diff-object.o lookup.o insn/insn.o insn/inat.o common.o
PRELINK_OBJS = prelink.o lookup.o insn/insn.o insn/inat.o common.o
SOURCES = create-diff-object.c prelink.c lookup.c insn/insn.c insn/inat.c common.c

all: $(TARGETS)

-include $(SOURCES:.c=.d)

%.o : %.c
	$(CC) -MMD -MP $(CFLAGS) -c -o $@ $<

create-diff-object: $(CREATE_DIFF_OBJECT_OBJS)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

prelink: $(PRELINK_OBJS)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

install: all
	$(INSTALL) -d $(LIBEXECDIR)
	$(INSTALL) $(TARGETS) livepatch-gcc $(LIBEXECDIR)
	$(INSTALL) -d $(BINDIR)
	$(INSTALL) livepatch-build $(BINDIR)

clean:
	$(RM) $(TARGETS) $(CREATE_DIFF_OBJECT_OBJS) $(PRELINK_OBJS) *.d insn/*.d
