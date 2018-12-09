`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 08:10:30
// Design Name: 
// Module Name: state_unit
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


module state_unit(
    input clk,
    input rst_n,
    
    input [`INST_BUS] inst,
    input mem_enable,
    
    output reg [`STATE_BUS] state,
    output reg [`STATE_BUS] next_state
    );
    
    wire arithmetic = inst == `INST_ADD || inst == `INST_SUB ||
        inst == `INST_ADDU || inst == `INST_AND || inst == `INST_OR ||
        inst == `INST_XOR || inst == `INST_SLL || inst == `INST_SLT;
        
    wire branch = inst == `INST_BEQ || inst == `INST_BNE || inst == `INST_BLTZ;
    wire halt = inst == `INST_HALT;
    
    always @*
    begin
        case (state)
            `STATE_IF: next_state = `STATE_ID;
            `STATE_ID:
                if (arithmetic || branch || mem_enable) next_state = `STATE_EXE;
                else if (halt) next_state = `STATE_HALT;
                else next_state = `STATE_IF;
            `STATE_EXE:
                if (arithmetic) next_state = `STATE_WB;
                else if (branch) next_state = `STATE_IF;
                else if (mem_enable) next_state = `STATE_MEM;
                else next_state = `STATE_INVALID;
            `STATE_MEM:
                if (inst == `INST_LW) next_state = `STATE_WB;
                else next_state = `STATE_IF;
            `STATE_WB : next_state = `STATE_IF;
            `STATE_HALT: next_state = `STATE_HALT;
            `STATE_INIT: next_state = `STATE_IF;
            `STATE_INVALID: next_state = `STATE_INVALID;
            default:
                next_state = `STATE_IF;
        endcase
    end

    always @(posedge clk, negedge rst_n)
        if (!rst_n) state <= `STATE_INIT;
        else state <= next_state;
endmodule
