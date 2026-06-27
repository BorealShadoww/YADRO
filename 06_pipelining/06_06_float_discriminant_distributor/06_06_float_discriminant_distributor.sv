module float_discriminant_distributor #(
    parameter FLEN = 64,
    parameter NE   = 11
) (
    input  logic                    clk,
    input  logic                    rst,

    input  logic                    arg_vld,
    input  logic [FLEN - 1:0]       a,
    input  logic [FLEN - 1:0]       b,
    input  logic [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Ваш код здесь
    localparam BLOCKS_AMOUT = 50;

    // Index counter
    logic [ $clog2( BLOCKS_AMOUT ) - 1:0 ] cnt_idx;

    // Defining inputs and outputs
    logic [ BLOCKS_AMOUT - 1:0 ] in_vld;
    logic [         FLEN - 1:0 ] in_a [ 0:BLOCKS_AMOUT - 1 ];
    logic [         FLEN - 1:0 ] in_b [ 0:BLOCKS_AMOUT - 1 ];
    logic [         FLEN - 1:0 ] in_c [ 0:BLOCKS_AMOUT - 1 ];

    wire  [ BLOCKS_AMOUT - 1:0 ] out_vld;
    wire  [         FLEN - 1:0 ] out  [ 0:BLOCKS_AMOUT - 1 ];
    wire  [ BLOCKS_AMOUT - 1:0 ] out_neg;
    wire  [ BLOCKS_AMOUT - 1:0 ] out_err;
    
    // Module instantation
    generate
        genvar i;

        for ( i = 0 ; i < BLOCKS_AMOUT ; ++i ) begin : for_disc
            float_discriminant block (
                .arg_vld     (  in_vld [i] ) ,
                .a           (  in_a   [i] ) ,
                .b           (  in_b   [i] ) ,
                .c           (  in_c   [i] ) ,
                .res_vld     ( out_vld [i] ) ,
                .res         ( out     [i] ) ,
                .res_negative( out_neg [i] ),
                .err         ( out_err [i] ) ,
                .busy        (             ) ,
                .*                        // clk , rst
            );
        end
    endgenerate

    // Counter logic
    always_ff @ ( posedge clk )
        if      ( rst                     ) cnt_idx <= '0;
        else if ( cnt_idx >= BLOCKS_AMOUT ) cnt_idx <= '0;
        else if ( arg_vld                 ) cnt_idx <= cnt_idx + 1;

    // Input valid movement
    always_ff @ ( posedge clk ) begin
        in_vld              <= '0;
        in_vld  [ cnt_idx ] <= arg_vld;
    end

    // Input data movement
    always_ff @ ( posedge clk )
        if ( arg_vld ) begin
            in_a [ cnt_idx ] <= a;
            in_b [ cnt_idx ] <= b;
            in_c [ cnt_idx ] <= c;
        end

    // Output valid
    assign res_vld = |out_vld;

    // Output data
    logic [ FLEN - 1:0 ] res_reg;
    logic                res_neg_reg;

    always_comb
        for ( int i = 0 ; i < BLOCKS_AMOUT ; ++i )
            if ( out_vld [i] ) begin
                res_reg     = out     [i];
                res_neg_reg = out_neg [i];
            end
    
    assign res          = res_reg;
    assign res_negative = res_neg_reg;

    // Output error
    assign err = |out_err;

endmodule