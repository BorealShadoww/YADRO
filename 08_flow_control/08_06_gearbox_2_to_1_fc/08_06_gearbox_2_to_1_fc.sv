module gearbox_2_to_1_fc
# (
    parameter width = 8
)
(
    input                    clk,
    input                    rst,

    input                    up_valid,
    output                   up_ready,
    input   [ 2*width - 1:0] up_data,

    output                   down_valid,
    input                    down_ready,
    output  [   width - 1:0] down_data
);

    // Task:
    // Implement a module that generates tokens from of one token.
    // Example:
    // "0110" => "01", "10"
    //
    // The module must use signals valid-ready for transfer tokens.
    logic [ width - 1:0 ]  part_data;
    logic [ width - 1:0 ] second_data;

    typedef enum logic [ 1:0 ] {
        EMPTY  = 'd0 ,
        FIRST  = 'd1 ,
        SECOND = 'd2
    } gearbox_states;

    gearbox_states state , next_state;

    //---------------------------------------------------------------------
    // State movement
    always_ff @ ( posedge clk or posedge rst )
        if ( rst ) state <= EMPTY;
        else       state <= next_state;
    //---------------------------------------------------------------------
    // State movement conditions
    always_comb begin
        next_state = state;

        case ( state )
            EMPTY  : if   ( up_valid & up_ready )                                 next_state = FIRST;
            FIRST  : if                             ( down_valid & down_ready )   next_state = SECOND;
            SECOND : if ( ( up_valid & up_ready ) & ( down_valid & down_ready ) ) next_state = FIRST;
                else if                             ( down_valid & down_ready )   next_state = EMPTY;
        endcase
    end
    //---------------------------------------------------------------------
    // State load conditions
    always_comb
        case ( state )
            EMPTY  : if   ( up_valid & up_ready )                                 { part_data , second_data } = up_data;
            FIRST  : if                             ( down_valid & down_ready )   part_data = second_data;
            SECOND : if ( ( up_valid & up_ready ) & ( down_valid & down_ready ) ) { part_data , second_data } = up_data;
        endcase
    //---------------------------------------------------------------------
    // Output
    always_ff @ ( posedge rst )
        if ( rst ) part_data <= 0;
        
    assign   up_ready = state != FIRST & down_ready;

    assign down_valid = ( state == FIRST | ( state == EMPTY & up_valid ) ) | ( state == SECOND & up_valid );

    assign down_data = part_data;

endmodule
