//Autor: Florea Andrei

`ifndef __output_intf
`define __output_intf

interface output_interface_dut;

  logic        clk;
logic reset;

  // Iesiri DUT
  logic  [2:0] semafor_masini;   // [2]=rosu, [1]=galben, [0]=verde
  logic  [1:0] semafor_pietoni;  // [1]=rosu, [0]=verde
  logic        lampa;
  logic        buzzer_pietoni;

  import uvm_pkg::*;
      
  //===========================
  // ASERTII OUTPUT
  //===========================

  // semafor masini: nu pot fi mai multe culori active simultan
  property p_semafor_masini_valid;
    @(posedge clk) disable iff (!reset)
      (semafor_masini == 3'b001) || // verde
      (semafor_masini == 3'b010) || // galben
      (semafor_masini == 3'b100);   // rosu
  endproperty

  asert_p_semafor_masini_valid: assert property (p_semafor_masini_valid)
    else $error("OUTPUT: semafor masini invalid (mai multe culori active)");

  cover_p_semafor_masini_valid: cover property (p_semafor_masini_valid);


  // semafor pietoni: doar rosu sau verde (nu ambele)
  property p_semafor_pietoni_valid;
    @(posedge clk) disable iff (!reset)
      (semafor_pietoni == 2'b01) || // verde
      (semafor_pietoni == 2'b10);   // rosu
  endproperty

  asert_p_semafor_pietoni_valid: assert property (p_semafor_pietoni_valid)
    else $error("OUTPUT: semafor pietoni invalid");


  // NU trebuie sa fie verde simultan la masini si pietoni
  property p_no_conflict;
    @(posedge clk) disable iff (!reset)
      !(semafor_masini == 3'b001 && semafor_pietoni == 2'b01);
  endproperty

  asert_p_no_conflict: assert property (p_no_conflict)
    else $error("OUTPUT: conflict masini verde si pietoni verde");


  // daca pietonii au verde, masinile trebuie sa fie rosu
  property p_pietoni_verde_masini_rosu;
    @(posedge clk) disable iff (!reset)
      (semafor_pietoni == 2'b01) |-> (semafor_masini == 3'b100);
  endproperty

  asert_p_pietoni_verde_masini_rosu: assert property (p_pietoni_verde_masini_rosu)
    else $error("OUTPUT: pietoni verde fara masini rosu");


  // iesirile nu trebuie sa fie X sau Z
  property p_outputs_valid;
    @(posedge clk) disable iff (!reset)
      !$isunknown(semafor_masini) &&
      !$isunknown(semafor_pietoni) &&
      !$isunknown(lampa) &&
      !$isunknown(buzzer_pietoni);
  endproperty

  asert_p_outputs_valid: assert property (p_outputs_valid)
    else $error("OUTPUT: semnale invalide (X/Z)");
      
endinterface

`endif
// buzzer ul la pietoni se aprinde doar cand e verde la pietoni rosu la masini
// lampa se aprinde la senzor 

