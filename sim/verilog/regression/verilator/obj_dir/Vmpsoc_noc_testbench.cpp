// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmpsoc_noc_testbench.h for the primary calling header

#include "Vmpsoc_noc_testbench.h" // For This
#include "Vmpsoc_noc_testbench__Syms.h"


//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(Vmpsoc_noc_testbench) {
    Vmpsoc_noc_testbench__Syms* __restrict vlSymsp = __VlSymsp = new Vmpsoc_noc_testbench__Syms(this, name());
    Vmpsoc_noc_testbench* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__0__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__0__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__0__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__0__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_vc_mux, Vmpsoc_noc_testbench_noc_vchannel_mux__F22_C9);
    VL_CELL (__PVT__mpsoc_noc_testbench__DOT__mesh__DOT__tdir__BRA__1__KET____DOT__zdir__BRA__1__KET____DOT__ydir__BRA__1__KET____DOT__xdir__BRA__1__KET____DOT__genblk1__DOT__u_router, Vmpsoc_noc_testbench_noc_router__F22_V9_I9_O9_D10);
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vmpsoc_noc_testbench::__Vconfigure(Vmpsoc_noc_testbench__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Vmpsoc_noc_testbench::~Vmpsoc_noc_testbench() {
    delete __VlSymsp; __VlSymsp=NULL;
}

//--------------------


void Vmpsoc_noc_testbench::eval() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vmpsoc_noc_testbench::eval\n"); );
    Vmpsoc_noc_testbench__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vmpsoc_noc_testbench* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    while (VL_LIKELY(__Vchange)) {
	VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (VL_UNLIKELY(++__VclockLoop > 100)) VL_FATAL_MT(__FILE__,__LINE__,__FILE__,"Verilated model didn't converge");
    }
}

void Vmpsoc_noc_testbench::_eval_initial_loop(Vmpsoc_noc_testbench__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    int __VclockLoop = 0;
    QData __Vchange = 1;
    while (VL_LIKELY(__Vchange)) {
	_eval_settle(vlSymsp);
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (VL_UNLIKELY(++__VclockLoop > 100)) VL_FATAL_MT(__FILE__,__LINE__,__FILE__,"Verilated model didn't DC converge");
    }
}

//--------------------
// Internal Methods

void Vmpsoc_noc_testbench::_eval(Vmpsoc_noc_testbench__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmpsoc_noc_testbench::_eval\n"); );
    Vmpsoc_noc_testbench* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Final
    vlTOPp->__Vclklast__TOP__mpsoc_noc_testbench__DOT__clk 
	= vlTOPp->mpsoc_noc_testbench__DOT__clk;
}

void Vmpsoc_noc_testbench::_eval_initial(Vmpsoc_noc_testbench__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmpsoc_noc_testbench::_eval_initial\n"); );
    Vmpsoc_noc_testbench* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vmpsoc_noc_testbench::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmpsoc_noc_testbench::final\n"); );
    // Variables
    Vmpsoc_noc_testbench__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vmpsoc_noc_testbench* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vmpsoc_noc_testbench::_eval_settle(Vmpsoc_noc_testbench__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmpsoc_noc_testbench::_eval_settle\n"); );
    Vmpsoc_noc_testbench* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

VL_INLINE_OPT QData Vmpsoc_noc_testbench::_change_request(Vmpsoc_noc_testbench__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmpsoc_noc_testbench::_change_request\n"); );
    Vmpsoc_noc_testbench* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vmpsoc_noc_testbench::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmpsoc_noc_testbench::_eval_debug_assertions\n"); );
}
#endif // VL_DEBUG

void Vmpsoc_noc_testbench::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmpsoc_noc_testbench::_ctor_var_reset\n"); );
    // Body
    mpsoc_noc_testbench__DOT__clk = VL_RAND_RESET_I(1);
    __Vclklast__TOP__mpsoc_noc_testbench__DOT__clk = VL_RAND_RESET_I(1);
}
