`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sun Yat-sen University
// Engineer: Yuhui Huang
// 
// Create Date: 2018/05/24 14:07:49
// Design Name: Pipeline Controller
// Module Name: pipeline
// Project Name: SimpleCPU
// Target Devices: Basys3
// Tool Versions: Vivado 2018.1
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   See https://en.wikipedia.org/wiki/Classic_RISC_pipeline
//   https://www.cs.cmu.edu/afs/cs/academic/class/15740-f97/public/info/pipeline-slide.pdf
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module pipeline#(parameter DATA_WIDTH = 32)(
    input clk,
    input rst_n,

    // execute
    input exec_mem_enable,
    input exec_wb_reg,
    input exec_take_branch,
    input [`DATA_BUS] exec_branch_target,

    // ======= Control Hazards ========
    output reg fetch_branch,
    output reg [`DATA_BUS] fetch_branch_target
    );
    
    wire fetch_done = `TRUE;

    reg [`DATA_BUS] fetch_addr;

    // ===============
    // Control Hazards
    // ===============

    always @*
    begin
        fetch_branch <= exec_take_branch;
        if (exec_take_branch)
            fetch_branch_target <= exec_branch_target;
        else // will not be taken
            fetch_branch_target <= fetch_addr;
    end

endmodule
