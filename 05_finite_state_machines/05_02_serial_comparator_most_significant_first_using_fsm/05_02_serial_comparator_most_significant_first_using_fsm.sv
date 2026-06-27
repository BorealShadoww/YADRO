module serial_comparator_most_significant_first_using_fsm (
  input  logic clk,
  input  logic rst,
  input  logic a,
  input  logic b,
  output logic a_less_b,
  output logic a_eq_b,
  output logic a_greater_b
);

  // Ваш код здесь
    typedef enum logic [ 2:0 ] {
        EQUAL       = 'b010,
        A_LESS_B    = 'b100,
        A_GREATER_B = 'b001
    } comp_states;

    comp_states state, next_state;

    wire [ 1:0 ] ab = { a , b };

    always_ff @( posedge clk or posedge rst )
        if ( rst ) state <= EQUAL;
        else       state <= next_state;

    always_comb begin
        next_state = state;

        case ( state )
            EQUAL:   if ( ab == 'b01 ) next_state = A_LESS_B;
                else if ( ab == 'b10 ) next_state = A_GREATER_B;
        endcase
    end

    assign { a_less_b , a_eq_b , a_greater_b } = next_state;

endmodule