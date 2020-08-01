// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vmpsoc_noc_testbench.h for the primary calling header

#ifndef _Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10_H_
#define _Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10_H_

#include "verilated.h"

class Vmpsoc_noc_testbench__Syms;
class Vmpsoc_noc_testbench_noc_router_input__pi2;
class Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9;

//----------

VL_MODULE(Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10) {
  public:
    // CELLS
    Vmpsoc_noc_testbench_noc_router_input__pi2*	__PVT__inputs__BRA__0__KET____DOT__u_input;
    Vmpsoc_noc_testbench_noc_router_input__pi2*	__PVT__inputs__BRA__1__KET____DOT__u_input;
    Vmpsoc_noc_testbench_noc_router_input__pi2*	__PVT__inputs__BRA__2__KET____DOT__u_input;
    Vmpsoc_noc_testbench_noc_router_input__pi2*	__PVT__inputs__BRA__3__KET____DOT__u_input;
    Vmpsoc_noc_testbench_noc_router_input__pi2*	__PVT__inputs__BRA__4__KET____DOT__u_input;
    Vmpsoc_noc_testbench_noc_router_input__pi2*	__PVT__inputs__BRA__5__KET____DOT__u_input;
    Vmpsoc_noc_testbench_noc_router_input__pi2*	__PVT__inputs__BRA__6__KET____DOT__u_input;
    Vmpsoc_noc_testbench_noc_router_input__pi2*	__PVT__inputs__BRA__7__KET____DOT__u_input;
    Vmpsoc_noc_testbench_noc_router_input__pi2*	__PVT__inputs__BRA__8__KET____DOT__u_input;
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9*	__PVT__outputs__BRA__0__KET____DOT__u_output;
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9*	__PVT__outputs__BRA__1__KET____DOT__u_output;
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9*	__PVT__outputs__BRA__2__KET____DOT__u_output;
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9*	__PVT__outputs__BRA__3__KET____DOT__u_output;
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9*	__PVT__outputs__BRA__4__KET____DOT__u_output;
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9*	__PVT__outputs__BRA__5__KET____DOT__u_output;
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9*	__PVT__outputs__BRA__6__KET____DOT__u_output;
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9*	__PVT__outputs__BRA__7__KET____DOT__u_output;
    Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9*	__PVT__outputs__BRA__8__KET____DOT__u_output;
    
    // PORTS
    VL_IN8(clk,0,0);
    VL_IN8(rst,0,0);
    VL_OUT16(out_last,8,0);
    VL_OUTW(out_valid,80,0,3);
    VL_INW(out_ready,80,0,3);
    VL_IN16(in_last,8,0);
    VL_INW(in_valid,80,0,3);
    VL_OUTW(in_ready,80,0,3);
    VL_INW(ROUTES,143,0,5);
    VL_OUTW(out_flit,305,0,10);
    VL_INW(in_flit,305,0,10);
    
    // LOCAL SIGNALS
    
    // LOCAL VARIABLES
    
    // INTERNAL VARIABLES
  private:
    Vmpsoc_noc_testbench__Syms* __VlSymsp;  // Symbol table
  public:
    
    // PARAMETERS
    
    // CONSTRUCTORS
  private:
    Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10& operator= (const Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10&);  ///< Copying not allowed
    Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10(const Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10&);  ///< Copying not allowed
  public:
    Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10(const char* name="TOP");
    ~Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10();
    
    // API METHODS
    
    // INTERNAL METHODS
    void __Vconfigure(Vmpsoc_noc_testbench__Syms* symsp, bool first);
  private:
    void _ctor_var_reset();
} VL_ATTR_ALIGNED(128);

#endif // guard
