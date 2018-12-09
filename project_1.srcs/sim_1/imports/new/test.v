`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/26 11:09:24
// Design Name: 
// Module Name: test
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

module test;
    
    // input
    reg clk;
    reg rst_n;
    
    // output
    wire [31:0] inst;
    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] alu_res;
    wire [31:0] write_data;
    wire [4:0] write_addr;
    wire write_en;
    wire [4:0] rs_addr;
    wire [31:0] rs_data;
    wire [4:0] rt_addr;
    wire [31:0] rt_data;
    wire [31:0] imm;
    wire [31:0] br_tgt;
    wire [31:0] mem_read;
    wire [`ALU_OP_BUS] alu_op;
    wire zero;
    wire b_ctrl;
    wire [`JUMP_BUS] jump;
    wire take_branch;
    wire fetch_rw;
    wire [`STATE_BUS] state, next_state;
    
    main main(
        .clk(clk),
        .rst_n(rst_n),
        .inst(inst),
        .pc(pc),
        .next_pc(next_pc),
        .alu_res(alu_res),
        .reg_write_data(write_data),
        .reg_write_addr(write_addr),
        .reg_write_en(write_en),
        .rs_addr(rs_addr),
        .rs_data(rs_data),
        .rt_addr(rt_addr),
        .rt_data(rt_data),
        .imm(imm),
        .branch_target(br_tgt),
        .mem_read(mem_read),
        .alu_op(alu_op),
        .zero(zero),
        .b_ctrl(b_ctrl),
        .jump(jump),
        .take_branch(take_branch),
        .fetch_rw(fetch_rw),
        .state(state),
        .next_state(next_state));
        
    initial 
    begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        #5;
            rst_n = 1;
        #5
        clk = !clk;
        forever #10 
        begin
            clk = !clk;
        end
    end
        
endmodule
