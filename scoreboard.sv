`ifndef __scoreboard
`define __scoreboard


`uvm_analysis_imp_decl(_apb)
`include "tranzactie_apb.sv"
import uvm_pkg::*;

class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)

  // port pentru date APB
  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_la_apb;

  // tranzactii interne
  tranzactie_apb tranzactie_venita_de_la_apb;

  bit enable;

  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
    port_pentru_datele_de_la_apb = new("pentru_datele_de_la_apb", this);
    tranzactie_venita_de_la_apb = tranzactie_apb::type_id::create("tranzactie_venita_de_la_apb");
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // functie apelata de portul de la monitor
  function void write_apb(input tranzactie_apb tranzactie_noua_apb);
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul APB tranzactia cu informatia:"), UVM_LOW)
    tranzactie_noua_apb.afiseaza_informatia_tranzactiei();

    $display("cand s-au primit date de la APB, enable = %0b", enable);

    // copiem tranzactia in obiect intern
    tranzactie_venita_de_la_apb = tranzactie_noua_apb.copy();
  endfunction

endclass

`endif