#include <stdint.h>
#include <stdio.h>
#include <verilated_vcd_c.h>
#include "Vfifo.h"
#include "verilated.h"

VerilatedVcdC *pTrace;
Vfifo *pCore;
uint64_t tickcount;

void opentrace(const char *vcdname) {
    if (!pTrace) {
        pTrace = new VerilatedVcdC;
        pCore->trace(pTrace, 99);
        pTrace->open(vcdname);
    }
}

void tick() {
    tickcount++;

    pCore->i_clk = 0;
    pCore->eval();
    
    if(pTrace) pTrace->dump(static_cast<vluint64_t>(10*tickcount-2));

    pCore->i_clk = 1;
    pCore->eval();
    if(pTrace) pTrace->dump(static_cast<vluint64_t>(10*tickcount));

    pCore->i_clk = 0;
    pCore->eval();
    if (pTrace) {
        pTrace->dump(static_cast<vluint64_t>(10*tickcount+5));
        pTrace->flush();
    }
}

void reset() {
    pCore->i_reset = 1;
    tick();
    pCore->i_reset = 0;
}

void push(uint32_t val) {
    printf("push %d\n", val);
    pCore->i_push = 1;
    pCore->i_dat = val;
    tick();
    pCore->i_push = 0;
    tick();
}

uint32_t pop() {
    uint32_t val = pCore->o_dat;
    pCore->i_pop = 1;
    tick();
    pCore->i_pop = 0;
    tick();
    return val;
}

int main(int argc, char *argv[]) {
    Verilated::traceEverOn(true);
    pCore = new Vfifo();
    opentrace("trace.vcd");

    pCore->i_push = 0;
    pCore->i_pop = 0;
    reset();

    int i=100;
    while( !pCore->o_full ) {
        push(i++);
    }

    while( !pCore->o_empty ) {
        printf("pop: %d\n", pop());
    }

    if (pTrace) {
        pTrace->close();
        pTrace = NULL;
    }
    return 0;
}
