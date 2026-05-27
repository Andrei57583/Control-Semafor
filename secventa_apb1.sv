`ifndef __input_apb_sequence
`define __input_apb_sequence

class secventa_apb extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(secventa_apb)

  function new(string name="secventa_apb");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info("SECVENTA_APB",
              "A inceput secventa fixa APB",
              UVM_NONE)

    // ================= TRANZACTIA 1 =================
    req = tranzactie_apb::type_id::create("req1");

    start_item(req);

    req.address     = 0;
    req.data        = 8'h11;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 2;

    finish_item(req);

    // ================= TRANZACTIA 2 =================
    req = tranzactie_apb::type_id::create("req2");

    start_item(req);

    req.address     = 1;
    req.data        = 8'h22;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 3;

    finish_item(req);

    // ================= TRANZACTIA 3 =================
    req = tranzactie_apb::type_id::create("req3");

    start_item(req);

    req.address     = 2;
    req.data        = 8'h33;
    req.rd_wr       = 1; // READ
    req.delay_trans = 1;

    finish_item(req);

    // ================= TRANZACTIA 4 =================
    req = tranzactie_apb::type_id::create("req4");

    start_item(req);

    req.address     = 3;
    req.data        = 8'h44;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 4;

    finish_item(req);

    `uvm_info("SECVENTA_APB",
              "Secventa fixa a fost transmisa",
              UVM_NONE)

  endtask

endclass

`endif