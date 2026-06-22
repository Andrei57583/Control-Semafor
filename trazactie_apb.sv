`ifndef __TRANZACTIE_APB
`define __TRANZACTIE_APB

// We extend from uvm_sequence_item because this is a data packet, not a component
class tranzactie_apb extends uvm_sequence_item;

  // 1. Declare the APB Bus Signals as random variables
  rand bit [1:0] address;     // 2-bit address (covers addresses 0, 1, 2, 3)
  rand bit [7:0] data;        // 8-bit data payload
  rand bit       rd_wr;       // 0 = WRITE, 1 = READ

  // 2. Control Variable for Timing Glitches / Stress Testing
  rand int unsigned delay_trans; 

  // Register the properties with the UVM factory for automatic printing and copying
  `uvm_object_utils_begin(tranzactie_apb)
    `uvm_field_int(address,     UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(data,        UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(rd_wr,       UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(delay_trans, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end

  // Standard UVM Object Constructor
  function new(string name = "tranzactie_apb");
    super.new(name);
  endfunction

  // 3. Base Constraints (Can be overridden by sequences using 'soft')
  constraint default_delay_c {
    soft delay_trans inside {[1:5]}; // By default, wait 1 to 5 cycles between transfers
  }

  constraint valid_address_c {
    address inside {[0:2]}; // Limits to your traffic light's 3 registers
  }

  // Helper function to easily print transaction details in terminal
  virtual function void afiseaza_informatia_tranzactiei();
    string tip_operatie;
    tip_operatie = (rd_wr == 0) ? "SCRIERE" : "CITIRE";
    
    $display("[APB_TRANS] %s | Adresa: 0x%0h | Date: 0x%0h | Delay: %0d cicluri", 
             tip_operatie, address, data, delay_trans);
  endfunction

endclass

`endif