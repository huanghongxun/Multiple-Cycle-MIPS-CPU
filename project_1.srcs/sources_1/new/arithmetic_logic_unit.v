`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sun Yat-sen University
// Engineer: Yuhui Huang
// 
// Create Date: 2018/06/12 20:04:40
// Design Name: Arithmetic and Logic Unit
// Module Name: arithmetic_logic_unit
// Project Name: CPU
// Target Devices: Basys3
// Tool Versions: Vivado 2015.4
// Description: Simple Arithmetic Logic Unit
// 
// Dependencies: NONE
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

// WIDTH - register width, 8, 16, 32 or 64
module arithmetic_logic_unit #(
    parameter DATA_WIDTH = 32
)(
    input stall,
    
    input [`ALU_OP_WIDTH-1:0] op,
    input [`DATA_BUS] rs,
    input [`DATA_BUS] rt,
    output reg [`DATA_BUS] rd
    );
    
    always @*
    begin
        case(op)
            `ALU_OP_NOP: begin
                rd = 0;
            end
            `ALU_OP_SLL: begin
                rd = rs << rt;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d << %d = %d", $signed(rs), $signed(rt), $signed(rd));
`endif
            end
            `ALU_OP_SRL: begin
                rd = rs >> rt;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d >> %d = %d", $signed(rs), $signed(rt), $signed(rd));
`endif
            end
            `ALU_OP_SRA: begin
                rd = $signed(rs) >>> $signed(rt);
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d >>> %d = %d", $signed(rs), $signed(rt), $signed(rd));
`endif
            end
            `ALU_OP_ADD: begin
                rd = rs + rt;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d + %d = %d", $signed(rs), $signed(rt), $signed(rd));
`endif
            end
            `ALU_OP_SUB: begin
                rd = rs - rt;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d - %d = %d", $signed(rs), $signed(rt), $signed(rd));
`endif
            end
            `ALU_OP_AND: begin
                rd = rs & rt;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d & %d = %d", $signed(rs), $signed(rt), $signed(rd));
`endif
            end
            `ALU_OP_OR: begin
                rd = rs | rt;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d | %d = %d", $signed(rs), $signed(rt), $signed(rd));
`endif
            end
            `ALU_OP_XOR: begin
                rd = rs ^ rt;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d ^ %d = %d", $signed(rs), $signed(rt), $signed(rd));
`endif
            end
            `ALU_OP_NOR: begin
                rd = ~(rs | rt);
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d ~| %d = %d", $signed(rs), $signed(rt), $signed(rd));
`endif
            end
            `ALU_OP_LU: begin
                rd = rt << 16;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d << 16 = %d", $unsigned(rt), $unsigned(rd));
`endif
            end
            `ALU_OP_EQ: begin
                rd = rs == rt ? 1 : 0;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d == %d = %d", $signed(rs), $signed(rt), rd);
`endif
            end
            `ALU_OP_NE: begin
                rd = $signed(rs) != $signed(rt) ? 1 : 0;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d != %d = %d", $signed(rs), $signed(rt), rd);
`endif
            end
            `ALU_OP_LT: begin
                rd = $signed(rs) < $signed(rt) ? 1 : 0;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d < %d = %d", $signed(rs), $signed(rt), rd);
`endif
            end
            `ALU_OP_LTU: begin
                rd = $unsigned(rs) < $unsigned(rt) ? 1 : 0;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d < %d = %d", $unsigned(rs), $unsigned(rt), rd);
`endif
            end
            `ALU_OP_LE: begin
                rd = $signed(rs) <= $signed(rt) ? 1 : 0;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: %d < %d = %d", $signed(rs), $signed(rt), rd);
`endif
            end
            default: begin
                rd = 0;
`ifdef DEBUG_ALU
                if (!stall)
                    $display("ALU: unknown op %b", op);
`endif
            end
        endcase
    end
endmodule
