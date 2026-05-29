`ifndef __apb_monitor
`define __apb_monitor

class monitor_apb extends uvm_monitor;
  
  `uvm_component_utils(monitor_apb) // Register the monitor in the UVM factory

  coverage_apb colector_coverage_apb; // Coverage collector instance

  uvm_analysis_port #(tranzactie_apb) port_date_monitor_apb; // Port used to send collected transactions to the scoreboard

  virtual apb_interface_dut interfata_monitor_apb; // Virtual APB interface used for signal sampling

  tranzactie_apb starea_preluata_a_apb, aux_tr_apb; // Transaction objects used for collected and copied data

  function new(string name = "monitor_apb", uvm_component parent = null);
    super.new(name, parent); // Call the parent constructor

    port_date_monitor_apb = new("port_date_monitor_apb", this); // Create the analysis port

    colector_coverage_apb = coverage_apb::type_id::create("colector_coverage_apb", this); // Create the coverage collector

    starea_preluata_a_apb = tranzactie_APB::type_id::create("tr_curent"); // Create the current transaction object
    aux_tr_apb            = tranzactie_APB::type_id::create("tr_copy"); // Create the copied transaction object
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); // Call the parent build phase

    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", interfata_monitor_apb))
      `uvm_fatal("MONITOR_APB", "Could not access the APB monitor interface") // Stop simulation if the interface is not found
  endfunction


  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase); // Call the parent connect phase

    colector_coverage_apb.p_monitor = this; // Connect the coverage collector to this monitor
  endfunction


  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase); // Call the parent run phase

    forever begin

      while (interfata_monitor_apb.psel == 0) begin // Wait until an APB transfer starts
        starea_preluata_a_apb.delay_trans++; // Count the idle cycles before the transfer
        @(negedge interfata_monitor_apb.pclk); // Sample on the negative clock edge
      end

      wait(interfata_monitor_apb.pready); // Wait until the APB slave completes the transfer

      @(negedge interfata_monitor_apb.pclk); // Move to the next negative edge before sampling the transfer information

      starea_preluata_a_apb.address = interfata_monitor_apb.paddr; // Store the APB address
      starea_preluata_a_apb.rd_wr   = ~interfata_monitor_apb.pwrite; // Convert PWRITE to the internal read/write encoding

      if(interfata_monitor_apb.pwrite)
        starea_preluata_a_apb.data = interfata_monitor_apb.pwdata; // For WRITE transfers, sample data from PWDATA
      else
        starea_preluata_a_apb.data = interfata_monitor_apb.prdata; // For READ transfers, sample data from PRDATA

      aux_tr_apb = starea_preluata_a_apb.copy(); // Copy the transaction to avoid changing it later

      port_date_monitor_apb.write(aux_tr_apb); // Send the transaction to the scoreboard

      `uvm_info("MONITOR_APB",
        $sformatf("ADDR=%0d DATA=%0d RD_WR=%0b",
        aux_tr_apb.address,
        aux_tr_apb.data,
        aux_tr_apb.rd_wr),
        UVM_LOW)

      colector_coverage_apb.stari_apb_cg.sample(); // Sample functional coverage

      @(negedge interfata_monitor_apb.pclk); // Prevent the same transfer from being collected twice

    end
  endtask

endclass

`endif