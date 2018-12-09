`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/15 23:59:12
// Design Name: 
// Module Name: bcd_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bcd_encoder(input enable, input [3:0] S, output reg [6:0] T);
    always @*
    begin
        case (S) //      abcdefg
            4'h0: T <= 7'b0000001;
            4'h1: T <= 7'b1001111;
            4'h2: T <= 7'b0010010;
            4'h3: T <= 7'b0000110;
            4'h4: T <= 7'b1001100;
            4'h5: T <= 7'b0100100;
            4'h6: T <= 7'b0100000;
            4'h7: T <= 7'b0001111;
            4'h8: T <= 7'b0000000;
            4'h9: T <= 7'b0000100;
            4'hA: T <= 7'b0001000;
            4'hb: T <= 7'b1100000;
            4'hC: T <= 7'b0110001;
            4'hd: T <= 7'b1000010;
            4'hE: T <= 7'b0110000;
            4'hF: T <= 7'b0111000; 
            default: T <= 7'b1111110; // negative sign
       endcase
    end
endmodule
