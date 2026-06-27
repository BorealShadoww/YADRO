module formula_1_pipe
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
    // ISqrt outputs
    wire enable;
    wire [ 15:0 ] a_out , b_out , c_out;
    
    // ISqrt instances
    isqrt a_isqrt ( .x_vld( arg_vld ) , .x( a ) , .y( a_out ) , .y_vld( enable ) , .* );
    isqrt b_isqrt ( .x_vld( arg_vld ) , .x( b ) , .y( b_out ) , .y_vld( enable ) , .* );
    isqrt c_isqrt ( .x_vld( arg_vld ) , .x( c ) , .y( c_out ) , .y_vld( enable ) , .* );

    // Args sum
    wire [ 31:0 ] arg_sum = a_out + b_out + c_out;

    // Out valid
    always_ff @( posedge clk )
        if ( rst )
            res_vld <= '0;
        else
            res_vld <= enable;

    // Out result
    always_ff @( posedge clk )
        if ( enable )
            res     <= arg_sum;

endmodule