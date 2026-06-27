//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement xor gate using instance(s) of mux,
  // constants 0 and 1, and wire connections
  wire not_a_gate_res;
  wire not_b_gate_res;
  wire not_a_and_gate_res;
  wire not_b_and_gate_res;

  mux not_a_gate
                      ( 1'b1 ,          1'b0 , a ,     not_a_gate_res );
  mux not_b_gate
                      ( 1'b1 ,          1'b0 , b ,     not_b_gate_res );
  mux not_a_and_gate
                      ( 1'b0, not_a_gate_res , b , not_a_and_gate_res );
  mux not_b_and_gate
                      ( 1'b0, not_b_gate_res , a , not_b_and_gate_res );
  
  wire res;
  
  mux xor_gate
    ( not_a_and_gate_res , 1'b1 , not_b_and_gate_res , res );
  
  assign o = res;

endmodule
