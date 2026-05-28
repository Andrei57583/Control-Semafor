`ifndef __directed_apb_sequence
`define __directed_apb_sequence

class secventa_tranzactie_directionata extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(secventa_tranzactie_directionata) // Register the directed APB sequence in the UVM factory

  rand byte data_param;
  rand bit [1:0] address_param;
  rand bit rd_wr_param; // 0 = WRITE, 1 = READ

  function new(string name = "secventa_tranzactie_directionata");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info("SECVENTA_APB_DIRECTED",
      "The directed APB sequence has started",
      UVM_NONE)

    req = tranzactie_apb::type_id::create("req"); // Create one APB transaction

    start_item(req);

    assert(req.randomize() with {
      address == address_param; // Use the address received as parameter
      data    == data_param; // Use the data received as parameter
      rd_wr   == rd_wr_param; // Use the operation type received as parameter
      // delay_trans inside {[0:10]}; // Optional delay between transactions
    });

    `ifdef DEBUG
      `uvm_info("SECVENTA_APB_DIRECTED",
        $sformatf("Directed transaction generated at time %0t", $time),
        UVM_LOW)

      req.afiseaza_informatia_tranzactiei();
    `endif

    finish_item(req);

    `uvm_info("SECVENTA_APB_DIRECTED",
      "The directed APB transaction was generated",
      UVM_LOW)

  endtask

endclass

`endif