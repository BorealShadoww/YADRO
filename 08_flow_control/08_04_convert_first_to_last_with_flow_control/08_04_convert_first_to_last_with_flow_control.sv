module gearbox_1_to_2_fc
# (
    parameter width = 8
)
(
    input                   clk,
    input                   rst,

    input                   up_valid,
    output                  up_ready,
    input  [   width - 1:0] up_data,

    output                  down_valid,
    output [ 2*width - 1:0] down_data,
    input                   down_ready
);

    // Task:
    // Implement a module that generates one token from of two tokens.
    // Example:
    // "01", "10" => "0110"
    //
    // The module must use signals valid-ready for transfer tokens.

    logic [ width - 1:0 ]  first_data;
    logic [ width - 1:0 ] second_data;
    logic [ 2*width - 1:0 ] full_data;

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
            FIRST  : if   ( up_valid & up_ready )                                 next_state = SECOND;
            SECOND : if ( ( up_valid & up_ready ) & ( down_valid & down_ready ) ) next_state = FIRST;
                else if                             ( down_valid & down_ready )   next_state = EMPTY;
        endcase
    end
    //---------------------------------------------------------------------
    // State load conditions
    always_comb
        case ( state )
            EMPTY  : if   ( up_valid & up_ready )                                 first_data = up_data;
            FIRST  : if   ( up_valid & up_ready )                                second_data = up_data;
            SECOND : if ( ( up_valid & up_ready ) & ( down_valid & down_ready ) ) first_data = up_data;
        endcase
    //---------------------------------------------------------------------
    // Output
    assign   up_ready = ( state == EMPTY | state == FIRST ) | ( ( down_valid & down_ready ) & ( state == SECOND ) );

    assign down_valid = ( state == SECOND );

    always_ff @ ( posedge clk )
        full_data <= { first_data , second_data };

    assign down_data = full_data;

endmodule
