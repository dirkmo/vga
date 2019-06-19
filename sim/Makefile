.PHONY: all clean sim wave

UNAME := $(shell uname -s)

VERILATOR_OUTPUTDIR = verilator

INCDIR=-I$(VERILATOR_OUTPUTDIR) -I../verilog -I/usr/share/verilator/include -I../include

VFLAGS = -CFLAGS -std=c++11 -Wall -trace -cc --exe $(INCDIR) --Mdir $(VERILATOR_OUTPUTDIR)
GTKWAVE := gtkwave
ifeq ($(UNAME),Darwin)
VFLAGS += --compiler clang
GTKWAVE := /Applications/gtkwave.app/Contents/MacOS/gtkwave-bin
endif

CFLAGS=-Wall -std=c++11

all: vgatop

verilator: vgatop.cpp ../verilog/vgatiming.v ../verilog/vgatop.v
	verilator $(VFLAGS) ../verilog/vgatop.v ../verilog/vgatiming.v vgatop.cpp


vgatiming: verilator
	make -C $(VERILATOR_OUTPUTDIR) -j4 -f Vvgatiming.mk

vgatop: verilator
	make -C $(VERILATOR_OUTPUTDIR) -j4 -f Vvgatop.mk


verilator_fifo: fifo.cpp ../verilog/fifo.v
	verilator $(VFLAGS) ../verilog/fifo.v fifo.cpp

fifo: verilator_fifo
	make -C $(VERILATOR_OUTPUTDIR) -j4 -f Vfifo.mk

sim_fifo: fifo
	$(VERILATOR_OUTPUTDIR)/Vfifo -d -t


sim: vgatop
	$(VERILATOR_OUTPUTDIR)/Vvgatop -d -t

wave: sim
	gtkwave trace.vcd &

clean:
	rm -f trace.vcd
	rm -f $(VERILATOR_OUTPUTDIR)/*
	-rm -r $(VERILATOR_OUTPUTDIR)
