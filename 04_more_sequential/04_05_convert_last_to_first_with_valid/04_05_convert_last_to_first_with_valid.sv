//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module conv_last_to_first
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_last,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_first,
    output [width - 1:0] down_data
);
    // Task:
    // Implement a module that converts 'last' input status signal
    // to the 'first' output status signal.
    //
    // See README for full description of the task with timing diagram.
    
    assign down_valid = up_valid;
    
    logic out_first;

    always_ff @ ( posedge clock )
      if ( reset )
        out_first     <= '1;
      else
        if ( up_valid )
          if ( up_last )
            out_first <= '1;
          else
            out_first <= '0;

    assign down_first = out_first;

    logic [ width - 1:0 ] out_data;

    always_comb
      if ( down_valid )
        out_data = up_data;
      else
        out_data = 'x;

    assign down_data  = out_data;

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



