// Autor: Dennis Muturi
`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __iesire_transaction
`define __iesire_transaction

// O tranzactie_iesire reprezinta toate datele transmise la un moment dat pe o interfata

class tranzactie_iesire extends uvm_sequence_item;

    //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(tranzactie_iesire)

  bit [2:0] masini;    // Masini: Red[2], Yellow[1], Green[0]
  bit [1:0] pietoni;   // Pietoni: Red[1], Green[0]
  bit       buzzer;    // Beeping sound
  bit       lampa;     // Acknowledgement Light


//constructorul clasei; această funcție este apelată când se creează un obiect al clasei "tranzactie"

  function new(string name = "element_secventaa");
    super.new(name);

    masini  = 0;
    pietoni = 0;
    buzzer  = 0;
    lampa   = 0;

  endfunction

     
  //functie de afisare a unei tranzactii
  function void afiseaza_informatia_tranzactiei();

    $display("--- STARE SEMAFOR ---");
    $display("Masini: %b | Pietoni: %b | Buzzer: %b | Lampa: %b", masini, pietoni, buzzer, lampa);

  endfunction

  function tranzactie_iesire copy();
    tranzactie_iesire cpy = new();
    cpy.masini  = this.masini;
    cpy.pietoni = this.pietoni;
    cpy.buzzer  = this.buzzer;
    cpy.lampa   = this.lampa;
    return cpy;
    
  endfunction

endclass

`endif