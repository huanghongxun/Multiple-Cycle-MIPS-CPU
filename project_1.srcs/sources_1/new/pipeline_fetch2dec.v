`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/07 10:52:22
// Design Name: 
// Module Name: pipeline_fetch2dec
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

`include "defines.v"

module pipeline_fetch2dec #(
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rst_n,
    input flush,
    input stall,

    input      [`DATA_BUS] pc_in,
    output reg [`DATA_BUS] pc_out,
    input      [`DATA_BUS] inst_in,
    output reg [`DATA_BUS] inst_out
    );

    always @(posedge clk, negedge rst_n)
    begin
        if (!rst_n)
        begin
            pc_out <= 0;
            inst_out <= 0;
        end
        else
        begin
            if (flush)
            begin
                pc_out <= 0;
                inst_out <= 0;
            end
            else if (!stall)
            begin
                pc_out <= pc_in;
                inst_out <= inst_in;
            end
        end
    end
endmodule