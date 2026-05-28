`ifndef __input_apb_sequence
`define __input_apb_sequence

class secventa_apb extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(secventa_apb) // Register the fixed APB sequence in the UVM factory

  function new(string name = "secventa_apb");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info("SECVENTA_APB",
              "The fixed APB verification scenario has started",
              UVM_NONE)

    req = tranzactie_apb::type_id::create("write_green"); // Create WRITE transaction for the green time register

    start_item(req);

    req.address     = 0; // Address 0 corresponds to the green time register
    req.data        = 8'h11; // Value written into the register
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 2; // Delay before sending the transaction

    finish_item(req);


    req = tranzactie_apb::type_id::create("write_yellow"); // Create WRITE transaction for the yellow time register

    start_item(req);

    req.address     = 1; // Address 1 corresponds to the yellow time register
    req.data        = 8'h22; // Value written into the register
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 3; // Delay before sending the transaction

    finish_item(req);


    req = tranzactie_apb::type_id::create("write_red"); // Create WRITE transaction for the red time register

    start_item(req);

    req.address     = 2; // Address 2 corresponds to the red time register
    req.data        = 8'h33; // Value written into the register
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 1; // Delay before sending the transaction

    finish_item(req);


    req = tranzactie_apb::type_id::create("read_green"); // Create READ transaction for the green time register

    start_item(req);

    req.address     = 0; // Read back the value from address 0
    req.data        = 8'h00; // Data is not used for READ transactions
    req.rd_wr       = 1; // READ operation
    req.delay_trans = 1; // Delay before sending the transaction

    finish_item(req);


    req = tranzactie_apb::type_id::create("read_yellow"); // Create READ transaction for the yellow time register

    start_item(req);

    req.address     = 1; // Read back the value from address 1
    req.data        = 8'h00; // Data is not used for READ transactions
    req.rd_wr       = 1; // READ operation
    req.delay_trans = 1; // Delay before sending the transaction

    finish_item(req);


    req = tranzactie_apb::type_id::create("read_red"); // Create READ transaction for the red time register

    start_item(req);

    req.address     = 2; // Read back the value from address 2
    req.data        = 8'h00; // Data is not used for READ transactions
    req.rd_wr       = 1; // READ operation
    req.delay_trans = 1; // Delay before sending the transaction

    finish_item(req);


    req = tranzactie_apb::type_id::create("invalid_address"); // Create transaction for an invalid APB address

    start_item(req);

    req.address     = 3; // Address 3 is used to check invalid address behavior
    req.data        = 8'h44; // Test value used for the invalid access
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 4; // Delay before sending the transaction

    finish_item(req);


    `uvm_info("SECVENTA_APB",
              "The fixed APB verification scenario was sent",
              UVM_NONE)

  endtask

endclass

`endif