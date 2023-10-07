#include "Vperipheral_noc_mux.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv, char **env) {
  Verilated::commandArgs(argc, argv);

  // init top verilog instance
  Vperipheral_noc_mux* top = new Vperipheral_noc_mux;

  // init trace dump
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace (tfp, 99);
  tfp->open ("peripheral_noc_mux.vcd");

  // initialize simulation inputs
  top->req = 0x55;
  top->gnt = 0x22;

  tfp->close();
  exit(0);
}
