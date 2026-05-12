`ifndef __input_apb_sequence_light_sensor
`define __input_apb_sequence_light_sensor

class secventa_apb_senzor_lumina extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(secventa_apb_senzor_lumina)

  rand int numarul_de_tranzactii;

  constraint marimea_sirului_c {
    soft numarul_de_tranzactii inside {[10:15]};
  }

  function new(string name="secventa_apb_senzor_lumina");
    super.new(name);
  endfunction

  function void post_randomize();
    $display("secventa_apb_senzor_lumina: Marimea sirului de tranzactii=%0d", numarul_de_tranzactii);
  endfunction

  virtual task body();
    `uvm_info("secventa_apb_senzor_lumina", $sformatf("A inceput secventa cu dimensiunea de %-2d elemente", numarul_de_tranzactii), UVM_NONE)

      register_write(0, 23);
      register_write(1, 10);
      register_write(2, 40);
      register_read(0);
      register_read(1);
      register_read(2);

    `uvm_info("secventa_apb_senzor_lumina", $sformatf("S-au generat toate cele %0d tranzactii", numarul_de_tranzactii), UVM_LOW)
  endtask

  
  virtual task register_write(bit[1:0] address_p, bit [7:0] data_p );
      req = tranzactie_apb::type_id::create("req");

      start_item(req);

      // generam random toate campurile tranzactiei
      assert(req.randomize() with {
        address == address_p;       // 4 adrese
        data  == data_p  ;     // date 8-bit
        rd_wr == 0;
       // delay_trans inside {[0:10]};  // delay intre tranzactii
      });

      `ifdef DEBUG
        `uvm_info("secventa_apb_senzor_lumina", $sformatf("Tranzactia de scriere %0d generata la timpul %0t", i, $time), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif

      finish_item(req);
    

    endtask

      
  virtual task register_read(bit[1:0] address_p);
      req = tranzactie_apb::type_id::create("req");

      start_item(req);

      // generam random toate campurile tranzactiei
      assert(req.randomize() with {
        address == address_p;       // 4 adrese
        rd_wr == 1;
       // delay_trans inside {[0:10]};  // delay intre tranzactii
      });

      `ifdef DEBUG
        `uvm_info("secventa_apb_senzor_lumina", $sformatf("Tranzactia de citire generata la timpul %0t",$time), UVM_LOW)
        req.afiseaza_informatia_tranzactiei();
      `endif

      finish_item(req);
    

    endtask

endclass

`endif