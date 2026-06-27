module detect_6_bit_sequence_using_fsm (
  input  logic clk,
  input  logic rst,
  input  logic a,
  output logic detected
);

  // Ваш код здесь
   typedef enum logic [2:0] {
      EMPTY  = 'd0, // xxxxxx
      FIRST  = 'd1, // 1xxxxx
      SECOND = 'd2, // 11xxxx
      THIRD  = 'd3, // 110xxx
      FOURTH = 'd4, // 1100xx
      FIFTH  = 'd5, // 11001x
      SIXTH  = 'd6  // 110011
  } sequence_states;

  sequence_states state, next_state;

  always_ff @( posedge clk or posedge rst )
      if ( rst ) state <= EMPTY;
      else       state <= next_state;

  always_comb begin
    next_state = EMPTY;

    case ( state )
        EMPTY:  if (  a ) next_state = FIRST;
        FIRST:  if (  a ) next_state = SECOND;
        SECOND: if ( !a ) next_state = THIRD;
                else      next_state = SECOND;
        THIRD:  if ( !a ) next_state = FOURTH;
                else      next_state = FIRST;
        FOURTH: if (  a ) next_state = FIFTH;
        FIFTH:  if (  a ) next_state = SIXTH;
        SIXTH:  if (  a ) next_state = FIRST;
                else      next_state = THIRD;
    endcase
  end

  assign detected = state == SIXTH;
    
endmodule