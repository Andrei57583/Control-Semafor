//Autor: Florea Andrei

`ifndef __apb_intf
`define __apb_intf

interface apb_interface_dut;

  logic        pclk; 
  logic        rst_n;

  logic [7:0]  paddr;
  logic [7:0]  pwdata;
  logic [7:0]  prdata;

  logic        pwrite;
  logic        psel;
  logic        penable;

  logic        pready;
  logic        pslverr;
  
  import uvm_pkg::*;
      
  //ASERTII
      
endinterface

`endif