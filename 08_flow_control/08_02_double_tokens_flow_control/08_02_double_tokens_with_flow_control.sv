module double_tokens_with_flow_control
(
    input  clk,
    input  rst,

    input  up_valid,
    output up_ready,
    input  up_token,

    output down_valid,
    input  down_ready,
    output down_data
);

  // Task:
  // Implement module double input signals (tokens). The module must use signals valid-ready for
  // transfer tokens. If the module receives more than 100 sequential tokens then it must set up_ready = 0;

  logic [ 106:0 ]  doubled_token_buffer;
  logic [  99:0 ] original_token_buffer;

  assign up_ready   = ~original_token_buffer[ 99 ];
  assign down_valid = down_ready | up_valid;
  assign down_data  = ( doubled_token_buffer[ 0 ] | original_token_buffer[ 0 ] | ( up_token & up_valid ) );

  // Buffer loading
  always @ ( posedge clk or posedge rst )
    if   ( rst ) begin
       doubled_token_buffer <= '0;
      original_token_buffer <= '0;
    end
    else if ( up_valid & up_ready & up_token ) begin
                          doubled_token_buffer <= {  doubled_token_buffer[ 105:0 ] , 1'b1 };
      if ( ~down_ready ) original_token_buffer <= { original_token_buffer[  99:0 ] , 1'b1 };
    end
  
  // Buffer releasing
  always @ ( posedge clk )
    if ( ~up_token & down_ready )
      if      ( original_token_buffer != 0 ) original_token_buffer <= { '0 , original_token_buffer[  99:1 ] };
      else if (  doubled_token_buffer != 0 )  doubled_token_buffer <= { '0 ,  doubled_token_buffer[ 106:1 ] };

endmodule