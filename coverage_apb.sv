`ifndef __apb_coverage_collector
`define __apb_coverage_collector

class coverage_apb extends uvm_component;

  `uvm_component_utils(coverage_apb) // Register the coverage collector in the UVM factory

  monitor_apb p_monitor; // Pointer to the monitor that provides the sampled transaction data

  covergroup stari_apb_cg; // Covergroup used to collect functional coverage for APB transactions
    option.per_instance = 1; // Keep separate coverage information for each instance

    coverpoint p_monitor.starea_preluata_a_apb.address { // Cover the accessed APB address
      bins min_addr    = {0}; // Address 0
      bins mid_addr    = {[1:2]}; // Addresses 1 and 2
      bins max_addr    = {3}; // Address 3
      bins others      = default; // Any other address value
    }

    coverpoint p_monitor.starea_preluata_a_apb.data { // Cover the APB data value
      bins zero        = {0}; // Data value equal to zero
      bins low         = {[1:50]}; // Low data values
      bins mid         = {[51:200]}; // Medium data values
      bins high        = {[201:255]}; // High data values
    }

    coverpoint p_monitor.starea_preluata_a_apb.rd_wr { // Cover the transaction type
      bins read        = {1}; // READ transaction
      bins write       = {0}; // WRITE transaction
    }

    coverpoint p_monitor.starea_preluata_a_apb.delay_trans { // Cover the delay before the transaction
      bins short       = {[0:3]}; // Short delay
      bins medium      = {[4:7]}; // Medium delay
      bins long        = {[8:10]}; // Long delay
    }

  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent); // Call the parent constructor

    $cast(p_monitor, parent); // Cast the parent component to the monitor pointer

    stari_apb_cg = new(); // Create the APB covergroup
  endfunction

  function void sample();
    stari_apb_cg.sample(); // Sample the current transaction values from the monitor
  endfunction

endclass

`endif