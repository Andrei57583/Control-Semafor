`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_agent
`define __apb_agent

`include "tranzactie_apb.sv"
`include "coverage_apb.sv"
`include "driver_agent_apb.sv"
`include "monitor_apb.sv"

class agent_apb extends uvm_agent;

  `uvm_component_utils(agent_apb) // Register the APB agent in the UVM factory

  driver_agent_apb driver_agent_apb_inst0; // APB driver instance
  monitor_apb       monitor_apb_inst0; // APB monitor instance
  uvm_sequencer #(tranzactie_apb) sequencer_agent_apb_inst0; // Sequencer used to provide transactions to the driver

  uvm_analysis_port #(tranzactie_apb) de_la_monitor_apb; // Analysis port used to forward monitor transactions to the environment

  local int is_active = 1; // 1 = active agent, 0 = passive agent

  function new(string name = "agent_apb", uvm_component parent = null);
    super.new(name, parent); // Call the parent constructor
    de_la_monitor_apb = new("de_la_monitor_apb", this); // Create the agent analysis port
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); // Call the parent build phase

    monitor_apb_inst0 = monitor_apb::type_id::create("monitor_apb_inst0", this); // Create the monitor for both active and passive modes

    if (is_active == 1) begin // In active mode, the agent also creates a sequencer and a driver
      sequencer_agent_apb_inst0 = uvm_sequencer#(tranzactie_apb)::type_id::create("sequencer_agent_apb_inst0", this); // Create the APB sequencer
      driver_agent_apb_inst0    = driver_agent_apb::type_id::create("driver_agent_apb_inst0", this); // Create the APB driver
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase); // Call the parent connect phase

    de_la_monitor_apb = monitor_apb_inst0.port_date_monitor_apb; // Connect the agent output port to the monitor analysis port

    if (is_active == 1) begin // Connect the driver to the sequencer only when the agent is active
      driver_agent_apb_inst0.seq_item_port.connect(sequencer_agent_apb_inst0.seq_item_export); // The driver receives APB transactions from the sequencer
    end
  endfunction

endclass

`endif