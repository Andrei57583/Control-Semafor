`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __intrare_transaction
`define __intrare_transaction

//o tranzactie este formata din totalitatea datelor transmise la un moment dat pe o interfata
class tranzactie_intrare extends uvm_sequence_item;
  
  //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(tranzactie_intrare)
  
  rand bit        buton_pietoni; //cerere trecere
  rand bit        senzor_lumina; //1 = intuneric, 0 = lumina
  rand bit[4:0]   ora_curenta;   // 0 - 23
  
  
  //constructorul clasei; această funcție este apelată când se creează un obiect al clasei "tranzactie"
  function new(string name = "element_secventaa");//numele dat este ales aleatoriu, si nu mai este folosit in alta parte
    super.new(name);  
  	buton_pietoni = 0;
    senzor_lumina = 0;
    ora_curenta   = 0;
  endfunction
  
  //functie de afisare a unei tranzactii
  function void afiseaza_informatia_tranzactiei();
    $display("Valoarea butonului: %b, Senzor lumina: %b, Ora curenta: %0h", buton_pietoni, senzor_lumina, ora_curenta);
  endfunction
  
  function tranzactie_intrare copy();
    copy = new();
    copy.buton_pietoni = this.buton_pietoni;
    copy.buton_pietoni = this.buton_pietoni;
    copy.ora_curenta = this.ora_curenta;
    return copy;
  endfunction

endclass
`endif