`timescale 1ns / 1ps

 module counter (
    // peripheral clock signals
    input clk,
    input rst_n,
    // register facing signals
    output[15:0] count_val,
    input[15:0] period,
    input en,
    input count_reset,
    input upnotdown,
    input[7:0] prescale
);
 
 reg [15:0]count_val_r = 0;
	//variabila interna pentru numararea cicliclor de ceas 
	//necesari pt incrementare/decrementare 
 reg [7:0]internal_prescale = 0;
 
 assign count_val = count_val_r;
 
 always @(posedge clk) begin
	//reset 
    if(!rst_n) begin
        count_val_r <= 0;
        internal_prescale <= 0;
    end
    else if(count_reset) begin
        count_val_r <= 0;
        internal_prescale <= 0;
    end
	//pentru cazul in care numaratorul este activ
    else if(en) begin 
	//incrementarea numarului de ciclii de ceas
        if(internal_prescale !=  prescale) begin
            internal_prescale <= internal_prescale + 1;
        end
	//daca au trecut ciclii de ceas necesari se face incrementarea/decrementarea
        else begin
		//reinitializarea variabilei interne pentru numararea cicliclor de ceas 
            internal_prescale <= 0;
		//logica pentru numararea in sus
            if(upnotdown) begin
                if(count_val_r >= period) begin
                    count_val_r <= 0;
                end
                else begin
                    count_val_r <= count_val_r + 1;
                end
            end
		//logica pentru numararea in jos
            else begin
                if(count_val_r == 0) begin
                    count_val_r <= period;
                end
                else begin
                    count_val_r <= count_val_r - 1;
                end
            end
        end
       end
    end
endmodule