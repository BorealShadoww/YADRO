module float_discriminant #(
    parameter FLEN = 64
) (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Ваш код здесь
    // Подсказка: вы можете использовать готовые модули f_mult и f_sub (доступны при компиляции)
    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;
    // localparam [FLEN - 1:0] mask = 64'h7fff_ffff_ffff_ffff;

    logic                 in_mult_1_vld;
    logic [ FLEN - 1:0 ]  in_mult_1_a;
    logic [ FLEN - 1:0 ]  in_mult_1_b;
    logic                out_mult_1_vld;
    logic [ FLEN - 1:0 ] out_mult_1_res;
    logic                out_mult_1_err;

    logic                 in_mult_2_vld;
    logic [ FLEN - 1:0 ]  in_mult_2_a;
    logic [ FLEN - 1:0 ]  in_mult_2_b;
    logic                out_mult_2_vld;
    logic [ FLEN - 1:0 ] out_mult_2_res;
    logic                out_mult_2_err;

    logic                 in_sub_1_vld;
    logic [ FLEN - 1:0 ]  in_sub_1_a;
    logic [ FLEN - 1:0 ]  in_sub_1_b;
    logic                out_sub_1_vld;
    logic [ FLEN - 1:0 ] out_sub_1_res;
    logic                out_sub_1_err;

    // Instances
    f_mult f_mult_1 (
        .a         (  in_mult_1_a   ) ,
        .b         (  in_mult_1_b   ) ,
        .up_valid  (  in_mult_1_vld ) ,
        .res       ( out_mult_1_res ) ,
        .down_valid( out_mult_1_vld ) ,
        .busy      (                ) ,
        .error     ( out_mult_1_err ) ,
        .*
    );

    f_mult f_mult_2 (
        .a         (  in_mult_2_a   ) ,
        .b         (  in_mult_2_b   ) ,
        .up_valid  (  in_mult_2_vld ) ,
        .res       ( out_mult_2_res ) ,
        .down_valid( out_mult_2_vld ) ,
        .busy      (                ) ,
        .error     ( out_mult_2_err ) ,
        .*
    );

    f_sub f_sub_1 (
        .a         (  in_sub_1_a    ) ,
        .b         (  in_sub_1_b    ) ,
        .up_valid  (  in_sub_1_vld  ) ,
        .res       ( out_sub_1_res  ) ,
        .down_valid( out_sub_1_vld  ) ,
        .busy      (                ) ,
        .error     ( out_sub_1_err  ) ,
        .*
    );

    // States definition
    typedef enum logic [ 1:0 ] {
        EMPTY             = 'd0 ,
        B_SQUARE_A_C_MULT = 'd1 ,
        FOUR_MULT         = 'd2 ,
        SUB               = 'd3
    } disc_states;

    disc_states state , next_state;

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
            EMPTY             : if ( arg_vld                         ) next_state = B_SQUARE_A_C_MULT;
            B_SQUARE_A_C_MULT : if ( out_mult_1_vld & out_mult_2_vld ) next_state = FOUR_MULT;
            FOUR_MULT         : if ( out_mult_2_vld                  ) next_state = SUB;
            SUB               : if ( arg_vld                         ) next_state = B_SQUARE_A_C_MULT;
        endcase
    end

    // State load valid conditions
    always_comb begin
        { in_mult_1_vld , in_mult_2_vld , in_sub_1_vld } = { '0 , '0 , '0 };

        case ( state )
            EMPTY             : if ( arg_vld                         ) { in_mult_1_vld , in_mult_2_vld } = { arg_vld , arg_vld };
            B_SQUARE_A_C_MULT : if ( out_mult_1_vld & out_mult_2_vld )   in_mult_2_vld = out_mult_1_vld & out_mult_2_vld;
            FOUR_MULT         : if ( out_mult_2_vld                  )   in_sub_1_vld  = out_mult_2_vld;
            SUB               : if ( arg_vld                         ) { in_mult_1_vld , in_mult_2_vld } = { arg_vld , arg_vld };
        endcase
    end

    // State load conditions
    always_comb
        case ( state )
            EMPTY             : if ( arg_vld                         ) { in_mult_1_a , in_mult_1_b , in_mult_2_a , in_mult_2_b } = { b , b , a , c };
            B_SQUARE_A_C_MULT : if ( out_mult_1_vld & out_mult_2_vld ) { in_mult_2_a , in_mult_2_b }                             = { four           , out_mult_2_res };
            FOUR_MULT         : if ( out_mult_2_vld                  ) { in_sub_1_a  , in_sub_1_b  }                             = { out_mult_1_res , out_mult_2_res };
            SUB               : if ( arg_vld                         ) { in_mult_1_a , in_mult_1_b , in_mult_2_a , in_mult_2_b } = { b , b , a , c };
        endcase

    // Output
    always_ff @ ( posedge clk )
        if ( rst ) res_vld <= '0;
        else       res_vld <= out_sub_1_vld & ( state == SUB );
    
    always_ff @ ( posedge clk ) begin
        res          <= out_sub_1_res;
        res_negative <= out_sub_1_res [ FLEN - 1 ];
    end

    always_ff @ ( posedge clk )
        if ( rst ) err <= '0;
        else       err <= out_mult_1_err | out_mult_2_err | out_sub_1_err;

endmodule