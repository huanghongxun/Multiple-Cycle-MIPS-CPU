`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sun Yat-sen University
// Engineer: Yuhui Huang
// 
// Create Date: 2018/05/25 00:13:18
// Design Name: Register renaming for register file
// Module Name: regfile_renaming
// Project Name: SimpleCPU
// Target Devices: Basys3
// Tool Versions: Vivado 2018.1
// Description: 
//
//
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   See https://en.wikipedia.org/wiki/Register_renaming
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module register_file#(
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rst_n,
    input stall_in, // stall signal to register file

    // decode
    input [`VREG_BUS] rs_addr, // the first operand register index of the inst in decode stage
    output [`DATA_BUS] rs_data, // the data of the first operand register
    input [`VREG_BUS] rt_addr, // the second operand register index of the inst in decode stage
    output [`DATA_BUS] rt_data, // the data of the second operand register
    input write_en, // write or not
    input [`VREG_BUS] write_addr, // the result register index of the inst in decode stage
    input [`DATA_BUS] write_data, // the data being written to the register being written
    output [`DATA_BUS] write_read
    );

    integer i;

    reg [`DATA_BUS] file[1:`REG_SIZE - 1];

    assign rs_data = (rs_addr == 0) ? 0 : file[rs_addr];
    assign rt_data = (rt_addr == 0) ? 0 : file[rt_addr];
    assign write_read = (write_addr == 0) ? 0 : file[write_addr];

    wire write_enabled = write_en == `MEM_WRITE && (write_addr != 0) && !stall_in;

    always @(negedge clk, negedge rst_n)
    begin
        if (!rst_n)
        begin
            for (i = 1; i < `REG_SIZE; i = i + 1)
                file[i] <= 0;
        end
        else
        begin
            // perform write
            if (write_enabled)
            begin
                file[write_addr] <= write_data;
            end
        end
    end
endmodule
