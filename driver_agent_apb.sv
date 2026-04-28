`ifndef __apb_driver
`define __apb_driver

class driver_agent_apb extends uvm_driver #(tranzactie_apb);

  `uvm_component_utils(driver_agent_apb)

  virtual apb_interface_dut interfata_driverului_pentru_apb;

  function new(string name = "driver_agent_apb", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", interfata_driverului_pentru_apb))
      `uvm_fatal("DRIVER_AGENT_APB", "Nu s-a putut accesa interfata_apb")
  endfunction

  virtual task run_phase(uvm_phase phase);
    tranzactie_apb req;

    super.run_phase(phase);

    forever begin
      `uvm_info("DRIVER_AGENT_APB", "Se asteapta o tranzactie de la sequencer", UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER_AGENT_APB", "S-a primit o tranzactie de la sequencer", UVM_LOW)

      trimiterea_tranzactiei(req);

      `uvm_info("DRIVER_AGENT_APB", "Tranzactia a fost transmisa pe interfata", UVM_LOW)
      seq_item_port.item_done();
    end
  endtask

  task trimiterea_tranzactiei(tranzactie_apb informatia_de_transmis);
    $timeformat(-9, 2, " ns", 20);

    // SETUP Phase
    repeat(informatia_de_transmis.delay_trans)@(posedge interfata_driverului_pentru_apb.pclk);
    interfata_driverului_pentru_apb.psel    <= 1'b1;
    interfata_driverului_pentru_apb.penable <= 1'b0;
    interfata_driverului_pentru_apb.paddr   <= informatia_de_transmis.address;
    interfata_driverului_pentru_apb.pwrite  <= ~informatia_de_transmis.rd_wr;

    if(informatia_de_transmis.rd_wr == 0) // daca avem scriere
      interfata_driverului_pentru_apb.pwdata <= informatia_de_transmis.data;

    // ACCESS Phase
    @(posedge interfata_driverului_pentru_apb.pclk);
    interfata_driverului_pentru_apb.penable <= 1'b1;

    // WAIT pready (APB handshake)
    wait(interfata_driverului_pentru_apb.pready);
    //@(posedge interfata_driverului_pentru_apb.pclk iff interfata_driverului_pentru_apb.pready);
	

    // READ: preluam datele citite de la DUT daca e read
	// nu cred  ca este necesar in driver:
    //if(informatia_de_transmis.rd_wr == 1)
    //  informatia_de_transmis.data = interfata_driverului_pentru_apb.prdata;

    // END Phase
    @(posedge interfata_driverului_pentru_apb.pclk);
    interfata_driverului_pentru_apb.psel    <= 1'b0;
    interfata_driverului_pentru_apb.penable <= 1'b0;
    interfata_driverului_pentru_apb.paddr   <= 'bz;
    interfata_driverului_pentru_apb.pwdata  <= 'bz;
    interfata_driverului_pentru_apb.pwrite  <= 'bz;

    `ifdef DEBUG
      $display("[DRV] Tranzactie transmisă: ADDR=%0d DATA=%0d RD_WR=%0b T=%0t",
               informatia_de_transmis.address,
               informatia_de_transmis.data,
               informatia_de_transmis.rd_wr,
               $realtime);
    `endif
  endtask

endclass

`endif