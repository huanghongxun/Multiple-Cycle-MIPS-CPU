`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/07 00:34:54
// Design Name: 
// Module Name: pipeline_dec2exec
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

module pipeline_dec2exec #(
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rst_n,
    input flush,
    input stall,
    
    input      [`INST_BUS] inst_in,
    output reg [`INST_BUS] inst_out,
    input      [`ALU_OP_BUS] alu_op_in,
    output reg [`ALU_OP_BUS] alu_op_out,
    input            [1:0] exec_src_in,
    output reg       [1:0] exec_src_out,
    input      [`DATA_BUS] alu_rs_in,
    output reg [`DATA_BUS] alu_rs_out,
    input      [`DATA_BUS] alu_rt_in,
    output reg [`DATA_BUS] alu_rt_out, // must process b_ctrl
    input                  mem_rw_in,
    output reg             mem_rw_out,
    input                  mem_enable_in,
    output reg             mem_enable_out,
    input      [`DATA_BUS] mem_write_in,
    output reg [`DATA_BUS] mem_write_out,
    input                  wb_src_in,
    output reg             wb_src_out,
    input                  wb_reg_in,
    output reg             wb_reg_out,
    input      [`VREG_BUS] virtual_write_addr_in,
    output reg [`VREG_BUS] virtual_write_addr_out,
    input      [1:0] jump_in,
    output reg [1:0] jump_out
    );

    always @(posedge clk, negedge rst_n)
    begin
        if (!rst_n)
        begin
            inst_out <= 0;
            alu_op_out <= 0;
            exec_src_out <= 0;
            alu_rs_out <= 0;
            alu_rt_out <= 0;
            mem_rw_out <= 0;
            mem_enable_out <= 0;
            mem_write_out <= 0;
            wb_src_out <= 0;
            wb_reg_out <= 0;
            virtual_write_addr_out <= 0;
            jump_out <= 0;
        end
        else
        begin
            if (flush)
            begin
                inst_out <= 0;
                alu_op_out <= 0;
                exec_src_out <= 0;
                alu_rs_out <= 0;
                alu_rt_out <= 0;
                mem_rw_out <= 0;
                mem_enable_out <= 0;
                mem_write_out <= 0;
                wb_src_out <= 0;
                wb_reg_out <= 0;
                virtual_write_addr_out <= 0;
                jump_out <= 0;
            end
            else if (!stall)
            begin
                inst_out <= inst_in;
                alu_op_out <= alu_op_in;
                exec_src_out <= exec_src_in;
                alu_rs_out <= alu_rs_in;
                alu_rt_out <= alu_rt_in;
                mem_rw_out <= mem_rw_in;
                mem_enable_out <= mem_enable_in;
                mem_write_out <= mem_write_in;
                wb_src_out <= wb_src_in;
                wb_reg_out <= wb_reg_in;
                virtual_write_addr_out <= virtual_write_addr_in;
                jump_out <= jump_in;
            end
        end
    end
endmodule
