`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_coverage_collector
`define __apb_coverage_collector

typedef class monitor_apb; // Forward declaration because coverage uses a pointer to the monitor

class coverage_apb extends uvm_component;

  `uvm_component_utils(coverage_apb) // Register the coverage collector in the UVM factory

  monitor_apb p_monitor; // Pointer to the monitor that provides the sampled transaction data

  covergroup stari_apb_cg; // Covergroup used to collect functional coverage for APB transactions
    option.per_instance = 1; // Keep separate coverage information for each instance

    coverpoint p_monitor.starea_preluata_a_apb.address { // Cover the accessed APB address
      bins addr_0      = {0};       // Address 0
      bins addr_1_2    = {[1:2]};   // Addresses 1 and 2
      bins addr_3      = {3};       // Address 3
      bins addr_others = default;   // Any other address value
    }

    coverpoint p_monitor.starea_preluata_a_apb.data { // Cover the APB data value
      bins data_zero = {0};          // Data value equal to zero
      bins data_low  = {[1:50]};     // Low data values
      bins data_mid  = {[51:200]};   // Medium data values
      bins data_high = {[201:255]};  // High data values
    }

    coverpoint p_monitor.starea_preluata_a_apb.rd_wr { // Cover the transaction type
      bins tr_read  = {1}; // READ transaction
      bins tr_write = {0}; // WRITE transaction
    }

    coverpoint p_monitor.starea_preluata_a_apb.delay_trans { // Cover the delay before the transaction
      bins delay_short = {[0:3]};  // Short delay
      bins delay_mid   = {[4:7]};  // Medium delay
      bins delay_long  = {[8:10]}; // Long delay
    }

  endgroup

  function new(string name = "coverage_apb", uvm_component parent = null);
    super.new(name, parent); // Call the parent constructor

    $cast(p_monitor, parent); // The parent should be the APB monitor

    stari_apb_cg = new(); // Create the covergroup
  endfunction

  function void sample();
    stari_apb_cg.sample(); // Sample the current transaction values
  endfunction

endclass

`endif