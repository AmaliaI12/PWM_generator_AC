`timescale 1ns/1ps
`default_nettype none

module instr_dcd(
    // peripheral clock signals
    input wire clk,
    input wire rst_n,
    // towards SPI slave interface signals
    input wire byte_sync,
    input wire [7:0] data_in,
    output wire [7:0] data_out,
    // register access signals
    output wire read,
    output wire write,
    output wire [5:0] addr,
    input wire [7:0] data_read,
    outputwire [7:0] data_write
);

    // o sa avem doua stari 0 si 1 
    // 0 =  suntem in faza de setup 
    // 1 = suntem in faza de date 
    reg state;
    reg rw_latched;     // 1=write, 0=read
    reg [5:0] addr_r;
    reg [7:0] data_out_r;
    reg [7:0] data_write_r;
    reg write_pending;
    reg write_r;
    reg read_r;

    assign addr = addr_r;
    assign data_out = data_out_r;
    assign data_write = data_write_r;
    assign write = write_r;
    assign read  = read_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 1'b0;
            rw_latched <= 1'b0;
            addr_r <= 6'd0;
            data_out_r <= 8'h00;
            data_write_r <= 8'h00;
            write_pending <= 1'b0;
            write_r <= 1'b0;
            read_r <= 1'b0;
        end else begin
            write_r <= 1'b0;
            read_r <= 1'b0;

            if (write_pending) begin
                write_r <= 1'b1;
                write_pending <= 1'b0;
            end

            if (byte_sync) begin // daca a fost trimis un nou byte
                if (!state) begin // daca suntem in faza de date
                    state <= 1'b1; 
                    rw_latched <= data_in[7];
                    addr_r <= data_in[5:0];
		    // pt citire imediat
                    if (!data_in[7])
                        data_out_r <= data_read;

                    end 
		    else begin // daca suntem in faza de date
                    state <= 1'b0;
                    if (rw_latched) begin
                        data_write_r <= data_in; //trimitere date catre registru pentru a fi scrise
                        write_pending <= 1'b1;
                    end else begin 
                        read_r <= 1'b1;
                        data_out_r <= data_read; //citire date din registru pentru a fi trimise catre spi bridge
                    end
                end
            end
        end
    end

endmodule

`default_nettype wire