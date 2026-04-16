`include "uvm_macros.svh"
import uvm_pkg::*;

`define PERIOADA_CEASULUI 10


//`define DEBUG      //parametru folosit pentru a activa mesaje pe care noi le stabilim ca ar fi necesare doar la debug

//stabilirea semnificatiei unitatilor de timp din simulator
`timescale 1ns/1ns

//includerea fisierelor la care modulul de top trebuie sa aiba acces

`include "apb_interface_dut.sv"
`include "rename_interface_dut.sv"
`include "test_exemplu.sv"
`include "design.sv"

// Code your testbench here

module top();
   logic        clk;
   wire         rst_n;
  
  //sunt create instantele interfetelor (in acest proiect sunt 2 agenti, deci vor fi 2 interfete); se leaga semnalele interfetelor de semnalele din modulul de top
  /*apb_interface_dut intf_apb();
  assign intf_apb.pclk = clk;
  assign rst_n         = intf_apb.rst_n;
  assign psel          = intf_apb.psel;
  assign penable       = intf_apb.penable;
  assign paddr         = intf_apb.paddr;
  
  rename_interface_dut intf_rename();
  assign intf_rename.clk = clk;
  assign valid = intf_rename.valid;
  assign addr  = intf_rename.addr;
  assign intf_rename.irq   = irq;*/
 


wire buton_pietoni        ; // apasat de pietoni, dupa --N-- sec culoarea se schimba din Rosu in verde pe semafor pieton
wire senzor_lumina        ; // senzor de lumina
wire [5-1:0] ora_curenta  ; // la o anumita ora intra in intermitent

wire        [2-1:0] Paddr;
wire 				       Pwrite;
wire 				       Psel;
wire 				       Penable;
wire        [8-1:0] Pwdata;
wire [8-1:0] Prdata;
wire 		     Pready;
wire 		     Pslverr;
                                      //       10          01
wire [2-1:0] semafor_pietoni; // MSB = red, LSB = green, 1 activ
                                      //    100            010           001
wire [3-1:0] semafor_masini; // MSB red, middle = yellow, LSB = green

wire  [8-1:0] durata_display; //un indicator LED care arata masinilor cat timp mai au de asteptat
wire               lampa         ; //lampa care ilumineaza trecerea de pietoni // activ pe senzor_lumina = 0
wire               buzer_pietoni;  //buzer pentru persoane cu dizabilitati de vedere //activ pe pieton = 1


 Semafor_control #(
//.wait_button       (10), //semafor car green  -> yellow
//.wait_car_yellow   (10), //semafor car yellow -> red
//.wait_car_red      (10), //semafor car red    -> green 
.start_intermitent_mode (3),
.stop_intermitent_mode  (6),
.blink_freq             (24),
.full_cycle             (100) // timp incare butonul nu mai ia valori dupa apasarea butonului si dureaza pana cand rosu se schimba in verde semafor masina
) Semafor_control_i

(
.buton_pietoni(buton_pietoni),         // apasat de pietoni, dupa --N-- sec culoarea se schimba din Rosu in verde pe semafor pieton
.senzor_lumina(senzor_lumina),         // senzor de lumina
.ora_curenta(ora_curenta),   // la o anumita ora intra in intermitent

.Paddr(Paddr),
.Pwrite(Pwrite),
.Psel(Psel),
.Penable(Penable),
.Pwdata(Pwdata),
.Prdata(Prdata),
.Pready(Pready),
.Pslverr(Pslverr),
                                  //       10          01
.semafor_pietoni(semafor_pietoni), // MSB = red, LSB = green, 1 activ
                                 //    100            010           001
.semafor_masini(semafor_masini), // MSB red, middle = yellow, LSB = green

.durata_display(durata_display), //un indicator LED care arata masinilor cat timp mai au de asteptat
.lampa         (lampa), //lampa care ilumineaza trecerea de pietoni // activ pe senzor_lumina = 0
.buzer_pietoni(buzer_pietoni)  //buzer pentru persoane cu dizabilitati de vedere //activ pe pieton = 1);
);
 initial begin
    //cele 2 linii de mai jos permit vizualizarea formelor de unda (pentru a vizualiza formele de unda trebuie bifata si optiunea "Open EPWave after run" din sectiunea "Tools & Simulators" aflata in stanga paginii)
    $dumpfile("dump.vcd");
    $dumpvars;
    //se genereaza ceasul
	clk = 1;
	forever begin 
    #(`PERIOADA_CEASULUI/2)  
    clk <= ~clk;
  end
	end
  
   initial
  	begin
      //se salveaza instantele interfetelor in baza de date UVM
      uvm_config_db#(virtual apb_interface_dut)::set(null, "*", "apb_interface_dut", intf_apb);
      uvm_config_db#(virtual rename_interface_dut)::set(null, "*", "rename_interface_dut", intf_rename);
      //se ruleaza testul dorit
      run_test("test_exemplu");
  	end

  // se instantiaza DUT-ul, facandu-se legaturile intre semnalele din modulul de top si semnalele acestuia
  my_dut DUT(
	.pclk_i                  (clk    ),
	.rst_n_i                 (rst_n   ),
	.psel_i                  (psel    ),
	.penable_i               (penable ),
  .paddr_i                 (paddr   ),
  .valid_i                 (valid   ),
  .addr_i                  (addr    ), 
  .irq_o                   (irq     )
);

endmodule