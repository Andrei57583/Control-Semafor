//Autor: Florea Andrei

`ifndef __input_intf
`define __input_intf

interface input_interface_dut;

  logic        clk;
  logic 	   reset;
  // Intrari externe
 
  logic        buton_pietoni;   // cerere trecere
  logic        senzor_lumina;   // 1 = intuneric, 0 = lumina
  logic  [4:0] ora_curenta;     // 0 - 23


  import uvm_pkg::*;
      
  //===========================
  // ASERTII INPUTURI
  //===========================

  // ora_curenta trebuie sa fie intre 0 si 23
  property p_ora_valida;
    @(posedge clk) disable iff (!reset)
      ora_curenta < 24;
  endproperty

  asert_p_ora_valida: assert property (p_ora_valida)
    else $error("INPUT: ora_curenta invalida (>=24)");

  cover_p_ora_valida: cover property (p_ora_valida);


  // butonul nu trebuie sa fie X sau Z (trebuie sa fie 0 sau 1)
  property p_buton_valid;
    @(posedge clk) disable iff (!reset)
      !$isunknown(buton_pietoni);
  endproperty

  asert_p_buton_valid: assert property (p_buton_valid)
    else $error("INPUT: buton_pietoni invalid (X/Z)");


  // senzorul de lumina nu trebuie sa fie X sau Z
  property p_senzor_valid;
    @(posedge clk) disable iff (!reset)
      !$isunknown(senzor_lumina);
  endproperty

  asert_p_senzor_valid: assert property (p_senzor_valid)
    else $error("INPUT: senzor_lumina invalid (X/Z)");


  // ora nu trebuie sa fie X
  property p_ora_not_unknown;
    @(posedge clk) disable iff (!reset)
      !$isunknown(ora_curenta);
  endproperty

  asert_p_ora_not_unknown: assert property (p_ora_not_unknown)
    else $error("INPUT: ora_curenta este necunoscuta");


  // butonul nu trebuie sa oscileze rapid (debounce simplu)
  // daca urca, trebuie sa ramana stabil cel putin 1 ciclu
  property p_buton_stabil;
    @(posedge clk) disable iff (!reset)
      $rose(buton_pietoni) |=> buton_pietoni;
  endproperty

  asert_p_buton_stabil: assert property (p_buton_stabil)
    else $error("INPUT: buton instabil (posibil bounce)");
      
endinterface

`endif

