`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __intrare_driver
`define __intrare_driver

//driverul va prelua date de tip "tranzactie", pe care le va trimite DUT-ului, conform protocolul de comunicatie de pe interfata
class driver_agent_intrare extends uvm_driver #(tranzactie_intrare);
  
  //driverul se adauga in baza de date UVM
  `uvm_component_utils (driver_agent_intrare)
  
  //este declarata interfata pe care driverul va trimite datele
  virtual intrare_interface_dut interfata_driverului_pentru_intrare;
  
  //constructorul clasei
  function new(string name = "driver_agent_intrare", uvm_component parent = null);
    //este apelat constructorul clasei parinte
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //este apelata mai intai functia build_phase din clasa parinte
    super.build_phase(phase);
    if (!uvm_config_db#(virtual intrare_interface_dut)::get(this, "", "intrare_interface_dut", interfata_driverului_pentru_intrare))begin
      `uvm_fatal("DRIVER_AGENT_intrare", "Nu s-a putut accesa interfata_intrare")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("DRIVER_AGENT_intrare", $sformatf("Se asteapta o tranzactie de la sequencer"), UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER_AGENT_intrare", $sformatf("S-a primit o tranzactie de la sequencer"), UVM_LOW)
      trimiterea_tranzactiei(req);
      `uvm_info("DRIVER_AGENT_intrare", $sformatf("Tranzactia a fost transmisa pe interfata"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
  
  task trimiterea_tranzactiei(tranzactie_intrare informatia_de_transmis);
    $timeformat(-9, 2, " ns", 20);//cand se va afisa in consola timpul, folosind directiva %t timpul va fi afisat in nanosecunde (-9), cu 2 zecimale, iar dupa valoare se va afisa abrevierea " ns"
    
	 @(posedge interfata_driverului_pentru_intrare.clk);
      interfata_driverului_pentru_intrare.buton_pietoni = informatia_de_transmis.buton_pietoni;
      interfata_driverului_pentru_intrare.senzor_lumina = informatia_de_transmis.senzor_lumina;
      interfata_driverului_pentru_intrare.ora_curenta   = informatia_de_transmis.ora_curenta;

    
    `ifdef DEBUG
    $display("DRIVER_AGENT_intrare, dupa transmisie; [T=%0t]", $realtime);
    `endif;
  endtask
  
endclass
`endif