// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vmpsoc_noc_testbench.h for the primary calling header

#ifndef _Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9_H_
#define _Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9_H_

#include "verilated.h"

class Vmpsoc_noc_testbench__Syms;
class Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9;

//----------

VL_MODULE(Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9) {
  public:
    // CELLS
    Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9*	__PVT__vc_mux__DOT__u_mux;
    
    // PORTS
    VL_IN8(__PVT__clk,0,0);
    VL_IN8(__PVT__rst,0,0);
    VL_OUT8(__PVT__out_last,0,0);
    VL_INW(__PVT__in_last,80,0,3);
    VL_INW(__PVT__in_valid,80,0,3);
    VL_OUTW(__PVT__in_ready,80,0,3);
    VL_OUT16(__PVT__out_valid,8,0);
    VL_IN16(__PVT__out_ready,8,0);
    VL_INW(__PVT__in_flit,2753,0,87);
    VL_OUT64(__PVT__out_flit,33,0);
    
    // LOCAL SIGNALS
    
    // LOCAL VARIABLES
    
    // INTERNAL VARIABLES
  private:
    Vmpsoc_noc_testbench__Syms* __VlSymsp;  // Symbol table
  public:
    
    // PARAMETERS
    
    // CONSTRUCTORS
  private:
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9& operator= (const Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9&);  ///< Copying not allowed
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9(const Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9&);  ///< Copying not allowed
  public:
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9(const char* name="TOP");
    ~Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9();
    
    // API METHODS
    
    // INTERNAL METHODS
    void __Vconfigure(Vmpsoc_noc_testbench__Syms* symsp, bool first);
  private:
    void _ctor_var_reset();
} VL_ATTR_ALIGNED(128);

#endif // guard
