`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __intrare_sequence
`define __intrare_sequence

//se declara o clasa care genereaza o secventa de date
class secventa_intrare extends uvm_sequence #(tranzactie_intrare);
  
  //noul tip de data (secventa) se adauga la baza de date UVM
  `uvm_object_utils(secventa_intrare)
  
  //se declara dimensiunea sirului
  rand int numarul_de_tranzactii;
  
  //se constrange dimensiunea sirului de tranzactii intr-un interval ales de noi
  constraint marimea_sirului_c{
    //constrangerile declarate cu cuvantul cheie "soft" se pot suprascrie ulterior
    soft numarul_de_tranzactii inside {[10:10+5]};
  }
  
  function new(string name="secventa_intrare");
    super.new(name);
  endfunction
    
  function void post_randomize();
    $display("SECVENTA_intrare: Marimea sirului de tranzactii=%0d", numarul_de_tranzactii);
   endfunction
  
  virtual task body();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;
    `uvm_info("SECVENTA_intrare", $sformatf("A inceput secventa cu dimensiunea de %-2d elemente", numarul_de_tranzactii), UVM_NONE)
    
    //for (int i=0; i< numarul_de_tranzactii; i++) begin
      
      //se creaza o tranzactie folosindu-se cuvantul cheie "req"
      req = tranzactie_intrare::type_id::create("req");
      
      //se incepe crearea tranzactiei
      start_item(req);
      //se genereaza random valori in intervalele de interes pt fiecare intrare 
      assert (req.randomize() with {buton_pietoni == {0}; senzor_lumina == {1}; ora_curenta == {17}});
      `ifdef DEBUG
      `uvm_info("SECVENTA_intrare", $sformatf("La timpul %0t s-a generat elementul %0d cu informatiile:\n ", $time, i), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif;
      
      //s-a terminat crearea tranzactiei; aceasta poate pleca catre sequencer
      finish_item(req);


           //se creaza o tranzactie folosindu-se cuvantul cheie "req"
      req = tranzactie_intrare::type_id::create("req");
      
      //se incepe crearea tranzactiei
      start_item(req);
      //se genereaza random valori in intervalele de interes pt fiecare intrare 
      assert (req.randomize() with {buton_pietoni == {0}; senzor_lumina == {1}; ora_curenta == {17}});
      `ifdef DEBUG
      `uvm_info("SECVENTA_intrare", $sformatf("La timpul %0t s-a generat elementul %0d cu informatiile:\n ", $time, i), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif;
      
      //s-a terminat crearea tranzactiei; aceasta poate pleca catre sequencer
      finish_item(req);


           //se creaza o tranzactie folosindu-se cuvantul cheie "req"
      req = tranzactie_intrare::type_id::create("req");
      
      //se incepe crearea tranzactiei
      start_item(req);
      //se genereaza random valori in intervalele de interes pt fiecare intrare 
      assert (req.randomize() with {buton_pietoni == {0}; senzor_lumina == {1}; ora_curenta == {17}});
      `ifdef DEBUG
      `uvm_info("SECVENTA_intrare", $sformatf("La timpul %0t s-a generat elementul %0d cu informatiile:\n ", $time, i), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif;
      
      //s-a terminat crearea tranzactiei; aceasta poate pleca catre sequencer
      finish_item(req);
    //end
    `uvm_info("SECVENTA_intrare", $sformatf("S-au generat toate cele %0d tranzactii", numarul_de_tranzactii), UVM_LOW)
  endtask
endclass
`endif