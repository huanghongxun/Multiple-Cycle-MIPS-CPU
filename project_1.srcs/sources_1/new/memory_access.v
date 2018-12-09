`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sun Yat-sen University
// Engineer: Yuhui Huang
// 
// Design Name: Memory Access Stage Controller
// Module Name: memory_access
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

module memory_access#(parameter DATA_WIDTH = 32)(
    input clk,
    input rst_n,
    
    input      [`INST_BUS] inst_in,
    input      [`DATA_BUS] alu_res_in, // Arithmetic result or memory address
    input      [`DATA_BUS] mem_read_in,
    output     [`DATA_BUS] mem_read_out,
    input      [`DATA_BUS] mem_write_in,
    output     [`DATA_BUS] mem_write_out,
    
    output                 mem_rw_out
);
    reg             mem_rw_reg;
    reg [`DATA_BUS] mem_write_reg;
    reg [`DATA_BUS] mem_read_reg;
    
    assign mem_rw_out = mem_rw_reg;
    assign mem_read_out = mem_read_reg;
    assign mem_write_out = mem_write_reg;

    always @*
    begin
        mem_rw_reg <= `MEM_READ;
        mem_read_reg <= 'bZ;
        mem_write_reg <= 0;
        case (inst_in)
            `INST_LW: begin
                mem_rw_reg <= `MEM_READ;
                mem_read_reg <= mem_read_in;
            end
            `INST_SW: begin
                mem_rw_reg <= `MEM_WRITE;
                mem_write_reg <= mem_write_in;
            end
        endcase
    end

endmodule