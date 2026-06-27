module formula_2_pipe
(
    input  logic        clk,
    input  logic        rst,

    input  logic        arg_vld,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,

    output logic        res_vld,
    output logic [31:0] res
);

    // Ваш код здесь
    // Instances definitions ---------------------------------------------------------------------------------

    localparam                ISQRT_LATENCY = 4;
    localparam                ARG_WIDTH     = 32;

    // First stage ------------------------------------------
    // Sqrt instance
    wire                      first_stg_sqrt_out_vld;
    wire  [ 15:0 ]            first_stg_sqrt_out_arg;

    isqrt #(
        .n_pipe_stages( ISQRT_LATENCY )
    )
    c_sqrt (
        .x_vld   ( arg_vld                 ) ,
        .x       ( c                       ) ,
        .y_vld   ( first_stg_sqrt_out_vld  ) ,
        .y       ( first_stg_sqrt_out_arg  ) ,
        .*                                     // clk , rst
    );

    // Second stage -----------------------------------------
    // Shift register instance
    wire                      second_stg_reg_out_vld;
    wire  [ ARG_WIDTH - 1:0 ] second_stg_reg_out_arg;

    shift_register_with_valid #(
        .depth   ( ISQRT_LATENCY           ) ,
        .width   ( ARG_WIDTH               )
    )
    first_shift_reg (
        .in_vld  ( arg_vld                 ) ,
        .in_data ( b                       ) ,
        .out_vld ( second_stg_reg_out_vld  ) ,
        .out_data( second_stg_reg_out_arg  ) ,
        .*                                     // clk , rst
    );

    // Sqrt instance
    logic                     second_stg_sqrt_in_vld;
    logic [ ARG_WIDTH - 1:0 ] second_stg_sqrt_in_arg;
    wire                      second_stg_sqrt_out_vld;
    wire  [ 15:0 ]            second_stg_sqrt_out_arg;

    isqrt #(
        .n_pipe_stages( ISQRT_LATENCY )
    )
    b_sqrt (
        .x_vld   ( second_stg_sqrt_in_vld  ) ,
        .x       ( second_stg_sqrt_in_arg  ) ,
        .y_vld   ( second_stg_sqrt_out_vld ) ,
        .y       ( second_stg_sqrt_out_arg ) ,
        .*                                     // clk , rst
    );

    // Third stage ------------------------------------------
    // Shift register instance
    wire                      third_stg_reg_out_vld;
    wire  [ ARG_WIDTH - 1:0 ] third_stg_reg_out_arg;

    shift_register_with_valid #(
        .depth   ( ISQRT_LATENCY * 2 + 1   ) ,
        .width   ( ARG_WIDTH               )
    )
    second_shift_reg (
        .in_vld  ( arg_vld                 ) ,
        .in_data ( a                       ) ,
        .out_vld ( third_stg_reg_out_vld   ) ,
        .out_data( third_stg_reg_out_arg   ) ,
        .*                                     // clk , rst
    );

    // Sqrt instance
    logic                     third_stg_sqrt_in_vld;
    logic [ ARG_WIDTH - 1:0 ] third_stg_sqrt_in_arg;
    wire                      third_stg_sqrt_out_vld;
    wire  [ 15:0 ]            third_stg_sqrt_out_arg;

    isqrt #(
        .n_pipe_stages( ISQRT_LATENCY )
    )
    a_sqrt (
        .x_vld   ( third_stg_sqrt_in_vld   ) ,
        .x       ( third_stg_sqrt_in_arg   ) ,
        .y_vld   ( third_stg_sqrt_out_vld  ) ,
        .y       ( third_stg_sqrt_out_arg  ) ,
        .*                                     // clk , rst
    );

    // Pipeline ----------------------------------------------------------------------------------------------
    // Second stage -----------------------------------------
    always_ff @ ( posedge clk )
        if ( rst )
            second_stg_sqrt_in_vld <= '0;
        else begin
            second_stg_sqrt_in_vld <= second_stg_reg_out_vld & first_stg_sqrt_out_vld; // Shift vld b + sqrt vld c
            second_stg_sqrt_in_arg <= second_stg_reg_out_arg + first_stg_sqrt_out_arg; // Shift reg b + sqrt c
        end

    // Third stage ------------------------------------------
    always_ff @ ( posedge clk )
        if ( rst )
            third_stg_sqrt_in_vld <= '0;
        else begin
            third_stg_sqrt_in_vld <= third_stg_reg_out_vld & second_stg_sqrt_out_vld; // Shift vld a + sqrt vld b
            third_stg_sqrt_in_arg <= third_stg_reg_out_arg + second_stg_sqrt_out_arg; // Shift reg a + sqrt b
        end

    // Output
    assign res_vld = third_stg_sqrt_out_vld;
    assign res     = third_stg_sqrt_out_arg;

endmodule