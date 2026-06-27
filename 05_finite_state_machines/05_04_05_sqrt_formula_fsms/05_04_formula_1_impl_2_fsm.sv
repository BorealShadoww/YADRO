module formula_1_impl_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Ваш код здесь
    // Double sqrt states
    typedef enum logic [ 2:0 ] {
        EMPTY      = 'd0,
        A_B_LOADED = 'd1,
        C_LOADED   = 'd2
    } work_states;

    work_states state , next_state;

    // States movement
    always_ff @ ( posedge clk or posedge rst )
        if ( rst ) state <= EMPTY;
        else       state <= next_state;

    // State movement conditions
    always_comb begin
        next_state = state;

        case ( state )
            EMPTY      : if ( arg_vld                       ) next_state = A_B_LOADED;
            A_B_LOADED : if ( isqrt_1_y_vld & isqrt_2_y_vld ) next_state = C_LOADED;
            C_LOADED   : if ( arg_vld                       ) next_state = A_B_LOADED;
        endcase
    end

    // State load valid conditions
    always_comb begin
        isqrt_1_x_vld = '0;
        isqrt_2_x_vld = '0;

        case ( state )
            EMPTY      : if ( arg_vld                       ) { isqrt_1_x_vld , isqrt_2_x_vld } = { arg_vld , arg_vld };
            A_B_LOADED : if ( isqrt_1_y_vld & isqrt_2_y_vld )   isqrt_1_x_vld                   =   isqrt_1_y_vld;
            C_LOADED   : if ( arg_vld                       ) { isqrt_1_x_vld , isqrt_2_x_vld } = { arg_vld , arg_vld };
        endcase
    end

    // State load conditions
    always_comb
        case ( state )
            EMPTY      : if ( arg_vld                       ) { isqrt_1_x , isqrt_2_x } = { a , b };
            A_B_LOADED : if ( isqrt_1_y_vld & isqrt_2_y_vld )   isqrt_1_x               =   c;
            C_LOADED   : if ( arg_vld                       ) { isqrt_1_x , isqrt_2_x } = { a , b };
        endcase

    // Output
    always_ff @ ( posedge clk or posedge rst )
        if ( rst ) res_vld <= '0;
        else       res_vld <= ( state == C_LOADED ) & isqrt_1_y_vld;

    always_ff @ ( posedge clk )
        if ( rst ) res = '0;
        else case ( state )
            A_B_LOADED : if ( isqrt_1_y_vld & isqrt_2_y_vld ) res = isqrt_1_y + isqrt_2_y;
            C_LOADED   : if ( isqrt_1_y_vld                 ) res = isqrt_1_y + res;
        endcase

endmodule