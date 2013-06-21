# (c) David Cunningham 2011, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

# this Makefile is just used to set up some variables, the muscle is in
# ../src/common.mk which is used by both linux and win32 builds

ROOT=../../..

include $(ROOT)/common.mk

repro: repro.c++ $(DEPENDENT_LIBS)
	$(COMPILER) $(CFLAGS) repro.c++ -o $@ $(LDFLAGS)


# vim: ts=8:sw=8:noexpandtab
