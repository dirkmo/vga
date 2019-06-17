#include <stdint.h>
#include <stdio.h>
#include <verilated_vcd_c.h>
#include "Vvgatiming.h"
#include "verilated.h"

VerilatedVcdC *pTrace;
Vvgatiming *pCore;
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

// 640x480 @ 60 Hz

#define hFRONTPORCH 16
#define hSYNCLEN 96
#define hBACKPORCH 48
#define hVISIBLE 640
#define hPOLARITY 0

#define vFRONTPORCH 10
#define vSYNCLEN 2
#define vBACKPORCH 33
#define vVISIBLE 480
#define vPOLARITY 0

int main(int argc, char *argv[]) {
    Verilated::traceEverOn(true);
    pCore = new Vvgatiming();
    opentrace("trace.vcd");

    pCore->i_hSyncStart = hFRONTPORCH;
    pCore->i_hBpStart = pCore->i_hSyncStart + hSYNCLEN;
    pCore->i_hVisibleStart = pCore->i_hBpStart + hBACKPORCH;
    pCore->i_hEnd = pCore->i_hVisibleStart + hVISIBLE;

    pCore->i_vSyncStart = vFRONTPORCH;
    pCore->i_vBpStart = pCore->i_vSyncStart + vSYNCLEN;
    pCore->i_vVisibleStart = pCore->i_vBpStart + vBACKPORCH;
    pCore->i_vEnd = pCore->i_vVisibleStart + vVISIBLE;

    reset();

    for( int i = 0; i < 1000; i++ ) {
        tick();
    }


    if (pTrace) {
        pTrace->close();
        pTrace = NULL;
    }
    return 0;
}
