
`timescale 1ns / 1ps

module instr_dcd(
    // peripheral clock signals
    input clk,
    input rst_n,
    // towards SPI slave interface signals
    input byte_sync,
    input[7:0] data_in,
    output[7:0] data_out,
    // register access signals
    output read,
    output write,
    output[5:0] addr,
    input[7:0] data_read,
    output[7:0] data_write
    );
    
    // o sa avem doua stari 0 si 1 
    // 0 =  suntem in faza de setup 
    // 1 = suntem in faza de date 
    
    reg state; 
    reg read_r;
    reg write_r;
    reg [5:0]addr_r;
    reg [7:0] data_out_r;
    reg [7:0] data_write_r;
    
    assign read = read_r;
    assign write = write_r;
    assign addr = addr_r;
    assign data_out = data_out_r;
    assign data_write = data_write_r;
    
    always @(posedge clk) begin
        if(!rst_n) begin
            state <= 0;
            read_r <= 0;
            write_r <= 0;
            addr_r <= 0;
            data_write_r <= 0;
            data_out_r <= 0;
        end else begin
            if(byte_sync) begin // daca a fost trimis un nou byte
                if(!state) begin // daca suntem in faza de setup
                    state <= 1;
                    write_r <= data_in[7];
                    read_r <= ~data_in[7];
                    
                    //setam adresa in functie de high/low
                    case(data_in[5:0])
                        6'h00,                  //daca adresa trimisa face parte dintr-un registru
                        6'h03,                 //[15:0]
                        6'h05,
                        6'h08: begin
                            addr_r <= data_in[5:0] + (data_in[6] ? 6'd1 : 6'd0);    
                             //daca hl este 1 (MSB) vrem adresa de baza + 1
                            //daca hl este 0 (LSB) ramane adresa de baza
                        end
                        
                        default: begin //daca adresa trimisa face parte dintr un registru [7:0]
                            addr_r <= data_in[5:0];  //adresa ramane cea de baza
                        end
                     endcase
                    
                end
                else begin // daca suntem in faza de date
                    if(write_r) begin
                        data_write_r <= data_in; //trimitere date catre registru pentru a fi scrise
                    end
                    else begin
                        data_out_r <= data_read; //citire date din registru pentru a fi trimise catre spi bridge
                    end
                    state <= 0;
                end
            end
        end
    end
  endmodule