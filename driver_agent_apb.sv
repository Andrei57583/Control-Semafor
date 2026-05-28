`ifndef __apb_driver
`define __apb_driver

class driver_agent_apb extends uvm_driver #(tranzactie_apb);

  `uvm_component_utils(driver_agent_apb) // Register the APB driver in the UVM factory

  virtual apb_interface_dut interfata_driverului_pentru_apb; // Virtual APB interface driven by this driver

  function new(string name = "driver_agent_apb", uvm_component parent = null);
    super.new(name, parent); // Call the parent constructor
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); // Call the parent build phase

    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", interfata_driverului_pentru_apb))
      `uvm_fatal("DRIVER_AGENT_APB", "Could not access the APB interface") // Stop simulation if the interface is not found
  endfunction

  virtual task run_phase(uvm_phase phase);
    tranzactie_apb req; // Transaction received from the sequencer

    super.run_phase(phase); // Call the parent run phase

    forever begin
      `uvm_info("DRIVER_AGENT_APB", "Waiting for a transaction from the sequencer", UVM_LOW)

      seq_item_port.get_next_item(req); // Get the next APB transaction from the sequencer

      `uvm_info("DRIVER_AGENT_APB", "Transaction received from the sequencer", UVM_LOW)

      trimiterea_tranzactiei(req); // Drive the received transaction on the APB interface

      `uvm_info("DRIVER_AGENT_APB", "Transaction was driven on the APB interface", UVM_LOW)

      seq_item_port.item_done(); // Notify the sequencer that the transaction is completed
    end
  endtask

  task trimiterea_tranzactiei(tranzactie_apb informatia_de_transmis);
    $timeformat(-9, 2, " ns", 20); // Set time display format for debug messages

    repeat(informatia_de_transmis.delay_trans)
      @(posedge interfata_driverului_pentru_apb.pclk); // Wait the delay specified inside the transaction

    interfata_driverului_pentru_apb.psel    <= 1'b1; // Start APB SETUP phase by selecting the slave
    interfata_driverului_pentru_apb.penable <= 1'b0; // PENABLE is low during SETUP phase
    interfata_driverului_pentru_apb.paddr   <= informatia_de_transmis.address; // Drive the APB address
    interfata_driverului_pentru_apb.pwrite  <= ~informatia_de_transmis.rd_wr; // Convert internal rd_wr encoding to APB PWRITE

    if(informatia_de_transmis.rd_wr == 0) // If the transaction is a WRITE
      interfata_driverului_pentru_apb.pwdata <= informatia_de_transmis.data; // Drive write data on PWDATA

    @(posedge interfata_driverului_pentru_apb.pclk); // Move from SETUP phase to ACCESS phase

    interfata_driverului_pentru_apb.penable <= 1'b1; // Enable APB ACCESS phase

    wait(interfata_driverului_pentru_apb.pready); // Wait until the APB slave completes the transfer

    //@(posedge interfata_driverului_pentru_apb.pclk iff interfata_driverului_pentru_apb.pready); // Alternative wait for PREADY on clock edge

    // Reading PRDATA is not done in the driver because the monitor collects read data from the interface
    // if(informatia_de_transmis.rd_wr == 1)
    //   informatia_de_transmis.data = interfata_driverului_pentru_apb.prdata;

    @(posedge interfata_driverului_pentru_apb.pclk); // Wait one clock cycle before returning the bus to idle

    interfata_driverului_pentru_apb.psel    <= 1'b0; // Deassert slave select
    interfata_driverului_pentru_apb.penable <= 1'b0; // Deassert enable signal
    interfata_driverului_pentru_apb.paddr   <= 'bz; // Release address bus
    interfata_driverului_pentru_apb.pwdata  <= 'bz; // Release write data bus
    interfata_driverului_pentru_apb.pwrite  <= 'bz; // Release write control signal

    `ifdef DEBUG
      $display("[DRV] Transaction sent: ADDR=%0d DATA=%0d RD_WR=%0b T=%0t",
               informatia_de_transmis.address,
               informatia_de_transmis.data,
               informatia_de_transmis.rd_wr,
               $realtime);
    `endif
  endtask

endclass

`endif