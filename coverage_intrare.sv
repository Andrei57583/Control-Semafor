`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __intrare_coverage_collector
`define __intrare_coverage_collector

//aceasta clasa este folosita pentru a se vedea cate combinatii de intrari au fost trimise DUT-ului; aceasta clasa este doar de model, si probabil va fi modificata, deoarece in general nu ne intereseaza sa obtinem in simulare toate combinatiile posibile de intrari ale unui DUT
class coverage_intrare extends uvm_component;
  
  //componenta se adauga in baza de date
  `uvm_component_utils(coverage_intrare)
  
  //se declara pointerul catre monitorul care da datele asupra carora se vor face masuratorile de coverage
  monitor_intrare p_monitor;
  
  covergroup stari_intrare_cg;
    option.per_instance = 1;
    coverpoint p_monitor.starea_preluata_a_intrare.buton_pietoni{
        bins buton_apasat   = {1};
        bins buton_neapasat = {0};
    }
    coverpoint p_monitor.starea_preluata_a_intrare.senzor_lumina{
        bins senzor_zi     = {0};
        bins senzor_noapte = {1};
    }
    coverpoint p_monitor.starea_preluata_a_intrare.ora_curenta {
      bins ore [24];
    }

  endgroup
  
  //se creeaza grupul de coverage; ATENTIE! Fara functia de mai jos, grupul de coverage nu va putea esantiona niciodata date deoarece pana acum el a fost doar declarat, nu si creat
  function new(string name, uvm_component parent);
    super.new(name, parent);
    $cast(p_monitor, parent);//with the use of $cast, type check will occur during runtime
    stari_intrare_cg = new();
  endfunction
  
endclass


`endif