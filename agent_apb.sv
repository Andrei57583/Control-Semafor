`ifndef __apb_agent
`define __apb_agent

`include "tranzactie_apb.sv"
`include "coverage_apb.sv"
`include "driver_agent_apb.sv"
`include "monitor_apb.sv"

class agent_apb extends uvm_agent;

  `uvm_component_utils(agent_apb)

  driver_agent_apb driver_agent_apb_inst0;
  monitor_apb       monitor_apb_inst0;
  uvm_sequencer #(tranzactie_apb) sequencer_agent_apb_inst0;

  uvm_analysis_port #(tranzactie_apb) de_la_monitor_apb;

  local int is_active = 1; // 1 = agent activ, 0 = pasiv

  function new(string name = "agent_apb", uvm_component parent = null);
    super.new(name, parent);
    de_la_monitor_apb = new("de_la_monitor_apb", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // MONITOR (atat pentru activ, cat si pasiv)
    monitor_apb_inst0 = monitor_apb::type_id::create("monitor_apb_inst0", this);

    // AGENT ACTIV → sequencer + driver
    if (is_active == 1) begin
      sequencer_agent_apb_inst0 = uvm_sequencer#(tranzactie_apb)::type_id::create("sequencer_agent_apb_inst0", this);
      driver_agent_apb_inst0    = driver_agent_apb::type_id::create("driver_agent_apb_inst0", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // portul de comunicare al agentului către scoreboard
    de_la_monitor_apb = monitor_apb_inst0.port_date_monitor_apb;

    // driver preia date de la sequencer (doar agent activ)
    if (is_active == 1) begin
      driver_agent_apb_inst0.seq_item_port.connect(sequencer_agent_apb_inst0.seq_item_export);
    end
  endfunction

endclass

`endif