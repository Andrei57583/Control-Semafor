// Author: Dennis Muturi

`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __rename_transaction
`define __rename_transaction

// A transaction contains all the data transferred on an interface at a specific moment
class tranzactie_rename extends uvm_sequence_item;
  
  `uvm_object_utils(tranzactie_rename) // Register the transaction in the UVM factory
  
  rand bit[2:0] addr;
       bit      irq; // Output field, so it is not randomized
  
  function new(string name = "element_secventaa"); // Constructor called when a transaction object is created
    super.new(name);  
    addr = 0;
    irq  = 0;
  endfunction
  
  function void afiseaza_informatia_tranzactiei(); // Function used to display transaction information
    $display("Address value: %0h, IRQ: %b", addr, irq);
  endfunction
  
  function tranzactie_rename copy();
    copy = new(); // Create a new transaction object
    copy.addr = this.addr;
    copy.irq  = this.irq;
    return copy;
  endfunction

endclass

`endif