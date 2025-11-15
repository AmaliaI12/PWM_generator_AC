module pwm_gen (
    // peripheral clock signals
    input clk,
    input rst_n,
    // PWM signal register configuration
    input pwm_en,
    input[15:0] period,
    input[7:0] functions,
    input[15:0] compare1,
    input[15:0] compare2,
    input[15:0] count_val,
    // top facing signals
    output pwm_out
);

    // wire variables that determine the alignment of the pwm signal based on functions
    wire is_aligned_left = (functions[1:0] == 2'b00);
    wire is_aligned_right = (functions[1:0] == 2'b01);
    wire is_unaligned = (functions[1] == 1'b1);

    // reg variables that track the current state and the next state of the pwm signal
    reg pwm_next_state;
    reg pwm_current_state;

    assign pwm_out = pwm_current_state;

    // Combinational logic
    always @(*) begin
        if (pwm_en) begin
            if (is_unaligned) begin
                pwm_next_state = (count_val >= compare1) && (count_val < compare2);
            end
            else if (is_aligned_left) begin
                pwm_next_state = (count_val < compare1);
            end
            else if (is_aligned_right) begin
                pwm_next_state = (count_val >= compare1);
            end
        end
        else begin
            pwm_next_state = pwm_current_state;
        end
    end

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_current_state <= 1'b0;
        end
        else begin
            pwm_curren_state <= pwm_next_state;
        end
    end

endmodule