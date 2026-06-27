module serial_divisibility_by_5_using_fsm (
  input  logic clk,
  input  logic rst,
  input  logic new_bit,
  output logic div_by_5
);

  // Ваш код здесь
    typedef enum logic [ 2:0 ] {
        MOD_0 = 'b000,
        MOD_1 = 'b001,
        MOD_2 = 'b010,
        MOD_3 = 'b011,
        MOD_4 = 'b100
    } mod_states;

    mod_states state, next_state;

    always_ff @( posedge clk or posedge rst )
        if ( rst ) state <= MOD_0;
        else       state <= next_state;

    always_comb begin
        next_state = state;

        case ( state )
            MOD_0: if (  new_bit ) next_state = MOD_1;
            MOD_1: if (  new_bit ) next_state = MOD_3;
                   else            next_state = MOD_2;
            MOD_2: if (  new_bit ) next_state = MOD_0;
                   else            next_state = MOD_4;
            MOD_3: if (  new_bit ) next_state = MOD_2;
                   else            next_state = MOD_1;
            MOD_4: if ( !new_bit ) next_state = MOD_3;
        endcase
    end

    assign div_by_5 = state == MOD_0;

endmodule