module shift_register_with_valid
# (
    parameter width = 8, depth = 8
)
(
    input  logic              clk,
    input  logic              rst,

    input  logic              in_vld,
    input  logic              [width - 1:0] in_data,

    output logic              out_vld,
    output logic              [width - 1:0] out_data
);

    // Ваш код здесь
    // Two shift regs definition
    logic [ width - 1:0 ] data [ 0:depth - 1 ];
    logic [ depth - 1:0 ] data_vld;

    // Shifting of valids
    always_ff @ ( posedge clk )
        if ( rst )
            data_vld <= '0;
        else
            data_vld <= { data_vld [depth - 2:0] , in_vld };

    assign out_vld = data_vld [depth - 1];
    
    // Shifting of data
    always_ff @ ( posedge clk )
        begin
            data [0] <= in_data;

            for ( int i = 1 ; i < depth ; i++ )
                data [i] <= data [ i - 1 ];
        end

    assign out_data = data [ depth - 1 ];

endmodule