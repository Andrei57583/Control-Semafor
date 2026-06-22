`ifndef __secventa_timing_glitch_apb
`define __secventa_timing_glitch_apb

class secventa_timing_glitch_apb extends uvm_sequence #(tranzactie_apb);
  `uvm_object_utils(secventa_timing_glitch_apb)

  function new(string name="secventa_timing_glitch_apb");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("GLITCH_SEQ", "START: Se executa testul de stres back-to-back (Timing Glitch)", UVM_LOW)

    // Run 20 rapid-fire transactions to flood the APB bus
    repeat(20) begin
      
      bit random_op     = $urandom_range(0, 1);
      bit [1:0] adresa  = $urandom_range(0, 3);
      bit [7:0] date    = $urandom();

      if (random_op == 0) begin
        glitch_write(adresa, date);
      end else begin
        glitch_read(adresa);
      end
    end

    `uvm_info("GLITCH_SEQ", "FINISH: Testul de timing glitch s-a incheiat.", UVM_LOW)
  endtask

  // Helper task for high-speed writes
  virtual task glitch_write(bit[1:0] address_p, bit [7:0] data_p);
    req = tranzactie_apb::type_id::create("req");
    start_item(req);
    
    if(!req.randomize() with { 
      address     == address_p; 
      data        == data_p; 
      rd_wr       == 0;         // 0 means write
      delay_trans == 0;         // CRITICAL: Forces 0 clock cycle delay between transactions!
    }) begin
      `uvm_error("SEQ_ERR", "Glitch Write Randomization failed")
    end
    
    finish_item(req);
  endtask

  // Helper task for high-speed reads
  virtual task glitch_read(bit[1:0] address_p);
    req = tranzactie_apb::type_id::create("req");
    start_item(req);
    
    if(!req.randomize() with { 
      address     == address_p; 
      rd_wr       == 1;         // 1 means read
      delay_trans == 0;         // CRITICAL: No breathing room for the bus state machine
    }) begin
      `uvm_error("SEQ_ERR", "Glitch Read Randomization failed")
    end
    
    finish_item(req);
  endtask
endclass

`endif