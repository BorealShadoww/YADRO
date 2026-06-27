//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);

  logic a_r;

  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.

  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;

  assign detected = ~ a_r & a;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module one_cycle_pulse_detector (input clk, rst, a, output detected);

  // Task:
  // Create an one cycle pulse (010) detector.
  //
  // Note:
  // See the testbench for the output format ($display task).
  typedef enum logic [1:0] {
    SEQ_NOTHING = 'd0 ,  // xxx
    SEQ_START   = 'd1 ,  // 0xx
    SEQ_MID     = 'd2 ,  // 01x
    SEQ_END     = 'd3    // 010
  } seq_states;

  seq_states state , next_state;

  always_ff @( posedge clk )
    if ( rst ) state <= SEQ_NOTHING;
    else       state <= next_state;
  
  always_comb begin
    next_state = state;
    case ( state )
      SEQ_NOTHING : if ( !a ) next_state = SEQ_START;
      SEQ_START   : if (  a ) next_state = SEQ_MID;
      SEQ_MID     : if ( !a ) next_state = SEQ_END;
                    else      next_state = SEQ_NOTHING;
      SEQ_END     : if ( !a ) next_state = SEQ_START;
                    else      next_state = SEQ_NOTHING;
    endcase
  end

  logic a_r;

  always_ff @( posedge clk )
    if ( rst ) a_r <= '0;
    else       a_r <= ( next_state == SEQ_MID );
  
  assign detected = a_r & ( ~a );

endmodule
