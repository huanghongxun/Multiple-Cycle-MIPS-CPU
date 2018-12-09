`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sun Yat-sen University
// Engineer: Yuhui Huang
// 
// Create Date: 2018/05/25 00:13:18
// Design Name: Decoder
// Module Name: decoder
// Project Name: SimpleCPU
// Target Devices: Basys3
// Tool Versions: Vivado 2018.1
// Description: Translate original instruction into ALU op-code.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//     Instructions see http://math-atlas.sourceforge.net/devel/assembly/mips-iv.pdf
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module decoder #(parameter DATA_WIDTH = 32)(
`ifdef DEBUG_DEC
    input stall,
`endif

    input [`DATA_BUS] pc,
    input [`RAW_INST_BUS] raw_inst,

    output reg [`VREG_BUS] rs_addr, // register index of rs
    output reg [`VREG_BUS] rt_addr, // register index of rt
    output reg wb_reg, // 1 if write to register rd. (if rd is valid)
    output reg [`VREG_BUS] rd_addr, // register index of rd, or coprocessor register index
    output reg [`DATA_BUS] imm, // immediate for I-type instruction.
    output reg [`INST_BUS] inst,
    output reg [`ALU_OP_WIDTH-1:0] exec_op, // ALU operation id.
    output reg b_ctrl, // 1 if use immediate value instead of rt
    output mem_enable, // 1 if enable memory, 0 if disable memory 
    output reg wb_src, // 0 if write back from ALU, 1 if write back from memory(load inst)
    output [1:0] jump, // 0 if not jump instruction, 1 if jump to imm, 2 if jump to register rt, 3 if jump conditionally
    output reg illegal
    );

    wire [5:0] op_wire = raw_inst[`RAW_INST_OP_BUS]; // op-code
    wire [4:0] rs_wire = raw_inst[`RAW_INST_RS_BUS]; // register index of rs for R/I-type instruction.
    wire [4:0] rt_wire = raw_inst[`RAW_INST_RT_BUS]; // register index of rt for R/I-type instruction.
    wire [4:0] rd_wire = raw_inst[`RAW_INST_RD_BUS]; // register index of rd for R-type instruction.
    wire [4:0] shamt_wire = raw_inst[`RAW_INST_SHAMT_BUS]; // shift amount field for R-type instruction.
    wire [5:0] funct_wire = raw_inst[`RAW_INST_FUNCT_BUS]; // function field for R-type instruction.
    wire [15:0] imm_wire = raw_inst[`RAW_INST_IMM_BUS]; // immediate for arithmetic instruction, or offset for branch instructions.
    
    reg [`EXT_BUS] sign_extend;
    
    always @*
        if (sign_extend == `SIGN_EXT)
            imm <= $signed(raw_inst[`RAW_INST_IMM_BUS]);
        else if (sign_extend == `ZERO_EXT)
            imm <=  $unsigned(raw_inst[`RAW_INST_IMM_BUS]);
        else if (sign_extend == `ADDR_EXT)
            imm <= pc + 4;
        else
            imm <= shamt_wire;

    `define decode(rs_wire, rt_wire, rd_wire, wb_reg_wire, inst_wire, exec_op_wire, sign_ext,  b_ctrl_wire, wb_src_wire) \
        rs_addr <= rs_wire; \
        rt_addr <= rt_wire; \
        rd_addr <= rd_wire; \
        wb_reg <= wb_reg_wire; \
        inst <= inst_wire; \
        exec_op <= exec_op_wire; \
        sign_extend <= sign_ext; \
        b_ctrl <= b_ctrl_wire; \
        wb_src <= wb_src_wire; \
        illegal <= 0

`ifdef DEBUG_DEC
    `define decode_invalid \
        if (!stall && raw_inst != 'bx) \
            $display("%x: unknown instruction %b", pc, raw_inst)
`else
    `define decode_invalid illegal <= 1
`endif

    always @*
    begin
        case (op_wire)
            6'b000000: begin // add
                `decode(rs_wire, rt_wire, rd_wire, `REG_WB, `INST_ADD, `ALU_OP_ADD, `ZERO_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: add, rs: %d, rt: %d, rd: %d", pc, rs_wire, rt_wire, rd_wire);
`endif
            end
            6'b000001: begin // sub
                `decode(rs_wire, rt_wire, rd_wire, `REG_WB, `INST_SUB, `ALU_OP_SUB, `ZERO_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: sub, rs: %d, rt: %d, rd: %d", pc, rs_wire, rt_wire, rd_wire);
`endif
            end
            6'b000010: begin // addiu
                `decode(rs_wire, 0, rt_wire, `REG_WB, `INST_ADDU, `ALU_OP_ADD, `SIGN_EXT, `B_IMM, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: addiu, rs: %d, imm: %d, rt: %d", pc, rs_wire, $signed(imm_wire), rt_wire);
`endif
            end
            6'b010000: begin // and
                `decode(rs_wire, rt_wire, rd_wire, `REG_WB, `INST_AND, `ALU_OP_AND, `ZERO_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: and, rs: %d, rt: %d, rd: %d", pc, rs_wire, rt_wire, rd_wire);
`endif
            end
            6'b010001: begin // andi
                `decode(rs_wire, 0, rt_wire, `REG_WB, `INST_AND, `ALU_OP_AND, `ZERO_EXT, `B_IMM, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: andi, rs: %d, imm: %d, rt: %d", pc, rs_wire, $unsigned(imm_wire), rt_wire);
`endif
            end
            6'b010010: begin // ori
                `decode(rs_wire, 0, rt_wire, `REG_WB, `INST_OR, `ALU_OP_OR, `ZERO_EXT, `B_IMM, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: ori, rs: %d, imm: %d, rt: %d", pc, rs_wire, $unsigned(imm_wire), rt_wire);
`endif
            end
            6'b010011: begin // xori
                `decode(rs_wire, 0, rt_wire, `REG_WB, `INST_XOR, `ALU_OP_XOR, `ZERO_EXT, `B_IMM, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: xori, rs: %d, imm: %d, rt: %d", pc, rs_wire, $unsigned(imm_wire), rt_wire);
`endif
            end
            6'b011000: begin // sll
                `decode(rt_wire, 0, rd_wire, `REG_WB, `INST_SLL, `ALU_OP_SLL, `SHAMT_IMM, `B_IMM, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: sll, rt: %d, sa: %d, rd: %d", pc, rt_wire, shamt_wire, rd_wire);
`endif
            end
            6'b100110: begin // slti
                `decode(rs_wire, 0, rt_wire, `REG_WB, `INST_SLT, `ALU_OP_LT, `SIGN_EXT, `B_IMM, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: slti, rs: %d, imm: %d, rt: %d", pc, rs_wire, $signed(imm_wire), rt_wire);
`endif
            end
            6'b100111: begin // slt
                `decode(rs_wire, rt_wire, rd_wire, `REG_WB, `INST_SLT, `ALU_OP_LT, `ZERO_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: slt, rs: %d, rt: %d, rd: %d", pc, rs_wire, rt_wire, rd_wire);
`endif
            end
            6'b110000: begin // sw
                `decode(rs_wire, rt_wire, 0, `REG_N, `INST_SW, `ALU_OP_ADD, `SIGN_EXT, `B_IMM, `WB_MEM);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: sw, base: %d, offset: %d, rt: %d", pc, rs_wire, $signed(imm_wire), rt_wire);
`endif
            end
            6'b110001: begin // lw
                `decode(rs_wire, 0, rt_wire, `REG_WB, `INST_LW, `ALU_OP_ADD, `SIGN_EXT, `B_IMM, `WB_MEM);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: lw, base: %d, offset: %d, rt: %d", pc, rs_wire, $signed(imm_wire), rt_wire);
`endif
            end
            6'b110100: begin // beq
                `decode(rs_wire, rt_wire, 0, `REG_N, `INST_BEQ, `ALU_OP_EQ, `SIGN_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: beq, rs: %d, rt: %d, offset: %x, dest: %x", pc, rs_wire, rt_wire, $signed(imm_wire), (pc + 4 + 4 * $signed(imm_wire)));
`endif
            end
            6'b110101: begin // bne
                `decode(rs_wire, rt_wire, 0, `REG_N, `INST_BNE, `ALU_OP_NE, `SIGN_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: bne, rs: %d, rt: %d, offset: %x, dest: %x", pc, rs_wire, rt_wire, $signed(imm_wire), (pc + 4 + 4 * $signed(imm_wire)));
`endif
            end
            6'b110110: begin // bltz
                `decode(rs_wire, 0, 0, `REG_N, `INST_BLTZ, `ALU_OP_LT, `SIGN_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: bltz, rs: %d, offset: %x, dest: %x", pc, rs_wire, $signed(imm_wire), (pc + 4 + 4 * $signed(imm_wire)));
`endif
            end
            6'b111000: begin // j
                `decode(0, 0, 0, `REG_N, `INST_J, `ALU_OP_NOP, `ZERO_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: j, dest: %x", pc, { pc[DATA_WIDTH-1:28], raw_inst[`RAW_INST_ADDR_BUS], 2'b00 });
`endif
            end
            6'b111001: begin // jr
                `decode(rs_wire, 0, 0, `REG_N, `INST_JR, `ALU_OP_NOP, `ZERO_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: j, dest: %x", pc, { pc[DATA_WIDTH-1:28], raw_inst[`RAW_INST_ADDR_BUS], 2'b00 });
`endif
            end
            6'b111010: begin // jal
                `decode(0, 0, 31, `REG_WB, `INST_JAL, `ALU_OP_NOP, `ADDR_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: j, dest: %x", pc, { pc[DATA_WIDTH-1:28], raw_inst[`RAW_INST_ADDR_BUS], 2'b00 });
`endif
            end
            6'b111111: begin // halt
                `decode(0, 0, 0, `REG_N, `INST_HALT, `ALU_OP_NOP, `ZERO_EXT, `B_REG, `WB_ALU);
`ifdef DEBUG_DEC
                if (!stall)
                    $display("%x: halt", pc);
`endif 
            end
            default: begin
                `decode(0, 0, 0, 0, 0, 0, 0, 0, 0);
                illegal <= 1;
            end
        endcase
    end

    assign mem_enable = (inst == `INST_LB || inst == `INST_LBU || inst == `INST_LH || inst == `INST_LHU || inst == `INST_LW || inst == `INST_LWL || inst == `INST_LWR
                      || inst == `INST_SB || inst == `INST_SH || inst == `INST_SW || inst == `INST_SWL || inst == `INST_SWR) ? `MEM_EN : `MEM_DIS;
    assign jump = inst == `INST_JR || inst == `INST_JALR ? `JUMP_REG :
        inst == `INST_J || inst == `INST_JAL ? `JUMP :
        inst == inst == `INST_BGEZ || inst == `INST_BLTZ || inst == `INST_BGTZ || inst == `INST_BLEZ || inst == `INST_BEQ || inst == `INST_BNE ? `JUMP_COND : `JUMP_N;
endmodule
