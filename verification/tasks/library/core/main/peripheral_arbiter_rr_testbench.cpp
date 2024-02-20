#include "Vperipheral_arbiter_rr.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv, char **env) {
  int i;
  Verilated::commandArgs(argc, argv);

  // init top verilog instance
  Vperipheral_arbiter_rr* top = new Vperipheral_arbiter_rr;

  // init trace dump
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace (tfp, 99);
  tfp->open ("peripheral_arbiter_rr.vcd");

  // initialize simulation inputs
  top->req = 0x55;
  top->gnt = 0x22;

  // run simulation for 100 clock periods
  for (i=0; i<20; i++) {
    top->en = (i < 5);

    if (Verilated::gotFinish()) exit(0);
  }

  tfp->close();
  exit(0);
}
