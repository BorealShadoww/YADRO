module generate_tokens_by_number_with_flow_control
#(
    parameter WIDTH = 4
)
(
    input                clk,
    input                rst,

    input                up_valid,
    output               up_ready,
    input  [ WIDTH-1:0 ] n_tokens,

    output               down_valid,
    input                down_ready,
    output               down_token
);

    // Ваш код здесь
    logic [ WIDTH - 1:0 ] cnt;

    assign   up_ready = cnt == 0;
    assign down_valid = '1;
    assign down_token = cnt > 0;

    // Counter loading
    always @ ( posedge clk or posedge rst )
        if      ( rst )                 cnt <= 0;
        else if ( up_valid & up_ready ) cnt <= n_tokens;

    // Counter releasing
    always @ ( posedge clk )
        if ( down_valid & down_ready & ( cnt > 0 ) ) cnt <= cnt - 1;
        
endmodule