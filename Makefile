.PHONY: all clean install

CFLAGS = -I. -O2 -fPIC -Wall -Wextra -Wno-implicit-fallthrough -DNDEBUG -DBLARGG_BUILD_DLL -DSPC_ISOLATED_ECHO_BUFFER
CXXFLAGS = -I. -O2 -fPIC -fno-exceptions -Wno-implicit-fallthrough -fno-rtti -Wall -Wextra -std=c++11 -DNDEBUG -DBLARGG_BUILD_DLL -DSPC_ISOLATED_ECHO_BUFFER

STATIC_PREFIX=lib
DYNLIB_PREFIX=lib
STATIC_EXT=.a
DYNLIB_EXT=.so

SPC_A = $(STATIC_PREFIX)spc$(STATIC_EXT)
SPC_SO = $(DYNLIB_PREFIX)spc$(DYNLIB_EXT)
SPC_BINS = \
  play_spc \
  benchmark \
  trim_spc \
  save_state 

DESTDIR=
PREFIX=/usr/local
BINDIR=$(DESTDIR)$(PREFIX)/bin
LIBDIR=$(DESTDIR)$(PREFIX)/lib
INCDIR=$(DESTDIR)$(PREFIX)/include/snes_spc

all: $(SPC_A) $(SPC_SO) $(SPC_BINS)

SPC_CPP_SRCS = \
  snes_spc/SPC_Filter.cpp \
  snes_spc/SNES_SPC.cpp \
  snes_spc/SNES_SPC_misc.cpp \
  snes_spc/SNES_SPC_state.cpp \
  snes_spc/SPC_DSP.cpp \
  snes_spc/spc.cpp \
  snes_spc/dsp.cpp

SPC_CPP_OBJS = \
  snes_spc/SPC_Filter.o \
  snes_spc/SNES_SPC.o \
  snes_spc/SNES_SPC_misc.o \
  snes_spc/SNES_SPC_state.o \
  snes_spc/SPC_DSP.o \
  snes_spc/spc.o \
  snes_spc/dsp.o

SPC_HEADERS = \
  snes_spc/SNES_SPC.h \
  snes_spc/SPC_CPU.h \
  snes_spc/SPC_DSP.h \
  snes_spc/SPC_Filter.h \
  snes_spc/blargg_common.h \
  snes_spc/blargg_config.h \
  snes_spc/blargg_endian.h \
  snes_spc/blargg_source.h \
  snes_spc/dsp.h \
  snes_spc/spc.h

UTIL_OBJS = demo/demo_util.o
WAVE_OBJS = demo/wave_writer.o
BENCHMARK_OBJS = demo/benchmark.o
TRIM_OBJS = demo/trim_spc.o
SAVE_OBJS = demo/save_state.o
PLAY_OBJS = demo/play_spc.o

play_spc: $(PLAY_OBJS) $(UTIL_OBJS) $(WAVE_OBJS) $(SPC_A)
	$(CC) -o $@ $^

benchmark: $(BENCHMARK_OBJS) $(UTIL_OBJS) $(SPC_A)
	$(CC) -o $@ $^

trim_spc: $(TRIM_OBJS) $(UTIL_OBJS) $(SPC_A)
	$(CC) -o $@ $^

save_state: $(SAVE_OBJS) $(UTIL_OBJS) $(WAVE_OBJS) $(SPC_A)
	$(CC) -o $@ $^

amal/spc.cpp: $(SPC_CPP_SRCS)
	mkdir -p amal
	perl aux/amalgate.pl "c:license.txt" $(SPC_CPP_SRCS) > $@

$(SPC_A): $(SPC_CPP_OBJS)
	$(AR) rcs $@ $^

$(SPC_SO): $(SPC_CPP_OBJS)
	$(CXX) -shared -o $@ $^

clean:
	rm -f play_spc benchmark trim_spc save_state $(UTIL_OBJS) $(WAVE_OBJS) $(PLAY_OBJS) $(BENCHMARK_OBJS) $(TRIM_OBJS) $(SAVE_OBJS) $(SPC_CPP_OBJS) $(SPC_A) $(SPC_SO) amal/spc.cpp amal/*.o

install: $(SPC_A) $(SPC_SO)
	install -d $(LIBDIR)/
	install -m 644 $(SPC_A) $(LIBDIR)/$(SPC_A)
	install -m 755 $(SPC_SO) $(LIBDIR)/$(SPC_SO)
	install -d $(BINDIR)/
	install -m 755 $(SPC_BINS) $(BINDIR)
	install -d $(INCDIR)/
	install -m 644 $(SPC_HEADERS) $(INCDIR)/

