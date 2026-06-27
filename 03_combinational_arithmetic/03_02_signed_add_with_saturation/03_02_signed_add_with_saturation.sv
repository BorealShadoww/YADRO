//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.
  
  wire  [3:0] raw_sum = a + b;
  logic [3:0] final_sum;

  always_comb begin
    if ( ( a[3] == b[3] ) & ~( raw_sum[3] == a[3] ) )
      if ( a[3] == 'b1 )
        final_sum = 'b1000;
      else
        final_sum = 'b0111;
    else
      final_sum = raw_sum;
  end

  assign sum = final_sum;

endmodule
