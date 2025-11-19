module spi_bridge (
    // peripheral clock signals
    input clk,
    input rst_n,
    // SPI master facing signals
    input sclk,
    input cs_n,
    input mosi,
    output miso,
    // internal facing 
    output byte_sync,
    output[7:0] data_in,
    input[7:0] data_out
);

  // synchronise sclk, cs_n and mosi using two flip flops to avoid metastable state
    reg sclk1, sclk2;
    reg cs1, cs2;
    reg mosi1, mosi2;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sclk1 <= 0;
            sclk2 <= 0;
            cs1 <= 1;
            cs2 <= 1;
            mosi1 <=0;
            mosi2 <= 0;
        end else begin
            sclk1 <= sclk;
            sclk2 <= sclk1;
            cs1 <= cs_n;
            cs2 <= cs1;
            mosi1 <=mosi;
            mosi2 <= mosi1;
        end
    end

endmodule