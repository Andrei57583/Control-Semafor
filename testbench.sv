`include "uvm_macros.svh"
import uvm_pkg::*;

`define PERIOADA_CEASULUI 10


//`define DEBUG      //parametru folosit pentru a activa mesaje pe care noi le stabilim ca ar fi necesare doar la debug

//stabilirea semnificatiei unitatilor de timp din simulator
`timescale 1ns/1ns

//includerea fisierelor la care modulul de top trebuie sa aiba acces

`include "apb_interface_dut.sv"
`include "input_interface_dut.sv"
`include "output_interface_dut.sv"
//`include "test_exemplu.sv"
//`include "test_buton_pietoni.sv"
//`include "test_intermitent.sv"
`include "test_senzor_lumina.sv"
`include "design.sv"

// Code your testbench here

module top();
  //semnale generale
  logic        pclk; 
  wire        rst_n;
  // semnale de date
  wire [7:0]  paddr;
  wire [7:0]  pwdata;
  wire [7:0]  prdata;
  wire        pwrite;

  // semnale de protocol  
  wire        psel;
  wire        penable;

  // semnalele date de slave
  wire        pready;
  wire        pslverr;

  // Iesiri DUT
  wire  [2:0] semafor_masini;   // [2]=rosu, [1]=galben, [0]=verde
  wire  [1:0] semafor_pietoni;  // [1]=rosu, [0]=verde
  wire        lampa;
  wire        buzzer_pietoni;

  // Intrari externe
  wire        buton_pietoni;   // cerere trecere
  wire        senzor_lumina;   // 1 = intuneric, 0 = lumina
  wire  [4:0] ora_curenta;   

  //sunt create instantele interfetelor (in acest proiect sunt 2 agenti, deci vor fi 2 interfete); se leaga semnalele interfetelor de semnalele din modulul de top
  apb_interface_dut intf_apb();
  assign intf_apb.pclk = pclk;
  assign rst_n         = intf_apb.rst_n;
  assign psel          = intf_apb.psel;
  assign penable       = intf_apb.penable;
  assign paddr         = intf_apb.paddr;
  assign pwdata        = intf_apb.pwdata;
  assign intf_apb.prdata = prdata;
  assign pwrite = intf_apb.pwrite;
  assign intf_apb.pready = pready;
  assign intf_apb.pslverr =pslverr;
  
  input_interface_dut intf_input();
  assign intf_input.clk = pclk;
  assign intf_input.reset = rst_n;
  assign buton_pietoni = intf_input.buton_pietoni;
  assign senzor_lumina  = intf_input.senzor_lumina;
  assign ora_curenta   = intf_input.ora_curenta;

  output_interface_dut intf_output();
  assign intf_output.clk = pclk;
  assign intf_output.reset = rst_n;
  assign intf_output.semafor_masini = semafor_masini;
  assign intf_output.semafor_pietoni = semafor_pietoni;
  assign intf_output.lampa = lampa;
  assign intf_output.buzzer_pietoni = buzzer_pietoni;
  
  initial begin
    //cele 2 linii de mai jos permit vizualizarea formelor de unda (pentru a vizualiza formele de unda trebuie bifata si optiunea "Open EPWave after run" din sectiunea "Tools & Simulators" aflata in stanga paginii)
    $dumpfile("dump.vcd");
    $dumpvars;
    //se genereaza ceasul
	pclk = 1;
	forever begin 
    #(`PERIOADA_CEASULUI/2)  
    pclk <= ~pclk;
  end
	end
  
   initial
  	begin
      //se salveaza instantele interfetelor in baza de date UVM
      uvm_config_db#(virtual apb_interface_dut)::set(null, "*", "apb_interface_dut", intf_apb);
      uvm_config_db#(virtual input_interface_dut)::set(null, "*", "input_interface_dut", intf_input);
      uvm_config_db#(virtual output_interface_dut)::set(null, "*", "output_interface_dut", intf_output);

      //se ruleaza testul dorit
    //  run_test("test_buton_pietoni");
    //  run_test("test_intermitent");
      run_test("test_senzor_lumina");

  	end

  // se instantiaza DUT-ul, facandu-se legaturile intre semnalele din modulul de top si semnalele acestuia
    Semafor_control my_dut(
	
  .clk (pclk),
  .rst_n(rst_n),
  .Paddr(paddr),
  .Pwdata(pwdata),
  .Prdata(prdata),
  .Pwrite(pwrite),

  .Psel(psel),
  .Penable(penable),

  .Pready(pready),
  .Pslverr(pslverr),

  .semafor_masini(semafor_masini),   // [2]=rosu, [1]=galben, [0]=verde
  .semafor_pietoni(semafor_pietoni),  // [1]=rosu, [0]=verde
  .lampa(lampa),
  .buzzer_pietoni(buzzer_pietoni),

  .buton_pietoni (buton_pietoni),  // cerere trecere
  .senzor_lumina (senzor_lumina),  // 1 = intuneric, 0 = lumina
  .ora_curenta ( ora_curenta)
); 

endmodule