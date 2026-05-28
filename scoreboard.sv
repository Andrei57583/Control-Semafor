`ifndef __scoreboard
`define __scoreboard

`include "tranzactie_apb.sv"
import uvm_pkg::*;

class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)

  // port pentru tranzactiile APB venite de la monitor
  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_la_apb;

  // model de referinta pentru registrele APB ale DUT-ului
  bit [7:0] registru_model [0:2];

  // contori pentru statistica
  int nr_write_corecte;
  int nr_read_corecte;
  int nr_read_gresite;
  int nr_adrese_invalide;

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);

    port_pentru_datele_de_la_apb = new("port_pentru_datele_de_la_apb", this);

    nr_write_corecte   = 0;
    nr_read_corecte    = 0;
    nr_read_gresite    = 0;
    nr_adrese_invalide = 0;
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // valori initiale pentru modelul de referinta
    registru_model[0] = 8'd0;
    registru_model[1] = 8'd0;
    registru_model[2] = 8'd0;
  endfunction


  // functie apelata automat cand monitorul trimite o tranzactie APB
  function void write_apb(input tranzactie_apb tranzactie_noua_apb);

    `uvm_info("SCOREBOARD",
      $sformatf("Tranzactie primita: ADDR=%0d DATA=%0d RD_WR=%0b",
      tranzactie_noua_apb.address,
      tranzactie_noua_apb.data,
      tranzactie_noua_apb.rd_wr),
      UVM_LOW)


    // =====================================================
    // Caz 1: adresa valida: 0, 1 sau 2
    // =====================================================
    if (tranzactie_noua_apb.address <= 2) begin

      // ----------------------------
      // WRITE APB
      // rd_wr = 0 inseamna scriere
      // ----------------------------
      if (tranzactie_noua_apb.rd_wr == 0) begin

        registru_model[tranzactie_noua_apb.address] = tranzactie_noua_apb.data;
        nr_write_corecte++;

        `uvm_info("SCOREBOARD",
          $sformatf("WRITE valid: registrul[%0d] a fost actualizat cu valoarea %0d",
          tranzactie_noua_apb.address,
          tranzactie_noua_apb.data),
          UVM_LOW)

      end

      // ----------------------------
      // READ APB
      // rd_wr = 1 inseamna citire
      // ----------------------------
      else begin

        if (tranzactie_noua_apb.data == registru_model[tranzactie_noua_apb.address]) begin

          nr_read_corecte++;

          `uvm_info("SCOREBOARD",
            $sformatf("READ corect: ADDR=%0d DATA=%0d",
            tranzactie_noua_apb.address,
            tranzactie_noua_apb.data),
            UVM_LOW)

        end
        else begin

          nr_read_gresite++;

          `uvm_error("SCOREBOARD",
            $sformatf("READ gresit la ADDR=%0d. Valoare citita=%0d, valoare asteptata=%0d",
            tranzactie_noua_apb.address,
            tranzactie_noua_apb.data,
            registru_model[tranzactie_noua_apb.address]))

        end

      end

    end


    // =====================================================
    // Caz 2: adresa invalida
    // =====================================================
    else begin

      nr_adrese_invalide++;

      `uvm_warning("SCOREBOARD",
        $sformatf("A fost accesata o adresa invalida APB: ADDR=%0d",
        tranzactie_noua_apb.address))

    end

  endfunction


  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("SCOREBOARD",
      "================ RAPORT SCOREBOARD APB ================",
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      $sformatf("WRITE-uri valide observate: %0d", nr_write_corecte),
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      $sformatf("READ-uri corecte observate: %0d", nr_read_corecte),
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      $sformatf("READ-uri gresite observate: %0d", nr_read_gresite),
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      $sformatf("Accesari de adrese invalide observate: %0d", nr_adrese_invalide),
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      "=======================================================",
      UVM_NONE)

  endfunction

endclass

`endif