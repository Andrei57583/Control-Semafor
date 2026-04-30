`ifndef __apb_transaction
`define __apb_transaction

class tranzactie_apb extends uvm_sequence_item;
  
  `uvm_object_utils(tranzactie_apb)
  
  rand byte data;
  rand bit [1:0] address;
  rand bit rd_wr;        // 0 = write, 1 = read
  rand int delay_trans;

  constraint delay_c {soft delay_trans inside {[0:10]}; }

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
    copy = new();
    copy.data        = this.data;
    copy.address     = this.address;
    copy.rd_wr       = this.rd_wr;
    copy.delay_trans = this.delay_trans;
    return copy;
  endfunction

endclass

`endif