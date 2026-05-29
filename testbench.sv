`include "uvm_macros.svh"
import uvm_pkg::*;

`define PERIOADA_CEASULUI 10


//`define DEBUG      // Parameter used to enable messages that are only needed during debug

// Define the meaning of the time units used by the simulator
`timescale 1ns/1ns

// Include the files that the top module needs to access

`include "apb_interface_dut.sv"
`include "rename_interface_dut.sv"
`include "test_exemplu.sv"
`include "design.sv"

// Code your testbench here

module top();
   logic        clk;
   wire         rst_n;
  
  // Interface instances are created here.
  // In this project there are two agents, so two interfaces are used.
  // The interface signals are connected to the signals from the top module.
  
wire buton_pietoni        ; // Pressed by pedestrians; after --N-- sec the color changes from red to green on the pedestrian traffic light
wire senzor_lumina        ; // Light sensor
wire [5-1:0] ora_curenta  ; // At a certain hour, the system enters blinking mode

wire        [2-1:0] Paddr;
wire 				       Pwrite;
wire 				       Psel;
wire 				       Penable;
wire        [8-1:0] Pwdata;
wire [8-1:0] Prdata;
wire 		     Pready;
wire 		     Pslverr;
                                      //       10          01
wire [2-1:0] semafor_pietoni; // MSB = red, LSB = green, active high
                                      //    100            010           001
wire [3-1:0] semafor_masini; // MSB = red, middle = yellow, LSB = green

wire  [8-1:0] durata_display; // LED indicator that shows drivers how much time they still have to wait
wire               lampa         ; // Lamp that illuminates the pedestrian crossing // active when senzor_lumina = 0
wire               buzer_pietoni;  // Buzzer for visually impaired people // active when pedestrian = 1

apb_interface_dut intf_apb();
  assign intf_apb.pclk = clk;
  assign rst_n         = intf_apb.rst_n;
  assign Psel          = intf_apb.psel;
  assign Penable       = intf_apb.penable;
  assign Paddr         = intf_apb.paddr;
  assign Pwrite		   = intf_apb.pwrite;
  assign Pwdata		   = intf_apb.pwdata;
  assign intf_apb.pready  = Pready;
  assign intf_apb.prdata  = Prdata;
  assign intf_apb.pslverr = Pslverr;
  
  rename_interface_dut intf_rename();
  assign intf_rename.clk = clk;
  assign valid = intf_rename.valid;
  assign addr  = intf_rename.addr;
  assign intf_rename.irq = irq;

 Semafor_control #(
//.wait_button       (10), // Car traffic light green -> yellow
//.wait_car_yellow   (10), // Car traffic light yellow -> red
//.wait_car_red      (10), // Car traffic light red -> green 
.start_intermitent_mode (3),
.stop_intermitent_mode  (6),
.blink_freq             (24),
.full_cycle             (100) // Time during which the button no longer accepts values after being pressed and lasts until the car red light changes to green
) Semafor_control_i

(
.buton_pietoni(buton_pietoni), // Pressed by pedestrians; after --N-- sec the color changes from red to green on the pedestrian traffic light
.senzor_lumina(senzor_lumina), // Light sensor
.ora_curenta(ora_curenta), // At a certain hour, the system enters blinking mode

.Paddr(Paddr),
.Pwrite(Pwrite),
.Psel(Psel),
.Penable(Penable),
.Pwdata(Pwdata),
.Prdata(Prdata),
.Pready(Pready),
.Pslverr(Pslverr),
                                  //       10          01
.semafor_pietoni(semafor_pietoni), // MSB = red, LSB = green, active high
                                 //    100            010           001
.semafor_masini(semafor_masini), // MSB = red, middle = yellow, LSB = green

.durata_display(durata_display), // LED indicator that shows drivers how much time they still have to wait
.lampa         (lampa), // Lamp that illuminates the pedestrian crossing // active when senzor_lumina = 0
.buzer_pietoni(buzer_pietoni)  // Buzzer for visually impaired people // active when pedestrian = 1
);
);

 initial begin
    // The two lines below enable waveform visualization.
    // To view the waveforms, the "Open EPWave after run" option must also be checked in the "Tools & Simulators" section on the left side of the page.
    $dumpfile("dump.vcd");
    $dumpvars;

    // Clock generation
	clk = 1;
	forever begin 
    #(`PERIOADA_CEASULUI/2)  
    clk <= ~clk;
  end
	end
  
   initial
  	begin
      // Store the interface instances in the UVM database
      uvm_config_db#(virtual apb_interface_dut)::set(null, "*", "apb_interface_dut", intf_apb);
      uvm_config_db#(virtual rename_interface_dut)::set(null, "*", "rename_interface_dut", intf_rename);

      // Run the selected test
      run_test("test_exemplu");
  	end

  // Instantiate the DUT and connect the top module signals to the DUT signals
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