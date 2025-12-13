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

    wire sclk_sync = sclk2;
    wire cs_sync = cs2;    
    wire sclk_rise =  sclk2 & ~sclk1;
    wire sclk_fall = ~sclk2 &  sclk1; 

    
    reg [7:0] shift_reg_in;
    reg [2:0] bit_count; //counts bits recieved
    reg [7:0] data_in_reg; 
    reg byte_sync_reg;
    
    always @(posedge  clk or negedge rst_n) begin
        if(!rst_n) begin //reset
            shift_reg_in <= 0;
            bit_count <= 0;
            data_in_reg <= 0;
            byte_sync_reg <= 0;
        end else begin
            byte_sync_reg <= 1'b0;
            if(cs_sync) begin
                bit_count  <= 0; //reset counter when cs is inactive
            end else if(sclk_rise) begin
                shift_reg_in <= {shift_reg_in[6:0], mosi2};
                bit_count <= bit_count + 1'b1;
                
                if (bit_count == 3'd7) begin
                    data_in_reg <= {shift_reg_in[6:0], mosi2};
                    byte_sync_reg <= 1;
                end
            end
        end
    end

    assign data_in = data_in_reg;
    assign byte_sync = byte_sync_reg;
    
    reg[7:0] shift_reg_out;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n ) begin
            shift_reg_out <= 0;
        end else if(cs_sync) begin
            shift_reg_out <= data_out;
        end else if(sclk_fall) begin
            shift_reg_out <= {shift_reg_out[6:0], 1'b0};
        end
    end
    
      assign miso = shift_reg_out[7];
      

endmodule