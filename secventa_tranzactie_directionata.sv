`ifndef __input_apb_sequence
`define __input_apb_sequence

class secventa_apb extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(secventa_apb)

rand byte data_param;
  rand bit[1:0] address_param;
 rand bit rd_wr_param;        // 0 = write, 1 = read
  

  function new(string name="secventa_apb");
    super.new(name);
  endfunction

/*  function void post_randomize();
    $display("SECVENTA_apb: Marimea sirului de tranzactii=%0d", numarul_de_tranzactii);
  endfunction*/

  virtual task body();
    `uvm_info("SECVENTA_apb", $sformatf("A inceput secventa cu dimensiunea de %-2d elemente", numarul_de_tranzactii), UVM_NONE)

    
      req = tranzactie_apb::type_id::create("req");

      start_item(req);

      // generam random toate campurile tranzactiei
      assert(req.randomize() with {
        address == address_param;       // 4 adrese
        data  ==  data_param ;     // date 8-bit
       rd_wr == rd_wr_param;       // 0=write,1=read
       // delay_trans inside {[0:10]};  // delay intre tranzactii
      });

      `ifdef DEBUG
        `uvm_info("SECVENTA_apb", $sformatf("Tranzactia %0d generata la timpul %0t", i, $time), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif

      finish_item(req);


    `uvm_info("SECVENTA_apb", $sformatf("S-au generat toate cele %0d tranzactii", numarul_de_tranzactii), UVM_LOW)
  endtask

endclass

`endif