`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/07 11:20:00
// Design Name: 
// Module Name: pipeline_mem2wb
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

module pipeline_mem2wb #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 18,
    parameter REG_ADDR_WIDTH = 5,
    parameter FREE_LIST_WIDTH = 3
)(
    input      clk,
    input      rst_n,
    input      flush,
    input      stall,

    input      wb_reg_in,
    output reg wb_reg_out,
    input      [`DATA_BUS] wb_data_in,
    output reg [`DATA_BUS] wb_data_out,
    input      [`VREG_BUS] write_addr_in,
    output reg [`VREG_BUS] write_addr_out

    );

    always @(posedge clk, negedge rst_n)
    begin
        if (!rst_n)
        begin
            wb_reg_out <= 0;
            wb_data_out <= 0;
            write_addr_out <= 0;
        end
        else
        begin
            if (flush)
            begin
                wb_reg_out <= 0;
                wb_data_out <= 0;
                write_addr_out <= 0;
            end
            else if (!stall)
            begin
                wb_reg_out <= wb_reg_in;
                wb_data_out <= wb_data_in;
                write_addr_out <= write_addr_in;
            end
        end
    end
endmodule

