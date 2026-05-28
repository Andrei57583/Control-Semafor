`ifndef __scoreboard
`define __scoreboard

`include "tranzactie_apb.sv"
import uvm_pkg::*;

class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard) // Register the scoreboard in the UVM factory

  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_la_apb; // Port used to receive APB transactions from the monitor

  bit [7:0] registru_model [0:2]; // Reference model for the valid APB registers

  int nr_write_corecte; // Counter for valid WRITE operations
  int nr_read_corecte; // Counter for correct READ operations
  int nr_read_gresite; // Counter for incorrect READ operations
  int nr_adrese_invalide; // Counter for invalid address accesses

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent); // Call the parent constructor

    port_pentru_datele_de_la_apb = new("port_pentru_datele_de_la_apb", this); // Create the analysis implementation port

    nr_write_corecte   = 0; // Initialize WRITE counter
    nr_read_corecte    = 0; // Initialize correct READ counter
    nr_read_gresite    = 0; // Initialize incorrect READ counter
    nr_adrese_invalide = 0; // Initialize invalid address counter
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); // Call the parent build phase

    registru_model[0] = 8'd0; // Initial expected value for register 0
    registru_model[1] = 8'd0; // Initial expected value for register 1
    registru_model[2] = 8'd0; // Initial expected value for register 2
  endfunction


  function void write_apb(input tranzactie_apb tranzactie_noua_apb); // Called automatically when the monitor sends an APB transaction

    `uvm_info("SCOREBOARD",
      $sformatf("Received transaction: ADDR=%0d DATA=%0d RD_WR=%0b",
      tranzactie_noua_apb.address,
      tranzactie_noua_apb.data,
      tranzactie_noua_apb.rd_wr),
      UVM_LOW)


    if (tranzactie_noua_apb.address <= 2) begin // Check if the accessed address is valid

      if (tranzactie_noua_apb.rd_wr == 0) begin // WRITE transaction

        registru_model[tranzactie_noua_apb.address] = tranzactie_noua_apb.data; // Update the reference model
        nr_write_corecte++; // Count the valid WRITE operation

        `uvm_info("SCOREBOARD",
          $sformatf("Valid WRITE: register[%0d] updated with value %0d",
          tranzactie_noua_apb.address,
          tranzactie_noua_apb.data),
          UVM_LOW)

      end

      else begin // READ transaction

        if (tranzactie_noua_apb.data == registru_model[tranzactie_noua_apb.address]) begin // Compare read data with expected data

          nr_read_corecte++; // Count the correct READ operation

          `uvm_info("SCOREBOARD",
            $sformatf("Correct READ: ADDR=%0d DATA=%0d",
            tranzactie_noua_apb.address,
            tranzactie_noua_apb.data),
            UVM_LOW)

        end
        else begin

          nr_read_gresite++; // Count the incorrect READ operation

          `uvm_error("SCOREBOARD",
            $sformatf("Incorrect READ at ADDR=%0d. Read value=%0d, expected value=%0d",
            tranzactie_noua_apb.address,
            tranzactie_noua_apb.data,
            registru_model[tranzactie_noua_apb.address]))

        end

      end

    end

    else begin // Invalid address access

      nr_adrese_invalide++; // Count the invalid address access

      `uvm_warning("SCOREBOARD",
        $sformatf("Invalid APB address accessed: ADDR=%0d",
        tranzactie_noua_apb.address))

    end

  endfunction


  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase); // Call the parent report phase

    `uvm_info("SCOREBOARD",
      "================ APB SCOREBOARD REPORT ================",
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      $sformatf("Valid WRITE operations observed: %0d", nr_write_corecte),
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      $sformatf("Correct READ operations observed: %0d", nr_read_corecte),
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      $sformatf("Incorrect READ operations observed: %0d", nr_read_gresite),
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      $sformatf("Invalid address accesses observed: %0d", nr_adrese_invalide),
      UVM_NONE)

    `uvm_info("SCOREBOARD",
      "=======================================================",
      UVM_NONE)

  endfunction

endclass

`endif