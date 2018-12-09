`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sun Yat-sen University
// Engineer: Yuhui Huang
// 
// Design Name: Execution Stage Controller
// Module Name: execution
// Project Name: SimpleCPU
// Target Devices: Basys3
// Tool Versions: Vivado 2018.1
// Description: 
//
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module execution#(parameter DATA_WIDTH = 32)(
    input clk,
    input rst_n,
    input stall,

    input [`ALU_OP_WIDTH-1:0] alu_op,
    input [`DATA_BUS] alu_rs,
    input [`DATA_BUS] alu_rt,

    input [1:0] jump,
    
    // Output ports

    output [`DATA_BUS] res,
    output take_branch
);
    wire [`DATA_BUS] alu_rd, move_res;

    assign take_branch = jump == `JUMP_COND && alu_rd;

    assign res = alu_rd;

    // ==== Data forwarding ===

    arithmetic_logic_unit #(.DATA_WIDTH(DATA_WIDTH)) alu(
        .stall(stall),
        .op(alu_op),
        .rs(alu_rs),
        .rt(alu_rt),
        .rd(alu_rd)
    );
endmodule