// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vmpsoc_noc_testbench.h for the primary calling header

#ifndef _Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9_H_
#define _Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9_H_

#include "verilated.h"

class Vmpsoc_noc_testbench__Syms;

//----------

VL_MODULE(Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9) {
  public:
    
    // PORTS
    VL_IN8(clk,0,0);
    VL_IN8(rst,0,0);
    VL_OUT8(out_last,0,0);
    VL_IN16(in_last,8,0);
    VL_IN16(in_valid,8,0);
    VL_OUT16(in_ready,8,0);
    VL_OUT16(out_valid,8,0);
    VL_IN16(out_ready,8,0);
    VL_INW(in_flit,305,0,10);
    VL_OUT64(out_flit,33,0);
    
    // LOCAL SIGNALS
    
    // LOCAL VARIABLES
    
    // INTERNAL VARIABLES
  private:
    Vmpsoc_noc_testbench__Syms* __VlSymsp;  // Symbol table
  public:
    
    // PARAMETERS
    
    // CONSTRUCTORS
  private:
    Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9& operator= (const Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9&);  ///< Copying not allowed
    Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9(const Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9&);  ///< Copying not allowed
  public:
    Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9(const char* name="TOP");
    ~Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9();
    
    // API METHODS
    
    // INTERNAL METHODS
    void __Vconfigure(Vmpsoc_noc_testbench__Syms* symsp, bool first);
  private:
    void _ctor_var_reset();
} VL_ATTR_ALIGNED(128);

#endif // guard
