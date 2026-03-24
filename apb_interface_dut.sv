//Autor: Florea Andrei

`ifndef __apb_intf
`define __apb_intf

interface apb_interface_dut;
//semnale generale
  logic        pclk; 
  logic        rst_n;
// semnale de date
  logic [7:0]  paddr;
  logic [7:0]  pwdata;
  logic [7:0]  prdata;
  logic        pwrite;

// semnale de protocol  
  logic        psel;
  logic        penable;

// semnalele date de slave
  logic        pready;
  logic        pslverr;
  
  import uvm_pkg::*;
      
  //ASERTII
  
  
      	//daca wr_en a fost 1, in urmatorul tact de ceas va fi 0
   property rose_penable_after_rose_psel;
     @(posedge clk) disable iff (reset==0)//daca avem reset, nu se executa asertia
     $rose(psel) |=> $rose(penable);
  endproperty
  
  asertia_rose_penable_after_rose_psel: assert property (rose_penable_after_rose_psel) 
    else $error("INTERFATA_INTRARE: a picat asertia rose_penable_after_rose_psel");
    rose_penable_after_rose_psel_c: cover property (rose_penable_after_rose_psel);//ne asiguram ca proprietatea a fost accesata macar o data
      
   penable |-> psel;
   
   pready |-> !pready;
      
endinterface

`endif