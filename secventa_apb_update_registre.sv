`ifndef __secventa_apb_update_registre
`define __secventa_apb_update_registre

class secventa_apb_update_registre extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(secventa_apb_update_registre)

  function new(string name = "secventa_apb_update_registre");
    super.new(name);
  endfunction


  virtual task body();

    `uvm_info("SECVENTA_APB_UPDATE",
              "A inceput scenariul de actualizare a registrelor APB",
              UVM_NONE)

    // =====================================================
    // PASUL 1 - Scriere valori initiale in registre
    // =====================================================

    // WRITE initial in registrul pentru verde masini
    req = tranzactie_apb::type_id::create("write_green_initial");

    start_item(req);

    req.address     = 0;
    req.data        = 8'd10;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 1;

    finish_item(req);


    // WRITE initial in registrul pentru galben masini
    req = tranzactie_apb::type_id::create("write_yellow_initial");

    start_item(req);

    req.address     = 1;
    req.data        = 8'd3;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 1;

    finish_item(req);


    // WRITE initial in registrul pentru rosu masini
    req = tranzactie_apb::type_id::create("write_red_initial");

    start_item(req);

    req.address     = 2;
    req.data        = 8'd8;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 1;

    finish_item(req);


    // =====================================================
    // PASUL 2 - Suprascrierea registrelor cu valori noi
    // =====================================================

    // Se verifica daca registrul poate fi modificat dupa prima scriere
    req = tranzactie_apb::type_id::create("update_green");

    start_item(req);

    req.address     = 0;
    req.data        = 8'd15;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 0;

    finish_item(req);


    req = tranzactie_apb::type_id::create("update_yellow");

    start_item(req);

    req.address     = 1;
    req.data        = 8'd5;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 0;

    finish_item(req);


    req = tranzactie_apb::type_id::create("update_red");

    start_item(req);

    req.address     = 2;
    req.data        = 8'd12;
    req.rd_wr       = 0; // WRITE
    req.delay_trans = 0;

    finish_item(req);


    // =====================================================
    // PASUL 3 - Citirea registrelor dupa actualizare
    // =====================================================

    // Ne asteptam sa citim ultima valoare scrisa: 15
    req = tranzactie_apb::type_id::create("read_green_updated");

    start_item(req);

    req.address     = 0;
    req.data        = 8'd0;
    req.rd_wr       = 1; // READ
    req.delay_trans = 1;

    finish_item(req);


    // Ne asteptam sa citim ultima valoare scrisa: 5
    req = tranzactie_apb::type_id::create("read_yellow_updated");

    start_item(req);

    req.address     = 1;
    req.data        = 8'd0;
    req.rd_wr       = 1; // READ
    req.delay_trans = 1;

    finish_item(req);


    // Ne asteptam sa citim ultima valoare scrisa: 12
    req = tranzactie_apb::type_id::create("read_red_updated");

    start_item(req);

    req.address     = 2;
    req.data        = 8'd0;
    req.rd_wr       = 1; // READ
    req.delay_trans = 1;

    finish_item(req);


    `uvm_info("SECVENTA_APB_UPDATE",
              "Scenariul de actualizare a registrelor APB s-a terminat",
              UVM_NONE)

  endtask

endclass

`endif