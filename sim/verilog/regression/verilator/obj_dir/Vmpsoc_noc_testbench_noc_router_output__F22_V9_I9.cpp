// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmpsoc_noc_testbench.h for the primary calling header

#include "Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9.h" // For This
#include "Vmpsoc_noc_testbench__Syms.h"


//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9) {
    VL_CELL (__PVT__vc_mux__DOT__u_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    // Reset internal values
    // Reset structure values
    _ctor_var_reset();
}

void Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9::__Vconfigure(Vmpsoc_noc_testbench__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9::~Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9() {
}

//--------------------
// Internal Methods

void Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+            Vmpsoc_noc_testbench_noc_router_output__F22_V9_I9::_ctor_var_reset\n"); );
    // Body
    __PVT__clk = VL_RAND_RESET_I(1);
    __PVT__rst = VL_RAND_RESET_I(1);
    VL_RAND_RESET_W(2754,__PVT__in_flit);
    VL_RAND_RESET_W(81,__PVT__in_last);
    VL_RAND_RESET_W(81,__PVT__in_valid);
    VL_RAND_RESET_W(81,__PVT__in_ready);
    __PVT__out_flit = VL_RAND_RESET_Q(34);
    __PVT__out_last = VL_RAND_RESET_I(1);
    __PVT__out_valid = VL_RAND_RESET_I(9);
    __PVT__out_ready = VL_RAND_RESET_I(9);
}
