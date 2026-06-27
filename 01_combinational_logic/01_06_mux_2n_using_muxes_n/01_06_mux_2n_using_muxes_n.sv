//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux_2_1
(
  input  [3:0] d0, d1,
  input        sel,
  output [3:0] y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module mux_4_1
(
  input  [3:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [3:0] y
);

  // Task:
  // Implement mux_4_1 using three instances of mux_2_1
  wire [3:0] mux_d0_d1_res;
  wire [3:0] mux_d2_d3_res;

  mux_2_1 mux_d0_d1
    ( d0 , d1 , sel [0] , mux_d0_d1_res );
  mux_2_1 mux_d2_d3 
    ( d2 , d3 , sel [0] , mux_d2_d3_res );

  wire [3:0] mux_d0_d1_d2_d3_res;

  mux_2_1 mux_d0_d1_d2_d3
    ( mux_d0_d1_res , mux_d2_d3_res , sel [1] , mux_d0_d1_d2_d3_res );

  assign y = mux_d0_d1_d2_d3_res;

endmodule
