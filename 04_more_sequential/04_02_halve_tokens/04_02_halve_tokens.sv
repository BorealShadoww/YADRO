//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
  input  clk,
  input  rst,
  input  a,
  output b
);
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101
    
  typedef enum logic {
    EMPTY = 'd0 ,  // 0
    FIRST = 'd1    // 1
  } seq_states;

  seq_states state , next_state;

  always_ff @( posedge clk )
    if ( rst ) state <= EMPTY;
    else       state <= next_state;
  
  always_comb begin
    next_state = state;
    case ( state )
      EMPTY : if ( a ) next_state = FIRST;
      FIRST : if ( a ) next_state = EMPTY;
    endcase
  end

  assign b = ( state == FIRST ) & a;

endmodule
