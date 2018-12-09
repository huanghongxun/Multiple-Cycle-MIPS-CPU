`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 19:26:41
// Design Name: 
// Module Name: pc_targeter
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

module pc_targeter#(
    parameter DATA_WIDTH = 32
)(
    input [`DATA_BUS] pc,
    input [`DATA_BUS] raw_inst,
    input [`DATA_BUS] alu_rs,
    input [`DATA_BUS] imm,
    
    input [1:0] jump,
        
    output reg [`DATA_BUS] branch_target
    );

    wire [`DATA_BUS] pc4 = pc + 4;

    always @*
    begin
        if (jump == `JUMP) // j, jal
            branch_target = { pc4[DATA_WIDTH-1:28], raw_inst[`RAW_INST_ADDR_BUS], 2'b00 };
        else if (jump == `JUMP_REG) // jr, jalr
            branch_target = alu_rs;
        else if (jump == `JUMP_COND) // beq, bne, bltz
            branch_target = pc4 + {imm[DATA_WIDTH-3:0], 2'b00}; // pc + 4 + 4 * imm
        else
            branch_target = 0;
    end
endmodule
