`ifndef __apb_transaction
`define __apb_transaction

class tranzactie_apb extends uvm_sequence_item;
  
  `uvm_object_utils(tranzactie_apb) // Register the transaction in the UVM factory
  
  rand byte data; // APB data field
  rand bit [1:0] address; // APB address field
  rand bit rd_wr; // 0 = WRITE, 1 = READ
  rand int delay_trans; // Delay before sending the transaction

  constraint delay_c {
    delay_trans inside {[0:10]}; // Limit the delay between 0 and 10 clock cycles
  }

  function new(string name = "tranzactie_apb");
    super.new(name);

    data = 0;
    address = 0;
    rd_wr = 0;
    delay_trans = 5;
  endfunction
  
  function void afiseaza_informatia_tranzactiei();
    $display("ADDR=%0d DATA=%0d RD_WR=%0b DELAY=%0d",
              address, data, rd_wr, delay_trans);
  endfunction
  
  function tranzactie_apb copy();
    copy = new(); // Create a new transaction object

    copy.data        = this.data;
    copy.address     = this.address;
    copy.rd_wr       = this.rd_wr;
    copy.delay_trans = this.delay_trans;

    return copy; // Return the copied transaction
  endfunction

endclass

`endif