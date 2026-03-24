`ifndef __apb_monitor
`define __apb_monitor

class monitor_apb extends uvm_monitor;
  
  `uvm_component_utils(monitor_apb)

  coverage_apb colector_coverage_apb;

  uvm_analysis_port #(tranzactie_APB) port_date_monitor_apb;

  virtual apb_interface_dut interfata_monitor_apb;

  tranzactie_APB starea_preluata_a_apb, aux_tr_apb;

  function new(string name = "monitor_apb", uvm_component parent = null);
    super.new(name, parent);

    port_date_monitor_apb = new("port_date_monitor_apb", this);

    colector_coverage_apb = coverage_apb::type_id::create("colector_coverage_apb", this);

    starea_preluata_a_apb = tranzactie_APB::type_id::create("tr_curent");
    aux_tr_apb            = tranzactie_APB::type_id::create("tr_copy");
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", interfata_monitor_apb))
      `uvm_fatal("MONITOR_APB", "Nu s-a putut accesa interfata")
  endfunction


  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    colector_coverage_apb.p_monitor = this;
  endfunction


  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
	while interfata_monitor_apb.psel==0 
		begin 
			starea_preluata_a_apb.delay_trans;
			@(negedge interfata_monitor_apb.pclk);
		end
      // astept tranzactie valida APB
      wait(interfata_monitor_apb.pready);

      @(negedge interfata_monitor_apb.pclk);

      // PRELUARE DATE
      starea_preluata_a_apb.address = interfata_monitor_apb.paddr;
      starea_preluata_a_apb.rd_wr   = ~interfata_monitor_apb.pwrite;

      if(interfata_monitor_apb.pwrite)
        starea_preluata_a_apb.data = interfata_monitor_apb.pwdata;
      else
        starea_preluata_a_apb.data = interfata_monitor_apb.prdata;

      // COPY (FOARTE IMPORTANT - exact ca la prof)
      aux_tr_apb = starea_preluata_a_apb.copy();

      // TRIMITERE CATRE SCOREBOARD
      port_date_monitor_apb.write(aux_tr_apb);

      `uvm_info("MONITOR_APB",
        $sformatf("ADDR=%0d DATA=%0d RD_WR=%0b",
        aux_tr_apb.address,
        aux_tr_apb.data,
        aux_tr_apb.rd_wr),
        UVM_LOW)

      // COVERAGE
      colector_coverage_apb.stari_apb_cg.sample();

      // evita dublarea tranzactiilor
      @(negedge interfata_monitor_apb.pclk);

    end
  endtask

endclass

`endif