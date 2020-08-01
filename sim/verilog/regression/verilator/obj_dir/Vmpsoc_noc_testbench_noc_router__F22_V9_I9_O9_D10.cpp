// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmpsoc_noc_testbench.h for the primary calling header

#include "Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10.h" // For This
#include "Vmpsoc_noc_testbench__Syms.h"


//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10) {
    VL_CELL (__PVT__inputs__BRA__0__KET____DOT__u_input, Vmpsoc_noc_testbench_noc_router_input__pi2);
    VL_CELL (__PVT__inputs__BRA__1__KET____DOT__u_input, Vmpsoc_noc_testbench_noc_router_input__pi2);
    VL_CELL (__PVT__inputs__BRA__2__KET____DOT__u_input, Vmpsoc_noc_testbench_noc_router_input__pi2);
    VL_CELL (__PVT__inputs__BRA__3__KET____DOT__u_input, Vmpsoc_noc_testbench_noc_router_input__pi2);
    VL_CELL (__PVT__inputs__BRA__4__KET____DOT__u_input, Vmpsoc_noc_testbench_noc_router_input__pi2);
    VL_CELL (__PVT__inputs__BRA__5__KET____DOT__u_input, Vmpsoc_noc_testbench_noc_router_input__pi2);
    VL_CELL (__PVT__inputs__BRA__6__KET____DOT__u_input, Vmpsoc_noc_testbench_noc_router_input__pi2);
    VL_CELL (__PVT__inputs__BRA__7__KET____DOT__u_input, Vmpsoc_noc_testbench_noc_router_input__pi2);
    VL_CELL (__PVT__inputs__BRA__8__KET____DOT__u_input, Vmpsoc_noc_testbench_noc_router_input__pi2);
    VL_CELL (__PVT__outputs__BRA__0__KET____DOT__u_output, Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9);
    VL_CELL (__PVT__outputs__BRA__1__KET____DOT__u_output, Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9);
    VL_CELL (__PVT__outputs__BRA__2__KET____DOT__u_output, Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9);
    VL_CELL (__PVT__outputs__BRA__3__KET____DOT__u_output, Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9);
    VL_CELL (__PVT__outputs__BRA__4__KET____DOT__u_output, Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9);
    VL_CELL (__PVT__outputs__BRA__5__KET____DOT__u_output, Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9);
    VL_CELL (__PVT__outputs__BRA__6__KET____DOT__u_output, Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9);
    VL_CELL (__PVT__outputs__BRA__7__KET____DOT__u_output, Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9);
    VL_CELL (__PVT__outputs__BRA__8__KET____DOT__u_output, Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9);
    // Reset internal values
    // Reset structure values
    _ctor_var_reset();
}

void Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10::__Vconfigure(Vmpsoc_noc_testbench__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10::~Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10() {
}

//--------------------
// Internal Methods

void Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+          Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10::_ctor_var_reset\n"); );
    // Body
    clk = VL_RAND_RESET_I(1);
    rst = VL_RAND_RESET_I(1);
    VL_RAND_RESET_W(144,ROUTES);
    VL_RAND_RESET_W(306,out_flit);
    out_last = VL_RAND_RESET_I(9);
    VL_RAND_RESET_W(81,out_valid);
    VL_RAND_RESET_W(81,out_ready);
    VL_RAND_RESET_W(306,in_flit);
    in_last = VL_RAND_RESET_I(9);
    VL_RAND_RESET_W(81,in_valid);
    VL_RAND_RESET_W(81,in_ready);
}
