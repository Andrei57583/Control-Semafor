//Autor: Florea Andrei

`ifndef __apb_intf
`define __apb_intf

interface apb_interface_dut;
//semnale generale
  logic        pclk; 
  logic        rst_n;
// semnale de date
  logic [7:0]  paddr;
  logic [7:0]  pwdata;
  logic [7:0]  prdata;
  logic        pwrite;

// semnale de protocol  
  logic        psel;
  logic        penable;

// semnalele date de slave
  logic        pready;
  logic        pslverr;
  
  import uvm_pkg::*;
     
  
  //===========================
  // ASERTII APB
  //===========================

  // daca PSEL devine 1 (incepe tranzactia),
  // in urmatorul ciclu trebuie sa apara PENABLE (intram in ACCESS)
  property p_enable_after_psel;
    @(posedge pclk) disable iff (!rst_n)
      $rose(psel) |=> penable;
  endproperty

  asert_p_enable_after_psel: assert property (p_enable_after_psel)
    else $error("APB: PENABLE nu vine dupa PSEL");

  cover_p_enable_after_psel: cover property (p_enable_after_psel); // verificam ca s-a intamplat macar o data


  // daca PENABLE este 1, atunci PSEL trebuie sa fie 1 (suntem in transfer)
  property p_enable_implies_psel;
    @(posedge pclk) disable iff (!rst_n)
      penable |-> psel;
  endproperty

  asert_p_enable_implies_psel: assert property (p_enable_implies_psel)
    else $error("APB: PENABLE activ fara PSEL");


  // in faza de ACCESS (psel=1 si penable=1), PSEL nu trebuie sa cada
  property p_psel_stable_in_access;
    @(posedge pclk) disable iff (!rst_n)
      (psel && penable) |-> psel;
  endproperty

  asert_p_psel_stable_in_access: assert property (p_psel_stable_in_access)
    else $error("APB: PSEL s-a dezactivat in ACCESS");


  // in timpul ACCESS (cat timp PREADY=0), semnalele trebuie sa ramana stabile
  property p_signals_stable;
    @(posedge pclk) disable iff (!rst_n)
      (psel && penable && !pready) |->
        ($stable(paddr) && $stable(pwrite) && $stable(pwdata));
  endproperty

  asert_p_signals_stable: assert property (p_signals_stable)
    else $error("APB: semnalele s-au schimbat in ACCESS");


  // cand incepe tranzactia (PSEL urca), semnalele de control trebuie sa fie valide
  property p_valid_setup;
    @(posedge pclk) disable iff (!rst_n)
      $rose(psel) |-> (!$isunknown(paddr) && !$isunknown(pwrite));
  endproperty

  asert_p_valid_setup: assert property (p_valid_setup)
    else $error("APB: semnale invalide in SETUP");


  // daca este operatie de write, trebuie sa avem date valide pe PWData
  property p_write_has_data;
    @(posedge pclk) disable iff (!rst_n)
      (psel && pwrite) |-> !$isunknown(pwdata);
  endproperty

  asert_p_write_has_data: assert property (p_write_has_data)
    else $error("APB: write fara date valide");


  // daca este operatie de read finalizata, PRDATA trebuie sa fie valid
  property p_read_data_valid;
    @(posedge pclk) disable iff (!rst_n)
      (psel && penable && pready && !pwrite) |-> !$isunknown(prdata);
  endproperty

  asert_p_read_data_valid: assert property (p_read_data_valid)
    else $error("APB: PRDATA invalid la read");


  // PREADY trebuie sa fie activ doar in faza de ACCESS (cand PENABLE=1)
  property p_pready_in_access;
    @(posedge pclk) disable iff (!rst_n)
      pready |-> penable;
  endproperty

  asert_p_pready_in_access: assert property (p_pready_in_access)
    else $error("APB: PREADY activ in afara ACCESS");


  // PSLVERR este valid doar la finalul transferului (psel=1, penable=1, pready=1)
  property p_pslverr_valid;
    @(posedge pclk) disable iff (!rst_n)
      pslverr |-> (psel && penable && pready);
  endproperty

  asert_p_pslverr_valid: assert property (p_pslverr_valid)
    else $error("APB: PSLVERR activ in moment invalid");


  // o tranzactie APB trebuie sa dureze minim 2 cicluri (SETUP + ACCESS)
  property p_two_cycle_transfer;
    @(posedge pclk) disable iff (!rst_n)
      $rose(psel) |-> ##1 penable;
  endproperty

  asert_p_two_cycle_transfer: assert property (p_two_cycle_transfer)
    else $error("APB: tranzactie prea scurta");
  
      
endinterface

`endif