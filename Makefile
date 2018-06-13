#
# Unix makefile for rpilot 1.4
# You probably want to use GNU make with this
# Rob Linwood (rcl211@nyu.edu)
#

CC = gcc
CCFLAGS=
#DFLAGS = -g -DDEBUG
CP=cp
RM=rm -f
EXE=
OBJS= main.o rstring.o err.o var.o math.o cmds.o line.o rpilot.o \
      label.o condex.o debug.o stack.o rpinfo.c bind.o calc.o
PROGS=rpilot line condex rstring

VERSION = 1.4.2

#
# Note: if you are not installing as root, please change the next line!
#
INSTALL_DIR = /usr/local/
BIN_DIR = $(INSTALL_DIR)bin/
MAN1_DIR = $(INSTALL_DIR)man/man1/
SHARE_DIR = $(INSTALL_DIR)share/rpilot/
DOC_DIR = $(INSTALL_DIR)doc/rpilot-$(VERSION)/

.c.o:
	$(CC) $(CCFLAGS) -o $@ -c $<

.PHONY : all install uninstall clean del bootstrap-clean libs bootstrap tar \
	 debug

all : rpilot

rpilot : $(OBJS) interact.o
	$(CC) $(CCFLAGS) -o rpilot $(OBJS) interact.o



rpilot.o : rpilot.c
	$(CC) -DIGNORE_HASH -o $@ -c $<

interact.o : interact.c
	$(CC) -DNO_INTER -o $@ -c $<

tar : clean
	cd .. && tar -c rpilot-$(VERSION)/*|gzip ->rpilot-$(VERSION).tar.gz

install : rpilot
	mkdir -p $(BIN_DIR)
	install -s -m 755 rpilot $(BIN_DIR)rpilot
	mkdir -p $(MAN1_DIR)
	install -m 644 doc/rpilot.1 $(MAN1_DIR)rpilot.1
	mkdir -p $(DOC_DIR)
	install -m 644 doc/* $(DOC_DIR)
	rm -f $(DOC_DIR)rpilot.1
	mkdir -p $(SHARE_DIR)examples
	install -m 644 examples/* $(SHARE_DIR)examples/

uninstall : 
	$(RM) $(BIN_DIR)rpilot
	$(RM) $(MAN1_DIR)rpilot.1
	rm -rf $(DOC_DIR)
	rm -rf $(SHARE_DIR)


##############################################################################
#
# The next few targets are for the RPilot libraries.  These are really not
# that useful in the current release, but when the translater/binder/whatever
# is in a usable state, these will be needed.
#
##############################################################################

libs : librpilot.so librpilot.a

librpilot.so : $(OBJS)  interact.o
	gcc -shared -Wl,-soname,$@ -o librpilot.so.1.4 $^ -lc

librpilot.a : $(OBJS) interact.o
	ar rcs $@ $^



##############################################################################
#
# The following targets allow you to bootstrap RPilot completely, without
# any pre-bound C files
#
# NOTE: None of these are used in 1.4!  They are unsupported and in various
# states of brokenness.
#
##############################################################################

bootstrap : rp1
	./rp1 -c -f inter -d inter_code inter.p
	$(CC) $(CCFLAGS) -o inter.o -c inter.c

rp1 : $(OBJS) interact.rp1.o
	$(CC) $(CCFLAGS) -DNO_INTER -o rp1 $^

interact.rp1.o : interact.c
	$(CC) -DNO_INTER -o $@ -c $<

#inter.c : inter.p
#	./rp1 -c -d inter_data -f inter inter.p

##############################################################################
#
# The programs below here are test drivers for the various bits of RPilot
#
##############################################################################

rstring : rstring.c
	$(CC) $(CCFLAGS) -DSTANDALONE -o $@$(EXE) $<

line.test.o : line.c 
	$(CC) $(CCFLAGS) -DTEST -o line.test.o -c line.c

line : line.test.o rstring.o condex.o
	$(CC) $(CCFLAGS) -DTEST -o $@ $^

condex.test.o : condex.c
	$(CC) $(CCFLAGS) -DTEST -o $@ -c $<

condex : condex.test.o rstring.o
	$(CC) $(CCFLAGS) -o $@ $^


##############################################################################
#
# The next few targets are for cleaning up RPilot or debugging it
#
##############################################################################


clean :
	$(RM) *.o *~
	$(RM) $(PROGS) $(LIBS)
#	$(RM) inter.c inter.h

del : 
	$(RM) *~

bootstrap-clean : 
	$(RM) rp1 interact.rp1.o

debug: 
	CFLAGS += "-g -DDEBUG "
	make all











