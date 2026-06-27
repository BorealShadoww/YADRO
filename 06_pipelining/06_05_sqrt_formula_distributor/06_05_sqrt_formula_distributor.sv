module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
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
    localparam BLOCKS_AMOUT = 50;

    // Index counter
    logic [ $clog2( BLOCKS_AMOUT ) - 1:0 ] cnt_idx;

    // Defining inputs and outputs
    logic [ BLOCKS_AMOUT - 1:0 ] in_vld;
    logic [               31:0 ] in_a [ 0:BLOCKS_AMOUT - 1 ];
    logic [               31:0 ] in_b [ 0:BLOCKS_AMOUT - 1 ];
    logic [               31:0 ] in_c [ 0:BLOCKS_AMOUT - 1 ];

    wire  [ BLOCKS_AMOUT - 1:0 ] out_vld;
    wire  [               31:0 ] out  [ 0:BLOCKS_AMOUT - 1 ];
    
    // Modules instantation
    generate
        genvar i;

        // formula_1_impl_1_top
        if      ( formula == 1 & impl == 1 ) begin : formula_1_impl_1
            for ( i = 0 ; i < BLOCKS_AMOUT ; ++i ) begin : for_1_1
                formula_1_impl_1_top block (
                    .arg_vld(  in_vld [i] ) ,
                    .a      (    in_a [i] ) ,
                    .b      (    in_b [i] ) ,
                    .c      (    in_c [i] ) ,
                    .res_vld( out_vld [i] ) ,
                    .res    (     out [i] ) ,
                    .*
                );
            end
        end
        // formula_1_impl_2_top
        else if ( formula == 1 & impl == 2 ) begin : formula_1_impl_2
            for ( i = 0 ; i < BLOCKS_AMOUT ; ++i ) begin : for_1_2
                formula_1_impl_2_top block (
                    .arg_vld(  in_vld [i] ) ,
                    .a      (    in_a [i] ) ,
                    .b      (    in_b [i] ) ,
                    .c      (    in_c [i] ) ,
                    .res_vld( out_vld [i] ) ,
                    .res    (     out [i] ) ,
                    .*
                );
            end
        end
        // formula_2_top
        else if ( formula == 2             ) begin : formula_2
            for ( i = 0 ; i < BLOCKS_AMOUT ; ++i ) begin : for_2
                formula_2_top        block ( 
                    .arg_vld(  in_vld [i] ) ,
                    .a      (    in_a [i] ) ,
                    .b      (    in_b [i] ) ,
                    .c      (    in_c [i] ) ,
                    .res_vld( out_vld [i] ) ,
                    .res    (     out [i] ) ,
                    .*
                );
            end
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
    logic [ 31:0 ] res_reg;

    always_comb
        for ( int i = 0 ; i < BLOCKS_AMOUT ; ++i )
            if ( out_vld [i] )
                res_reg = out [i];
    
    assign res = res_reg;

endmodule