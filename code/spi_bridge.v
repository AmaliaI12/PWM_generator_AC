`default_nettype none
`timescale 1ns/1ns

module spi_bridge (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sclk,
    input  wire       cs_n,
    input  wire       mosi,
    output wire       miso,
    output wire       byte_sync,
    output wire [7:0] data_in,
    input  wire [7:0] data_out
);

    // RX
    reg [7:0] in_shift_reg; // Shift register pentru a strange bitii de pe mosi
    reg [2:0] bit_counter;
    reg [7:0] full_byte; // Byte complet primit stocat pentru transfer in clk
    reg       in_toggle;   // Schimba starea cu fiecare byte citit

    always @(posedge sclk or posedge cs_n or negedge rst_n) begin
        if (!rst_n) begin
            in_shift_reg  <= 8'h00;
            bit_counter    <= 3'd0;
            full_byte   <= 8'h00;
            in_toggle <= 1'b0;
        end else if (cs_n) begin
            in_shift_reg <= 8'h00;
            bit_counter   <= 3'd0;
        end else begin
            in_shift_reg <= {in_shift_reg[6:0], mosi}; // Ia urmatorul bit si il pune in shift s
            if (bit_counter == 3'b111) begin
                full_byte   <= {in_shift_reg[6:0], mosi}; // Stocam byte ul citit
                in_toggle <= ~in_toggle;   // Marcam ca a fost primit un byte
                bit_counter    <= 3'd0; // Resetam contorul
            end else begin
                bit_counter <= bit_counter + 3'd1; // Incrementam contorul, a fost adaugat un bit
            end
        end
    end


    // Sincronizare cu doua flip-flop-uri pentru a evita metastabilitatea
    reg t1, t2;
    reg cs1, cs2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            t1 <= 1'b0; t2 <= 1'b0;
            cs1 <= 1'b1; cs2 <= 1'b1;
        end else begin
            t1 <= in_toggle; // t1 ia starea curenta
            t2 <= t1; // t2 ia starea anterioara
            cs1 <= cs_n;
            cs2 <= cs1;
        end
    end

    wire byte_event = (t1 ^ t2); // Un byte nou primit

    // Registre interne pentru iesiri
    reg [7:0] data_in_reg;
    reg       byte_sync_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_reg   <= 8'h00;
            byte_sync_reg <= 1'b0;
        end else begin
            byte_sync_reg <= 1'b0;
            if (!cs2 && byte_event) begin
                data_in_reg   <= full_byte;
                byte_sync_reg <= 1'b1;
            end
        end
    end

    assign data_in   = data_in_reg;
    assign byte_sync = byte_sync_reg;


   // TX
    reg [7:0] out_shift_reg;
    always @(negedge cs_n or negedge rst_n) begin
        if (!rst_n) 
            out_shift_reg <= 8'h00;
        else        
            out_shift_reg <= data_out;
    end

    always @(negedge sclk or posedge cs_n or negedge rst_n) begin
        if (!rst_n) begin
            out_shift_reg <= 8'h00;
        end else if (!cs_n) begin
            out_shift_reg <= {out_shift_reg[6:0], 1'b0}; // Shift out MSB
        end
    end
    assign miso = out_shift_reg[7];

endmodule

`default_nettype wire