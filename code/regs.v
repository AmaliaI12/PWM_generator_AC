module regs (
    // peripheral clock signals
    input clk,
    input rst_n,
    // decoder facing signals
    input read,
    input write,
    input[5:0] addr,
    output[7:0] data_read,
    input[7:0] data_write,
    // counter programming signals
    input[15:0] counter_val,
    output[15:0] period,
    output en,
    output count_reset,
    output upnotdown,
    output[7:0] prescale,
    // PWM signal programming values
    output pwm_en,
    output[7:0] functions,
    output[15:0] compare1,
    output[15:0] compare2
);

    /*
    All registers that appear in this block should be similar to this. Please try to abide
    to sizes as specified in the architecture documentation.
*/
    // reg variables for counter programming signals
    reg[15:0] reg_period;
    reg reg_en;
    reg reg_count_reset;
    reg reg_upnotdown;
    reg[7:0] reg_prescale;
    // reg variables for PWM signal programming values
    reg reg_pwm_en;
    reg[7:0] reg_functions;
    reg[15:0] reg_compare1;
    reg[15:0] reg_compare2;
    // reg variable for decoder facing signal data_read
    reg[7:0] reg_data_read;
    // reg variable to track the 2-cycle duration of the counter reset
    reg[1:0] count_reset_cycles;

    assign period = reg_period;
    assign en = reg_en;
    assign count_reset = reg_count_reset;
    assign upnotdown = reg_upnotdown;
    assign prescale = reg_prescale;

    assign pwm_en = reg_pwm_en;
    assign functions = reg_functions;
    assign compare1 = reg_compare1;
    assign compare2 = reg_compare2;

    assign data_read = reg_data_read;

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_period <= 16'h0000;
            reg_en <= 1'b0;
            reg_count_reset <= 1'b0;
            reg_upnotdown <= 1'b0;
            reg_prescale <= 8'h00;
            reg_pwm_en <= 1'b0;
            reg_functions <= 8'h00;
            reg_compare1<= 16'h0000;
            reg_compare2 <= 16'h0000;
            reg_data_read <= 8'h00;
            count_reset_cycles <= 2'b00;
        end else begin
            // Here should be the rest of the implementation

            // Write logic
            if (write) begin
                case (addr)
                    6'h00: reg_period[7:0] <= data_write; //writes to the LSB section of the 16 bit register
                    6'h01: reg_period[15:8] <= data_write; //writes to the MSB section of the 16 bit register
                    6'h02: reg_en <= data_write[0];
                    6'h03: reg_compare1[7:0] <= data_write;
                    6'h04: reg_compare1[15:8] <= data_write;
                    6'h05: reg_compare2[7:0] <= data_write;
                    6'h06: reg_compare2[15:8] <= data_write;
                    6'h07: begin
                        reg_count_reset <= data_write[0];
                        if (data_write[0]) begin
                            count_reset_cycles <= 2'b10;
                        end
                    end
                    6'h0A: reg_prescale <= data_write;
                    6'h0B: reg_upnotdown <= data_write[0];
                    6'h0C: reg_pwm_en <= data_write[0];
                    6'h0D: reg_functions <= data_write;
                    default: ;
                endcase
            end

            // Read logic
            if (read) begin
                case (addr)
                    6'h00: reg_data_read <= reg_period[7:0]; //reads from the LSB section of the 16 bit register
                    6'h01: reg_data_read <= reg_period[15:8]; //reads from the MSB section of the 16 bit register
                    6'h02: reg_data_read <={7'b0, reg_en};
                    6'h03: reg_data_read <=reg_compare1[7:0];
                    6'h04: reg_data_read <= reg_compare1[15:8];
                    6'h05: reg_data_read <=reg_compare2[7:0];
                    6'h06: reg_data_read <= reg_compare2[15:8];
                    6'h08: reg_data_read <=counter_val[7:0];
                    6'h09: reg_data_read <= counter_val[15:8];
                    6'h0A: reg_data_read <=reg_prescale;
                    6'h0B: reg_data_read <={7'b0, reg_upnotdown};
                    6'h0C: reg_data_read <={7'b0, reg_pwm_en};
                    6'h0D: reg_data_read <= reg_functions;
                    default: reg_data_read <= 8'h00;
                endcase
            end

            // Counter reset logic
            if (count_reset_cycles != 2'b00) begin
                if (count_reset_cycles == 2'b01) begin
                    reg_count_reset <= 1'b0;
                end
                count_reset_cycles <= count_reset_cycles - 1'b1;
            end
        end
    end
endmodule