`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __intrare_sequence_current_hour
`define __intrare_sequence_current_hour

//se declara o clasa care genereaza o secventa de date
class secventa_intrare_ora_actuala extends uvm_sequence #(tranzactie_intrare);
  
  //noul tip de data (secventa) se adauga la baza de date UVM
  `uvm_object_utils(secventa_intrare_ora_actuala)
  
  //se declara dimensiunea sirului
  rand int numarul_de_tranzactii;
  
  //se constrange dimensiunea sirului de tranzactii intr-un interval ales de noi
  constraint marimea_sirului_c{
    //constrangerile declarate cu cuvantul cheie "soft" se pot suprascrie ulterior
    soft numarul_de_tranzactii inside {[10:10+5]};
  }
  
  function new(string name="secventa_intrare_ora_actuala");
    super.new(name);
  endfunction
    
  function void post_randomize();
    $display("secventa_intrare_ora_actuala: Marimea sirului de tranzactii=%0d", numarul_de_tranzactii);
   endfunction
  
  virtual task body();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;
    `uvm_info("secventa_intrare_ora_actuala", $sformatf("A inceput secventa cu dimensiunea de %-2d elemente", numarul_de_tranzactii), UVM_NONE)
    
   parsing_day(1);
    `uvm_info("secventa_intrare_ora_actuala", $sformatf("S-au generat toate cele %0d tranzactii", numarul_de_tranzactii), UVM_LOW)
  endtask

 task parsing_day(int durata_ora);
  for (int i=0;i<24;i++)begin
    button_sensor_hour(0, 0, i);
    for (int j= 0;j<durata_ora;j++)
      nop(0,i);
  end
  endtask

  task press_release_button();
  button_sensor_hour(1, 0, 12);
  button_sensor_hour(0, 0, 12);
  endtask

   task nop(bit senzor, bit[4:0] ora );
      req = tranzactie_intrare::type_id::create("req");
      
      //se incepe crearea tranzactiei
      start_item(req);
      //se genereaza random valori in intervalele de interes pt fiecare intrare 
      assert (req.randomize() with {
        buton_pietoni == 0; 
        senzor_lumina == senzor; 
        ora_curenta == ora;
      });
      `ifdef DEBUG
      `uvm_info("secventa_intrare_ora_actuala", $sformatf("La timpul %0t s-a generat elementul %0d cu informatiile:\n ", $time, i), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif;
      
      //s-a terminat crearea tranzactiei; aceasta poate pleca catre sequencer
      finish_item(req);


  endtask

  task button_sensor_hour(bit buton, bit senzor, bit[4:0] ora );
      req = tranzactie_intrare::type_id::create("req");
      
      //se incepe crearea tranzactiei
      start_item(req);
      //se genereaza random valori in intervalele de interes pt fiecare intrare 
      assert (req.randomize() with {
        buton_pietoni == buton; 
        senzor_lumina == senzor; 
        ora_curenta == ora;
      });
      `ifdef DEBUG
      `uvm_info("secventa_intrare_ora_actuala", $sformatf("La timpul %0t s-a generat elementul %0d cu informatiile:\n ", $time, i), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif;
      
      //s-a terminat crearea tranzactiei; aceasta poate pleca catre sequencer
      finish_item(req);


  endtask
endclass
`endif