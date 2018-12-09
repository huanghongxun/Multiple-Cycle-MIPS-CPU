`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/25 09:12:25
// Design Name: 
// Module Name: main
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

module main(
    input clk,
    input rst_n,
    
    output [31:0] inst,
    output [31:0] pc,
    output [31:0] next_pc,
    output [31:0] alu_res,
    output [31:0] reg_write_data,
    output [4:0] reg_write_addr,
    output [31:0] reg_write_read,
    output reg_write_en,
    output [4:0] rs_addr,
    output [31:0] rs_data,
    output [4:0] rt_addr,
    output [31:0] rt_data,
    output [31:0] imm,
    output [31:0] branch_target,
    output [31:0] mem_read,
    output [`ALU_OP_BUS] alu_op,
    output zero,
    output b_ctrl,
    output [`JUMP_BUS] jump,
    output take_branch,
    output fetch_rw,
    output [`STATE_BUS] state,
    output [`STATE_BUS] next_state);
    
    localparam DATA_WIDTH = 32;
    localparam DATA_PER_BYTE_WIDTH = 2;
    
    // wire fetch_rw;
    wire [`DATA_BUS] fetch_write;
    wire [`DATA_BUS] fetch_pc;
    wire [`DATA_BUS] fetch_next_pc;
    wire [`DATA_BUS] imem_data;
    
    wire [`DATA_BUS] dec_pc;
    wire [`RAW_INST_BUS] dec_raw_inst;
    wire [`VREG_BUS] dec_vrs_addr;
    wire [`VREG_BUS] dec_vrt_addr;
    wire [`DATA_BUS] dec_rs_data;
    wire [`DATA_BUS] dec_rt_data;
    wire [`VREG_BUS] dec_write_addr;
    wire [`INST_BUS] dec_inst;
    wire [`DATA_BUS] dec_branch_target;
    wire [`ALU_OP_BUS] dec_exec_op;
    wire dec_b_ctrl;
    wire dec_mem_enable;
    wire [`DATA_BUS] dec_imm;
    wire dec_wb_src;
    wire dec_wb_reg;
    wire dec_illegal;
    wire [1:0] dec_jump;
    
    wire [`INST_BUS] exec_inst;
    wire exec_mem_enable;
    wire [`DATA_BUS] exec_mem_write;
    wire exec_wb_src;
    wire exec_wb_reg;
    wire [1:0] exec_jump;
    wire [`ALU_OP_BUS] exec_alu_op;
    wire [`DATA_BUS] exec_alu_rs;
    wire [`DATA_BUS] exec_alu_rt;
    wire [`DATA_BUS] exec_res;
    wire exec_take_branch; // conditional branch inst taken

    wire [`DATA_BUS] dmem_res;
    reg  [`DATA_BUS] dmem_write; // DBDR
    wire dmem_wb_src = exec_wb_src;
    
    wire [`DATA_BUS] dmem_mem_read;
    wire [`DATA_BUS] dmem_mem_read_raw;
    wire [`DATA_BUS] dmem_mem_write;
    wire [3:0] dmem_mem_sel;
    wire dmem_mem_enable = exec_mem_enable;
    wire dmem_mem_rw;
    wire dmem_ready;
    wire dmem_mem_rw_valid;

    wire [`VREG_BUS] wb_write_addr;
    wire [`DATA_BUS] wb_write;
    wire wb_wb_reg;
    
    assign inst = imem_data;
    assign pc = fetch_pc;
    assign next_pc = fetch_next_pc;
    assign alu_res = exec_res;
    assign reg_write_data = dec_inst == `INST_JAL ? dec_imm : wb_write;
    assign reg_write_addr = dec_inst == `INST_JAL ? dec_write_addr : wb_write_addr;
    assign reg_write_en = dec_wb_reg;
    assign rs_addr = dec_vrs_addr;
    assign rs_data = dec_rs_data;
    assign rt_addr = dec_vrt_addr;
    assign rt_data = dec_rt_data;
    assign imm = dec_imm;
    assign branch_target = dec_branch_target;
    assign mem_read = dmem_mem_read;
    assign alu_op = exec_alu_op;
    assign zero = exec_res == 0;
    assign b_ctrl = dec_b_ctrl;
    assign jump = dec_jump;
    assign take_branch = exec_take_branch;
    
    assign fetch_rw = exec_take_branch || dec_jump == `JUMP_REG || dec_jump == `JUMP;
    assign fetch_write = dec_branch_target;
    
    state_unit su(
        .clk(clk),
        .rst_n(rst_n),
        
        .inst(dec_inst),
        .mem_enable(dec_mem_enable),
        
        .state(state),
        .next_state(next_state)
    );
    
    fetch_unit #(.DATA_WIDTH(DATA_WIDTH)) fetch(
        .clk(clk),
        .rst_n(rst_n),
        .stall(next_state != `STATE_IF),
        
        .rw(fetch_rw),
        .write(fetch_write),
        
        .pc(fetch_pc),
        .next_pc(fetch_next_pc)
    );
    
    inst_cache#(.DATA_WIDTH(DATA_WIDTH)) icache(
        .clk(clk),
        .rst_n(rst_n),

        // request
        .addr(fetch_pc),

        .data(imem_data)
    );

    pipeline_fetch2dec #(.DATA_WIDTH(DATA_WIDTH)) pfd(
        .clk(clk),
        .rst_n(rst_n),
        .flush(0),
        .stall(next_state != `STATE_ID),
        
        .pc_in(fetch_pc),
        .pc_out(dec_pc),
        .inst_in(imem_data),
        .inst_out(dec_raw_inst));

    decoder #(.DATA_WIDTH(DATA_WIDTH)) decode(
`ifdef DEBUG_DEC
        .stall(`FALSE),
`endif
        .pc(dec_pc),
        .raw_inst(dec_raw_inst),
        .rs_addr(dec_vrs_addr),
        .rt_addr(dec_vrt_addr),
        .wb_reg(dec_wb_reg), // rd_enable
        .rd_addr(dec_write_addr),
        .imm(dec_imm),
        .inst(dec_inst),
        .exec_op(dec_exec_op),
        .b_ctrl(dec_b_ctrl),
        .mem_enable(dec_mem_enable),
        .wb_src(dec_wb_src),
        .jump(dec_jump),
        .illegal(dec_illegal)
    );

    register_file #(.DATA_WIDTH(DATA_WIDTH))
                    regfile(
        .clk(clk),
        .rst_n(rst_n),
        .stall_in(!((state == `STATE_ID && dec_inst == `INST_JAL) || state == `STATE_WB)),

        .rs_addr(dec_vrs_addr),
        .rs_data(dec_rs_data),
        .rt_addr(dec_vrt_addr),
        .rt_data(dec_rt_data),
        .write_en(reg_write_en),
        .write_addr(reg_write_addr),
        .write_data(reg_write_data),
        .write_read(reg_write_read)
    );
    
    pc_targeter#(.DATA_WIDTH(DATA_WIDTH)) pct(
        .pc(dec_pc),
        .raw_inst(dec_raw_inst),
        .alu_rs(dec_rs_data),
        .imm(dec_imm),
        
        .jump(dec_jump),
        
        .branch_target(dec_branch_target)
    );

    pipeline_dec2exec #(.DATA_WIDTH(DATA_WIDTH)) pde(
        .clk(clk),
        .rst_n(rst_n),
        .flush(next_state == `STATE_IF),
        .stall(next_state != `STATE_EXE),
        
        .inst_in(dec_inst),
        .inst_out(exec_inst),
        .alu_op_in(dec_exec_op),
        .alu_op_out(exec_alu_op),
        .alu_rs_in(dec_rs_data),
        .alu_rs_out(exec_alu_rs),
        .alu_rt_in(dec_b_ctrl ? dec_imm : dec_rt_data),
        .alu_rt_out(exec_alu_rt),
        .mem_enable_in(dec_mem_enable),
        .mem_enable_out(exec_mem_enable),
        .mem_write_in(dec_rt_data),
        .mem_write_out(exec_mem_write),
        .wb_src_in(dec_wb_src),
        .wb_src_out(exec_wb_src),
        .wb_reg_in(dec_wb_reg),
        .wb_reg_out(exec_wb_reg),
        .jump_in(dec_jump),
        .jump_out(exec_jump));
                        
    execution #(.DATA_WIDTH(DATA_WIDTH)) exe(
        .clk(clk),
        .rst_n(rst_n),
        .stall(`FALSE),
        
        .alu_op(exec_alu_op),
        .alu_rs(exec_alu_rs),
        .alu_rt(exec_alu_rt),

        .jump(exec_jump),
        
        .res(exec_res),
        .take_branch(exec_take_branch)
    );
    
    pipeline_exec2mem #(.DATA_WIDTH(DATA_WIDTH)) pem(
        .clk(clk),
        .rst_n(rst_n),
        .flush(0),
        .stall(next_state != `STATE_MEM),
        
        .alu_res_in(exec_res),
        .alu_res_out(dmem_res));

    memory_access #(.DATA_WIDTH(DATA_WIDTH)) mem(
        .clk(clk),
        .rst_n(rst_n),
        
        .inst_in(exec_inst),
        .alu_res_in(exec_res),
        .mem_rw_out(dmem_mem_rw),
        .mem_write_in(exec_mem_write),
        .mem_write_out(dmem_mem_write),
        .mem_read_in(dmem_mem_read_raw),
        .mem_read_out(dmem_mem_read)
    );
    
    data_cache #(.DATA_WIDTH(DATA_WIDTH))
                dcache(
        .clk(clk),
        .rst_n(rst_n),
        
        .addr(dmem_res),
        .enable(dmem_mem_enable && state == `STATE_MEM),
        .rw(dmem_mem_rw),

        .write(dmem_mem_write),
        .read(dmem_mem_read_raw)
    );

    always @* // select which value should we write back to register file.
        if (dmem_wb_src == `WB_ALU) // if this instruction writes the value calculated back to register.
        begin
            // exec_res because instructions which writes back from ALU skip MEM stage
            // but for pipeline, ALU result passed through MEM stage so dmem_res..
            dmem_write <= exec_res;
        end
        else // if this instruction is load-like inst.
        begin
            dmem_write <= dmem_mem_read; // write the value read from memory.
        end
    
    pipeline_mem2wb #(.DATA_WIDTH(DATA_WIDTH)) pmw(
        .clk(clk),
        .rst_n(rst_n),
        .flush(0),
        .stall(next_state != `STATE_WB),
        
        .wb_reg_in(dec_wb_reg),
        .wb_reg_out(wb_wb_reg),
        .wb_data_in(dmem_write),
        .wb_data_out(wb_write),
        .write_addr_in(dec_write_addr),
        .write_addr_out(wb_write_addr));

    
endmodule
