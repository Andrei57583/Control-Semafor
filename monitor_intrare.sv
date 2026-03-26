`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __intrare_monitor
`define __intrare_monitor
//`include "tranzactie_semafoare.sv"

class monitor_intrare extends uvm_monitor;
  
  //monitorul se adauga in baza de date UVM
  `uvm_component_utils (monitor_intrare) 
  
  //se declara colectorul de coverage care va inregistra valorile semnalelor de pe interfata citite de monitor
  coverage_intrare colector_coverage_intrare; 
  
  //este creat portul prin care monitorul trimite spre exterior (la noi, informatia este accesata de scoreboard), prin intermediul agentului, tranzactiile extrase din traficul de pe interfata
  uvm_analysis_port #(tranzactie_intrare) port_date_monitor_intrare;
  
  //declaratia interfetei de unde monitorul isi colecteaza datele
  //virtual interfata_intrare interfata_monitor_intrare;
  virtual intrare_interface_dut interfata_monitor_intrare;
  
  tranzactie_intrare starea_preluata_a_intrare, aux_tr_intrare;
  
  //constructorul clasei
  function new(string name = "monitor_intrare", uvm_component parent = null);
    
    //prima data se apeleaza constructorul clasei parinte
    super.new(name, parent);
    
    //se creeaza portul prin care monitorul trimite in exterior, prin intermediul agentului, datele pe care le-a cules din traficul de pe interfata
    port_date_monitor_intrare = new("port_date_monitor_intrare",this);
    
    //se creeaza colectorul de coverage (la creare, se apeleaza constructorul colectorului de coverage)
    
    colector_coverage_intrare = coverage_intrare::type_id::create ("colector_coverage_intrare", this);
    
    
    //se creeaza obiectul (tranzactia) in care se vor retine datele colectate de pe interfata la fiecare tact de ceas
    starea_preluata_a_intrare = tranzactie_intrare::type_id::create("date_noi");
    
    aux_tr_intrare = tranzactie_intrare::type_id::create("datee_noi");
  endfunction
  
  
  //se preia din baza de date interfata la care se va conecta monitorul pentru a citi date, si se "leaga" la interfata pe care deja monitorul o contine
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual intrare_interface_dut)::get(this, "", "intrare_interface_dut", interfata_monitor_intrare))
        `uvm_fatal("MONITOR_intrare", "Nu s-a putut accesa interfata monitorului")
  endfunction
        
  
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
    //in faza UVM "connect", se face conexiunea intre pointerul catre monitor din instanta colectorului de coverage a acestui monitor si monitorul insusi 
	colector_coverage_intrare.p_monitor = this;
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      
      //vreau sa citesc semnalul valid_i doar pe fronturile descrescatoare de ceas
      @(negedge interfata_monitor_intrare.clk); 
      //preiau datele de pe interfata de iesire a DUT-ului (interfata_semafoare)
      starea_preluata_a_intrare.buton_pietoni = interfata_monitor_intrare.buton_pietoni;
      starea_preluata_a_intrare.senzor_lumina = interfata_monitor_intrare.senzor_lumina;
      starea_preluata_a_intrare.ora_curenta   = interfata_monitor_intrare.ora_curenta;


      aux_tr_intrare = starea_preluata_a_intrare.copy();//nu vreau sa folosesc pointerul starea_preluata_a_intrare pentru a trimite datele, deoarece continutul acestuia se schimba, iar scoreboardul va citi alte date 
      
       //tranzactia cuprinzand datele culese de pe interfata se pune la dispozitie pe portul monitorului, daca modulul nu este in reset
      port_date_monitor_intrare.write(aux_tr_intrare); 
      `uvm_info("MONITOR_intrare", $sformatf("S-a receptionat tranzactia cu informatiile:"), UVM_NONE)
      aux_tr_intrare.afiseaza_informatia_tranzactiei();
	  
      //se inregistreaza valorile de pe cele doua semnale de iesire
      colector_coverage_intrare.stari_intrare_cg.sample();
      
	  @(negedge interfata_monitor_intrare.clk); //acest wait il adaug deoarece uneori o tranzactie este interpretata a fi doua tranzactii identice back to back (validul este citit ca fiind 1 pe doua fronturi consecutive de ceas); in implementarea curenta nu se poate sa vina doua tranzactii back to back
      
      
    end//forever begin
  endtask
  
  
endclass: monitor_intrare

`endif