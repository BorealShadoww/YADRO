module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output       [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Ваш код здесь
    // States definition
    // States definition
    typedef enum logic [ 1:0 ] {
        EMPTY    = 'd0 ,
        A_LOADED = 'd1 ,
        B_LOADED = 'd2 ,
        C_LOADED = 'd3
    } sqrt_states;

    sqrt_states state , next_state;

    // State movement
    always_ff @ ( posedge clk )
        if ( rst )
            state <= EMPTY;
        else
            state <= next_state;
    
    // State movement conditions
    always_comb begin
        next_state = state;

        case ( state )
            EMPTY    : if ( arg_vld     ) next_state = A_LOADED;
            A_LOADED : if ( isqrt_y_vld ) next_state = B_LOADED;
            B_LOADED : if ( isqrt_y_vld ) next_state = C_LOADED;
            C_LOADED : if ( arg_vld     ) next_state = A_LOADED;
        endcase
    end

    // State load conditions
    always_comb
        case ( state )
            EMPTY    : if ( arg_vld     ) isqrt_x = a;
            A_LOADED : if ( isqrt_y_vld ) isqrt_x = b;
            B_LOADED : if ( isqrt_y_vld ) isqrt_x = c;
            C_LOADED : if ( arg_vld     ) isqrt_x = a;
        endcase
    
    // State load valid conditions
    always_comb begin
        isqrt_x_vld = '0;

        case ( state )
            EMPTY    : if ( arg_vld     ) isqrt_x_vld = arg_vld;
            A_LOADED : if ( isqrt_y_vld ) isqrt_x_vld = isqrt_y_vld;
            B_LOADED : if ( isqrt_y_vld ) isqrt_x_vld = isqrt_y_vld;
            C_LOADED : if ( arg_vld     ) isqrt_x_vld = arg_vld;
        endcase
    end

    // State sum conditions
    logic [ 31:0 ] args_sum;

    always_ff @( posedge clk )
        if ( rst )
            args_sum <= '0;
        else
            case ( state )
                A_LOADED : if ( isqrt_y_vld ) args_sum = isqrt_y;
                B_LOADED : if ( isqrt_y_vld ) args_sum = isqrt_y + args_sum;
                C_LOADED : if ( isqrt_y_vld ) args_sum = isqrt_y + args_sum;
            endcase
    
    // Output
    always_ff @( posedge clk )
        if ( rst )
            res_vld <= '0;
        else begin
            res_vld <= isqrt_y_vld & ( state == C_LOADED );
        end
    
    assign res = args_sum;

endmodule