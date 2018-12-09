`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/08 19:46:47
// Design Name: 
// Module Name: pipeline_exec2mem
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

module pipeline_exec2mem #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5,
    parameter FREE_LIST_WIDTH = 3
)(
    input clk,
    input rst_n,
    input flush,
    input stall,
    
    input      [`DATA_BUS] alu_res_in,
    output reg [`DATA_BUS] alu_res_out
    );

    always @(posedge clk, negedge rst_n)
    begin
        if (!rst_n)
        begin
            alu_res_out <= 0;
        end
        else
        begin
            if (!stall)
            begin
                if (flush)
                begin
                    alu_res_out <= 0;
                end
                else
                begin
                    alu_res_out <= alu_res_in;
                end
            end
        end
    end
endmodule
