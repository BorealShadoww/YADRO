//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_comparator_least_significant_first
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  logic prev_a_eq_b, prev_a_less_b;

  assign a_eq_b      = prev_a_eq_b & (a == b);
  assign a_less_b    = (~ a & b) | (a == b & prev_a_less_b);
  assign a_greater_b = (~ a_eq_b) & (~ a_less_b);

  always_ff @ (posedge clk)
    if (rst)
    begin
      prev_a_eq_b   <= '1;
      prev_a_less_b <= '0;
    end
    else
    begin
      prev_a_eq_b   <= a_eq_b;
      prev_a_less_b <= a_less_b;
    end

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_comparator_most_significant_first
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  // Task:
  // Implement a module that compares two numbers in a serial manner.
  // The module inputs a and b are 1-bit digits of the numbers
  // and most significant bits are first.
  // The module outputs a_less_b, a_eq_b, and a_greater_b
  // should indicate whether a is less than, equal to, or greater than b, respectively.
  // The module should also use the clk and rst inputs.
  //
  // See the testbench for the output format ($display task).
  logic prev_a_eq_b, prev_a_less_b, prev_a_greater_b;

  // Combinational logic for outputs
  // If previous bits were equal, compare current bits
  // Otherwise, keep the previous result
  assign a_less_b    = prev_a_eq_b ? (a < b)  : prev_a_less_b;
  assign a_greater_b = prev_a_eq_b ? (a > b)  : prev_a_greater_b;
  assign a_eq_b      = prev_a_eq_b ? (a == b) : 1'b0;

  always_ff @(posedge clk)
    if (rst)
    begin
      // Start with equal assumption for MSB comparison
      prev_a_eq_b      <= 1'b1;
      prev_a_less_b    <= 1'b0;
      prev_a_greater_b <= 1'b0;
    end
    else
    begin
      // Store current results for next cycle
      prev_a_eq_b      <= a_eq_b;
      prev_a_less_b    <= a_less_b;
      prev_a_greater_b <= a_greater_b;
    end

endmodule
