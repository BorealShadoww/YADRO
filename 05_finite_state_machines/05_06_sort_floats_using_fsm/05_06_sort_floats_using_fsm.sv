module sort_floats_using_fsm #(
    parameter FLEN = 64
) (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output logic                   busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Ваш код здесь

    typedef enum logic [ 1:0 ] {
        EMPTY  = 'd0 ,
        FIRST  = 'd1 ,
        SECOND = 'd2 ,
        THIRD  = 'd3
    } comp_states;

    comp_states state , next_state;

    // States moving
    always_ff @ ( posedge clk or posedge rst )
        if ( rst ) state <= EMPTY;
        else       state <= next_state;

    always_comb begin
        next_state = EMPTY;

        case ( state )
            EMPTY  : if ( valid_in ) next_state = FIRST;
            FIRST  : if ( !err     ) next_state = SECOND;
            SECOND : if ( !err     )  next_state = THIRD;
            THIRD  : if ( !err     )  next_state = EMPTY;
        endcase
    end

    // Data loading
    always_comb
        case ( state )
            FIRST  : { f_le_a , f_le_b } = { unsorted[ 0 ] , unsorted[ 1 ] };
            SECOND : { f_le_a , f_le_b } = { unsorted[ 0 ] , unsorted[ 2 ] };
            THIRD  : { f_le_a , f_le_b } = { unsorted[ 1 ] , unsorted[ 2 ] };
        endcase

    // Comporation
    logic [ 2:0 ] comp_results;

    always_comb
        case ( state )
            EMPTY  : comp_results      = 'b101;
            FIRST  : comp_results[ 2 ] = f_le_res;
            SECOND : comp_results[ 1 ] = f_le_res;
            THIRD  : comp_results[ 0 ] = f_le_res;
        endcase
    
    always_comb
        if ( state == THIRD ) begin
            sorted = unsorted;

            case ( comp_results )
                'b011 : sorted = { unsorted[ 1 ] , unsorted[ 0 ] , unsorted[ 2 ] } ;
                'b001 : sorted = { unsorted[ 1 ] , unsorted[ 2 ] , unsorted[ 0 ] } ;
                'b100 : sorted = { unsorted[ 2 ] , unsorted[ 0 ] , unsorted[ 1 ] } ;
                'b000 : sorted = { unsorted[ 2 ] , unsorted[ 1 ] , unsorted[ 0 ] } ;
                'b110 : sorted = { unsorted[ 0 ] , unsorted[ 2 ] , unsorted[ 1 ] } ;
            endcase
        end

    // Output
    assign valid_out = ( state == THIRD ) | err;
    
    // Error detection
    always_comb
        if ( rst ) err = '0;
        else if ( state == EMPTY ) err = '0;
        else err = f_le_err;

endmodule