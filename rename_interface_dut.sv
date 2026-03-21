//Autor: Florea Andrei

`ifndef __rename_intf
`define __rename_intf

interface rename_interface_dut;

  logic        clk;

  // Intrari externe
  logic        buton_pietoni;   // cerere trecere
  logic        senzor_lumina;   // 1 = intuneric, 0 = lumina
  logic  [4:0] ora_curenta;     // 0 - 23

  // Iesiri DUT
  logic  [2:0] semafor_masini;   // [2]=rosu, [1]=galben, [0]=verde
  logic  [1:0] semafor_pietoni;  // [1]=rosu, [0]=verde
  logic        lampa;
  logic        buzzer_pietoni;

  import uvm_pkg::*;
      
  //ASERTII
      
endinterface

`endif