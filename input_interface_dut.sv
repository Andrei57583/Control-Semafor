//Autor: Florea Andrei

`ifndef __input_intf
`define __input_intf

interface input_interface_dut;

  logic        clk;
  logic 	   reset;
  // Intrari externe
 
  logic        buton_pietoni;   // cerere trecere
  logic        senzor_lumina;   // 1 = intuneric, 0 = lumina
  logic  [4:0] ora_curenta;     // 0 - 23


  import uvm_pkg::*;
      
  //ASERTII
      
endinterface

`endif