// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmpsoc_noc_testbench.h for the primary calling header

#include "Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9.h" // For This
#include "Vmpsoc_noc_testbench__Syms.h"


//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9) {
    // Reset internal values
    // Reset structure values
    _ctor_var_reset();
}

void Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9::__Vconfigure(Vmpsoc_noc_testbench__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9::~Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9() {
}

//--------------------
// Internal Methods

void Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+              Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9::_ctor_var_reset\n"); );
    // Body
    clk = VL_RAND_RESET_I(1);
    rst = VL_RAND_RESET_I(1);
    VL_RAND_RESET_W(306,in_flit);
    in_last = VL_RAND_RESET_I(9);
    in_valid = VL_RAND_RESET_I(9);
    in_ready = VL_RAND_RESET_I(9);
    out_flit = VL_RAND_RESET_Q(34);
    out_last = VL_RAND_RESET_I(1);
    out_valid = VL_RAND_RESET_I(9);
    out_ready = VL_RAND_RESET_I(9);
}
