`timescale 10ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/17 15:39:50
// Design Name: 
// Module Name: clock_div
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

module clock_div #(
    parameter N = 2,
    parameter WIDTH = 8
)(  
    input clk,
    input rst_n,
    output reg clk_out
    );

    reg [WIDTH-1 : 0] cnt;
    always @(posedge clk, negedge rst_n)
    begin
        if (!rst_n)
            cnt <= 0;
        else
        begin
            if (cnt == N - 1)
            begin
                cnt <= 0;
            end
            else
            begin
                cnt <= cnt + 1;
            end
        end
    end
    
    always @(posedge clk, negedge rst_n)
    begin
        if (!rst_n)
            clk_out <= 0;
        else
            if (cnt == N - 1) begin
                clk_out <= !clk_out;
            end
    end
  
endmodule  