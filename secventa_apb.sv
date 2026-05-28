`ifndef __input_apb_sequence
`define __input_apb_sequence

class secventa_apb extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(secventa_apb) // Register the sequence in the UVM factory

  rand int numarul_de_tranzactii; // Number of APB transactions to be generated

  constraint marimea_sirului_c {
    soft numarul_de_tranzactii inside {[10:15]}; // Default range for the number of transactions
  }

  function new(string name = "secventa_apb");
    super.new(name);
  endfunction

  function void post_randomize();
    $display("SECVENTA_apb: Number of generated transactions = %0d", numarul_de_tranzactii);
  endfunction

  virtual task body();

    `uvm_info("SECVENTA_apb",
      $sformatf("The APB random sequence started with %0d transactions", numarul_de_tranzactii),
      UVM_NONE)

    for (int i = 0; i < numarul_de_tranzactii; i++) begin

      req = tranzactie_apb::type_id::create("req"); // Create a new APB transaction

      start_item(req);

      assert(req.randomize() with {
        address inside {[0:3]}; // Generate valid APB addresses used in this project
        // data inside {[0:255]}; // 8-bit data range
        // rd_wr inside {[0:1]}; // 0 = WRITE, 1 = READ
        // delay_trans inside {[0:10]}; // Delay between transactions
      });

      `ifdef DEBUG
        `uvm_info("SECVENTA_apb",
          $sformatf("Transaction %0d generated at time %0t", i, $time),
          UVM_LOW)

        req.afiseaza_informatia_tranzactiei();
      `endif

      finish_item(req);
    end

    `uvm_info("SECVENTA_apb",
      $sformatf("All %0d APB transactions were generated", numarul_de_tranzactii),
      UVM_LOW)

  endtask

endclass

`endif