`ifndef __secventa_apb_update_registre
`define __secventa_apb_update_registre

class secventa_apb_update_registre extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(secventa_apb_update_registre) // Register the update sequence in the UVM factory

  function new(string name = "secventa_apb_update_registre");
    super.new(name);
  endfunction


  virtual task body();

    `uvm_info("SECVENTA_APB_UPDATE",
              "The APB register update scenario has started",
              UVM_NONE)

    req = tranzactie_apb::type_id::create("write_green_initial"); // Initial WRITE for the green time register

    start_item(req);

    req.address     = 0; // Address 0 corresponds to the green time register
    req.data        = 8'd10; // Initial value written to the register
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 1;

    finish_item(req);


    req = tranzactie_apb::type_id::create("write_yellow_initial"); // Initial WRITE for the yellow time register

    start_item(req);

    req.address     = 1; // Address 1 corresponds to the yellow time register
    req.data        = 8'd3; // Initial value written to the register
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 1;

    finish_item(req);


    req = tranzactie_apb::type_id::create("write_red_initial"); // Initial WRITE for the red time register

    start_item(req);

    req.address     = 2; // Address 2 corresponds to the red time register
    req.data        = 8'd8; // Initial value written to the register
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 1;

    finish_item(req);


    req = tranzactie_apb::type_id::create("update_green"); // Update the green time register with a new value

    start_item(req);

    req.address     = 0;
    req.data        = 8'd15; // New value expected to overwrite the previous one
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 0; // Back-to-back transaction

    finish_item(req);


    req = tranzactie_apb::type_id::create("update_yellow"); // Update the yellow time register with a new value

    start_item(req);

    req.address     = 1;
    req.data        = 8'd5; // New value expected to overwrite the previous one
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 0; // Back-to-back transaction

    finish_item(req);


    req = tranzactie_apb::type_id::create("update_red"); // Update the red time register with a new value

    start_item(req);

    req.address     = 2;
    req.data        = 8'd12; // New value expected to overwrite the previous one
    req.rd_wr       = 0; // WRITE operation
    req.delay_trans = 0; // Back-to-back transaction

    finish_item(req);


    req = tranzactie_apb::type_id::create("read_green_updated"); // READ back the updated green time register

    start_item(req);

    req.address     = 0;
    req.data        = 8'd0; // Data is not used for READ transactions
    req.rd_wr       = 1; // READ operation
    req.delay_trans = 1;

    finish_item(req);


    req = tranzactie_apb::type_id::create("read_yellow_updated"); // READ back the updated yellow time register

    start_item(req);

    req.address     = 1;
    req.data        = 8'd0; // Data is not used for READ transactions
    req.rd_wr       = 1; // READ operation
    req.delay_trans = 1;

    finish_item(req);


    req = tranzactie_apb::type_id::create("read_red_updated"); // READ back the updated red time register

    start_item(req);

    req.address     = 2;
    req.data        = 8'd0; // Data is not used for READ transactions
    req.rd_wr       = 1; // READ operation
    req.delay_trans = 1;

    finish_item(req);


    `uvm_info("SECVENTA_APB_UPDATE",
              "The APB register update scenario has finished",
              UVM_NONE)

  endtask

endclass

`endif