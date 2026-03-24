//Autor: Florea Andrei

`ifndef __output_intf
`define __output_intf

interface output_interface_dut;

  logic        clk;
logic reset;

  // Iesiri DUT
  logic  [2:0] semafor_masini;   // [2]=rosu, [1]=galben, [0]=verde
  logic  [1:0] semafor_pietoni;  // [1]=rosu, [0]=verde
  logic        lampa;
  logic        buzzer_pietoni;

  import uvm_pkg::*;
      
  //ASERTII
      
endinterface

`endif