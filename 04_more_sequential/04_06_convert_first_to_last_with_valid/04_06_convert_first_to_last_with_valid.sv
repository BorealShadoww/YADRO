//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module conv_first_to_last_no_ready
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_last,
    output [width - 1:0] down_data
);
    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // See README for full description of the task with timing diagram.

    logic out_valid;

    always_ff @ ( posedge clock )
      if ( reset )
        out_valid <= 0;
      else
        if ( up_valid )
          out_valid <= '1;
    
    assign down_valid = out_valid & up_valid;

    logic [ width - 1:0 ] out_data;

    always_ff @ ( posedge clock )
      if ( reset )
        out_data   <= '0;
      else
        if ( up_valid )
          out_data <= up_data;
    
    assign down_data = out_data;

    logic out_last;

    always_comb
      if ( down_valid )
        out_last = up_first;

    assign down_last = out_last;

endmodule


// --- support: upstream_traffic_generator.sv ---
module upstream_traffic_generator
# (
    parameter width     = 8,
              use_valid = 1
)
(
    input                clock,
    input                reset,

    input                up_enable,

    output               up_valid,
    input                up_ready,
    output               up_first,
    output               up_last,
    output [width - 1:0] up_data
);

    logic               valid;
    logic               first;
    logic               last;
    logic [width - 1:0] data;

    assign up_valid = valid;
    wire   ready    = up_ready;
    assign up_first = valid ? first : 'x;
    assign up_last  = valid ? last  : 'x;
    assign up_data  = valid ? data  : 'x;

    always @ (posedge clock)
    begin
        if (reset)
        begin
            valid <= ~ use_valid;
            first <= 1'b1;
            last  <= 1'b1;
            data  <= "A";
        end
        else
        begin
            if (use_valid & (~ valid | ready))
                valid <= up_enable & $urandom_range (0, 99) < 60;

            if (valid & ready)
            begin
                first <= last;
                last  <= $urandom_range (0, 99) < 30;
                data  <= $urandom_range ("A", "Z");
            end
        end
    end

endmodule



