// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmpsoc_noc_testbench.h for the primary calling header

#include "Vmpsoc_noc_testbench_noc_router_input__pi2.h" // For This
#include "Vmpsoc_noc_testbench__Syms.h"


//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(Vmpsoc_noc_testbench_noc_router_input__pi2) {
    // Reset internal values
    // Reset structure values
    _ctor_var_reset();
}

void Vmpsoc_noc_testbench_noc_router_input__pi2::__Vconfigure(Vmpsoc_noc_testbench__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Vmpsoc_noc_testbench_noc_router_input__pi2::~Vmpsoc_noc_testbench_noc_router_input__pi2() {
}

//--------------------
// Internal Methods

void Vmpsoc_noc_testbench_noc_router_input__pi2::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+            Vmpsoc_noc_testbench_noc_router_input__pi2::_ctor_var_reset\n"); );
    // Body
    __PVT__clk = VL_RAND_RESET_I(1);
    __PVT__rst = VL_RAND_RESET_I(1);
    VL_RAND_RESET_W(144,__PVT__ROUTES);
    __PVT__in_flit = VL_RAND_RESET_Q(34);
    __PVT__in_last = VL_RAND_RESET_I(1);
    __PVT__in_valid = VL_RAND_RESET_I(9);
    __PVT__in_ready = VL_RAND_RESET_I(9);
    VL_RAND_RESET_W(81,__PVT__out_valid);
    __PVT__out_last = VL_RAND_RESET_I(9);
    VL_RAND_RESET_W(306,__PVT__out_flit);
    VL_RAND_RESET_W(81,__PVT__out_ready);
}
