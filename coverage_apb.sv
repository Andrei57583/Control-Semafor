`ifndef __apb_coverage_collector
`define __apb_coverage_collector

class coverage_apb extends uvm_component;

  `uvm_component_utils(coverage_apb)

  // pointer la monitorul care furnizeaza date
  monitor_apb p_monitor;

  // covergroup
  covergroup stari_apb_cg;
    option.per_instance = 1;

    coverpoint p_monitor.starea_preluata_a_apb.address {
      bins min_addr    = {0};
      bins mid_addr    = {[1:2]};
      bins max_addr    = {3};
      bins others      = default;
    }

    coverpoint p_monitor.starea_preluata_a_apb.data {
      bins zero        = {0};
      bins low         = {[1:50]};
      bins mid         = {[51:200]};
      bins high        = {[201:255]};
    }

    coverpoint p_monitor.starea_preluata_a_apb.rd_wr {
      bins read        = {1};
      bins write       = {0};
    }

    coverpoint p_monitor.starea_preluata_a_apb.delay_trans {
      bins short       = {[0:3]};
      bins mediu      = {[4:7]};
      bins long        = {[8:10]};
    }

  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);

    // legatura cu monitorul
    $cast(p_monitor, parent);

    // creare covergroup
    stari_apb_cg = new();
  endfunction

  // functia care preia datele de la monitor si esantioneaza
  function void sample();
    stari_apb_cg.sample();
  endfunction

endclass

`endif