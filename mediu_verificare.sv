`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __verification_environment
`define __verification_environment

typedef scoreboard; // Forward type definition used to avoid errors caused by cross dependency between scoreboard and coverage classes

`include "agent_apb.sv"
`include "agent_rename.sv"
`include "scoreboard.sv"

class mediu_verificare extends uvm_env;
  
  `uvm_component_utils(mediu_verificare) // Register the verification environment in the UVM factory
  
  virtual apb_interface_dut interfata_monitor_apb; // Virtual APB interface used by the environment
  virtual rename_interface_dut interfata_monitor_rename; // Virtual output interface used by the environment

  agent_apb agent_apb_din_mediu; // Active APB agent that drives and monitors the APB interface
  agent_rename agent_rename_din_mediu; // Agent that monitors the output/interface behavior
  
  scoreboard IO_scorboard; // Scoreboard used to check the transactions received from the agents
  
  function new(string name, uvm_component parent = null);
    super.new(name, parent); // Call the parent constructor
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase); // Call the parent build phase

    agent_apb_din_mediu = agent_apb::type_id::create("agent_apb_din_mediu", this); // Create the APB agent
    agent_rename_din_mediu = agent_rename::type_id::create("agent_rename_din_mediu", this); // Create the rename/output agent
    IO_scorboard = scoreboard::type_id::create("IO_scorboard", this); // Create the scoreboard
  endfunction
  
  function void connect_phase(uvm_phase phase);

    `uvm_info("VERIFICATION_ENVIRONMENT", "The connection phase has started", UVM_NONE);

    assert(uvm_resource_db#(virtual apb_interface_dut)::read_by_name(
      get_full_name(), "apb_interface_dut", interfata_monitor_apb)) 
    else 
      `uvm_error("VERIFICATION_ENVIRONMENT", "Could not get apb_interface_dut from the UVM database");

    assert(uvm_resource_db#(virtual rename_interface_dut)::read_by_name(
      get_full_name(), "rename_interface_dut", interfata_monitor_rename)) 
    else 
      `uvm_error("VERIFICATION_ENVIRONMENT", "Could not get rename_interface_dut from the UVM database");

    agent_apb_din_mediu.de_la_monitor_apb.connect(IO_scorboard.port_pentru_datele_de_la_apb); // Connect APB monitor output to the scoreboard
    agent_rename_din_mediu.de_la_monitor_rename.connect(IO_scorboard.port_pentru_datele_de_la_rename); // Connect rename monitor output to the scoreboard

    `uvm_info("VERIFICATION_ENVIRONMENT", "The connection phase has finished", UVM_HIGH);

  endfunction: connect_phase
  
  task run_phase(uvm_phase phase);

    // phase.raise_objection(this);

    `uvm_info("VERIFICATION_ENVIRONMENT", "The verification environment RUN phase has started", UVM_NONE);

    begin
      // Initialization code for interface traffic can be added here if needed
    end

    // phase.drop_objection(this);

  endtask
  
endclass

`endif