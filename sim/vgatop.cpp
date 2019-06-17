#include <stdint.h>
#include <stdio.h>
#include <verilated_vcd_c.h>
#include "Vvgatop.h"
#include "verilated.h"

VerilatedVcdC *pTrace;
Vvgatop *pCore;
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

    pCore->i_vgaclk = 0;
    pCore->eval();
    
    if(pTrace) pTrace->dump(static_cast<vluint64_t>(10*tickcount-2));

    pCore->i_vgaclk = 1;
    pCore->eval();
    if(pTrace) pTrace->dump(static_cast<vluint64_t>(10*tickcount));

    pCore->i_vgaclk = 0;
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

void regwrite(uint16_t addr, uint16_t dat) {
    pCore->i_wb_sel = 3;
    pCore->i_wb_we = 1;
    pCore->i_wb_dat = dat;
    pCore->i_wb_addr = addr;
    pCore->i_wb_clk = 1;
    tick();
    pCore->i_wb_sel = 0;
    pCore->i_wb_we = 0;
    pCore->i_wb_clk = 0;
    tick();
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
    pCore = new Vvgatop();
    opentrace("trace.vcd");

    reset();

    regwrite(0, hFRONTPORCH);
    regwrite(1, hFRONTPORCH + hSYNCLEN);
    regwrite(2, hFRONTPORCH + hSYNCLEN + hBACKPORCH);
    regwrite(3, hFRONTPORCH + hSYNCLEN + hBACKPORCH + hVISIBLE);

    regwrite(4, vFRONTPORCH);
    regwrite(5, vFRONTPORCH + vSYNCLEN);
    regwrite(6, vFRONTPORCH + vSYNCLEN + vBACKPORCH);
    regwrite(7, vFRONTPORCH + vSYNCLEN + vBACKPORCH + vVISIBLE);
    regwrite(8, hPOLARITY | (vPOLARITY << 1) );


    for( int i = 0; i < 1000; i++ ) {
        tick();
    }


    if (pTrace) {
        pTrace->close();
        pTrace = NULL;
    }
    return 0;
}
