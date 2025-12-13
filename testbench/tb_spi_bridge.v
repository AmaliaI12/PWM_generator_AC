module tb_spi_bridge;

    reg clk = 0;
    always #10 clk = ~clk;

    reg rst_n;
    reg sclk;
    reg cs_n;
    reg mosi;
    wire miso;

    wire byte_sync;
    wire [7:0] data_in;
    reg  [7:0] data_out;

    spi_bridge dut (
        .clk(clk),
        .rst_n(rst_n),
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .miso(miso),
        .byte_sync(byte_sync),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        rst_n = 0;
        cs_n  = 1;
        sclk  = 0;
        mosi  = 0;
        data_out = 8'hA5;  // ce trimite slave-ul

        #100 rst_n = 1;

        // START SPI
        #50 cs_n = 0;

        spi_send_byte(8'h3C);
        
        #500
     
        spi_send_byte(8'hF0);
        
        #100
        
        spi_send_byte (8'hFF);
        
        #100
        spi_send_byte(8'hAB);
        
        data_out = 8'hD3;
        
        #100

        #50 cs_n = 1;

        #200 $finish;
    end

    task spi_send_byte(input [7:0] tx);
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                mosi = tx[i];
                #20 sclk = 1;
                #20 sclk = 0;
            end
        end
    endtask

    always @(posedge clk) begin
        if (byte_sync)
            $display("Time %0t | RX = 0x%02h", $time, data_in);
    end

endmodule
