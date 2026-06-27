//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
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

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    // States definition
    typedef enum logic [ 1:0 ] {
        EMPTY    = 'd0,
        C_LOADED = 'd1,
        B_LOADED = 'd2,
        A_LOADED = 'd3
    } work_states;

    work_states state , next_state;

    // States movement
    always_ff @ ( posedge clk )
        if ( rst ) state <= EMPTY;
        else       state <= next_state;

    // State movement conditions
    always_comb begin
        next_state = state;

        case ( state )
            EMPTY    : if ( arg_vld     ) next_state = C_LOADED;
            C_LOADED : if ( isqrt_y_vld ) next_state = B_LOADED;
            B_LOADED : if ( isqrt_y_vld ) next_state = A_LOADED;
            A_LOADED : if ( arg_vld     ) next_state = C_LOADED;
        endcase
    end

    // State load valid conditions
    always_comb begin
        isqrt_x_vld = 0;

        case ( state )
            EMPTY    : if ( arg_vld     ) isqrt_x_vld = arg_vld;
            C_LOADED : if ( isqrt_y_vld ) isqrt_x_vld = isqrt_y_vld;
            B_LOADED : if ( isqrt_y_vld ) isqrt_x_vld = isqrt_y_vld;
            A_LOADED : if ( arg_vld     ) isqrt_x_vld = arg_vld;
        endcase
    end

    // State load conditions
    always_comb
        case ( state )
            EMPTY    : if ( arg_vld     ) isqrt_x = c;
            C_LOADED : if ( isqrt_y_vld ) isqrt_x = b + isqrt_y;
            B_LOADED : if ( isqrt_y_vld ) isqrt_x = a + isqrt_y;
            A_LOADED : if ( arg_vld     ) isqrt_x = c;
        endcase

    // Output
    always_ff @ ( posedge clk or posedge rst )
        if ( rst ) res_vld <= '0;
        else       res_vld <= ( state == A_LOADED ) & isqrt_y_vld;

    always_ff @ ( posedge clk )
        if ( rst ) res <= '0;
        else       res <= isqrt_y;

endmodule
