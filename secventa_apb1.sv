`ifndef __input_apb_sequence
`define __input_apb_sequence

class secventa_apb extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(secventa_apb)

  function new(string name = "secventa_apb");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info("SECVENTA_APB",
              "A inceput scenariul fix de verificare APB",
              UVM_NONE)

    // =====================================================
    // TRANZACTIA 1 - WRITE in registrul pentru verde masini
    // Adresa 0 -> car_green_reg
    // =====================================================
    req = tranzactie_apb::type_id::create("write_green");

    start_item(req);

    req.address     = 0;
    req.data        = 8'h11;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 2;

    finish_item(req);


    // =====================================================
    // TRANZACTIA 2 - WRITE in registrul pentru galben masini
    // Adresa 1 -> car_yellow_reg
    // =====================================================
    req = tranzactie_apb::type_id::create("write_yellow");

    start_item(req);

    req.address     = 1;
    req.data        = 8'h22;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 3;

    finish_item(req);


    // =====================================================
    // TRANZACTIA 3 - WRITE in registrul pentru rosu masini
    // Adresa 2 -> car_red_reg
    // =====================================================
    req = tranzactie_apb::type_id::create("write_red");

    start_item(req);

    req.address     = 2;
    req.data        = 8'h33;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 1;

    finish_item(req);


    // =====================================================
    // TRANZACTIA 4 - READ din registrul pentru verde masini
    // Se verifica daca valoarea scrisa anterior poate fi citita
    // =====================================================
    req = tranzactie_apb::type_id::create("read_green");

    start_item(req);

    req.address     = 0;
    req.data        = 8'h00;
    req.rd_wr       = 1; // READ
    req.delay_trans = 1;

    finish_item(req);


    // =====================================================
    // TRANZACTIA 5 - READ din registrul pentru galben masini
    // =====================================================
    req = tranzactie_apb::type_id::create("read_yellow");

    start_item(req);

    req.address     = 1;
    req.data        = 8'h00;
    req.rd_wr       = 1; // READ
    req.delay_trans = 1;

    finish_item(req);


    // =====================================================
    // TRANZACTIA 6 - READ din registrul pentru rosu masini
    // =====================================================
    req = tranzactie_apb::type_id::create("read_red");

    start_item(req);

    req.address     = 2;
    req.data        = 8'h00;
    req.rd_wr       = 1; // READ
    req.delay_trans = 1;

    finish_item(req);


    // =====================================================
    // TRANZACTIA 7 - Acces la adresa invalida
    // Adresa 3 nu corespunde unui registru valid
    // Aici se verifica semnalizarea erorii PSLVERR
    // =====================================================
    req = tranzactie_apb::type_id::create("invalid_address");

    start_item(req);

    req.address     = 3;
    req.data        = 8'h44;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 4;

    finish_item(req);


    `uvm_info("SECVENTA_APB",
              "Scenariul fix de verificare APB a fost transmis",
              UVM_NONE)

  endtask

endclass

`endif