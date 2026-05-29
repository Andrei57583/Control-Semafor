// Author: Florea Andrei

`ifndef __apb_intf
`define __apb_intf

interface apb_interface_dut;

  logic        pclk; // APB clock signal
  logic        rst_n; // Active-low reset signal

  logic [7:0]  paddr; // APB address bus
  logic [7:0]  pwdata; // APB write data bus
  logic [7:0]  prdata; // APB read data bus
  logic        pwrite; // Write control signal: 1 = WRITE, 0 = READ

  logic        psel; // Slave select signal
  logic        penable; // Enable signal used during the ACCESS phase

  logic        pready; // Slave ready signal, used to complete the transfer
  logic        pslverr; // Slave error signal, used to indicate an invalid transfer
  
  import uvm_pkg::*;
     
  
  // APB assertions are used to check protocol correctness during simulation

  property p_enable_after_psel;
    @(posedge pclk) disable iff (!rst_n)
      $rose(psel) |=> penable; // PENABLE must be asserted one cycle after PSEL rises
  endproperty

  asert_p_enable_after_psel: assert property (p_enable_after_psel)
    else $error("APB: PENABLE does not come after PSEL");

  cover_p_enable_after_psel: cover property (p_enable_after_psel); // Cover that this protocol transition happened at least once


  property p_enable_implies_psel;
    @(posedge pclk) disable iff (!rst_n)
      penable |-> psel; // PENABLE is only valid when PSEL is active
  endproperty

  asert_p_enable_implies_psel: assert property (p_enable_implies_psel)
    else $error("APB: PENABLE active without PSEL");


  property p_psel_stable_in_access;
    @(posedge pclk) disable iff (!rst_n)
      (psel && penable) |-> psel; // PSEL must stay active during the ACCESS phase
  endproperty

  asert_p_psel_stable_in_access: assert property (p_psel_stable_in_access)
    else $error("APB: PSEL was deasserted during ACCESS");


  property p_signals_stable;
    @(posedge pclk) disable iff (!rst_n)
      (psel && penable && !pready) |->
        ($stable(paddr) && $stable(pwrite) && $stable(pwdata)); // Control signals must stay stable while the slave is not ready
  endproperty

  asert_p_signals_stable: assert property (p_signals_stable)
    else $error("APB: signals changed during ACCESS");


  property p_valid_setup;
    @(posedge pclk) disable iff (!rst_n)
      $rose(psel) |-> (!$isunknown(paddr) && !$isunknown(pwrite)); // Address and transfer type must be valid in SETUP phase
  endproperty

  asert_p_valid_setup: assert property (p_valid_setup)
    else $error("APB: invalid signals during SETUP");


  property p_write_has_data;
    @(posedge pclk) disable iff (!rst_n)
      (psel && pwrite) |-> !$isunknown(pwdata); // WRITE transfers must have valid PWDATA
  endproperty

  asert_p_write_has_data: assert property (p_write_has_data)
    else $error("APB: WRITE transfer without valid data");


  property p_read_data_valid;
    @(posedge pclk) disable iff (!rst_n)
      (psel && penable && pready && !pwrite) |-> !$isunknown(prdata); // Completed READ transfers must provide valid PRDATA
  endproperty

  asert_p_read_data_valid: assert property (p_read_data_valid)
    else $error("APB: invalid PRDATA during READ");


  property p_pready_in_access;
    @(posedge pclk) disable iff (!rst_n)
      pready |-> penable; // PREADY must be active only during the ACCESS phase
  endproperty

  asert_p_pready_in_access: assert property (p_pready_in_access)
    else $error("APB: PREADY active outside ACCESS");


  property p_pslverr_valid;
    @(posedge pclk) disable iff (!rst_n)
      pslverr |-> (psel && penable && pready); // PSLVERR is valid only at the end of a transfer
  endproperty

  asert_p_pslverr_valid: assert property (p_pslverr_valid)
    else $error("APB: PSLVERR active at an invalid time");


  property p_two_cycle_transfer;
    @(posedge pclk) disable iff (!rst_n)
      $rose(psel) |-> ##1 penable; // An APB transfer must have SETUP followed by ACCESS
  endproperty

  asert_p_two_cycle_transfer: assert property (p_two_cycle_transfer)
    else $error("APB: transfer is too short");
  
      
endinterface

`endif