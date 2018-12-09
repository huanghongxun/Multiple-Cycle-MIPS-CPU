`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/01 17:53:30
// Design Name: 
// Module Name: data_cache
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

module data_cache#(
    parameter DATA_WIDTH = 32,
    parameter DATA_PER_BYTE_WIDTH = 2 // $clog2(DATA_WIDTH/8)
)(
    input clk,
    input rst_n,

    // request
    input [`DATA_BUS] addr, // lowest 2 bits are assumed 2'b00.
    input enable,
    input rw,
    
    // outputs
    input [`DATA_BUS] write,
    output reg [`DATA_BUS] read
    );
    
    reg [7:0] dat[0:127];
    integer i;
    
    always @*
        if (enable)
        begin
            read[31:24] <= dat[addr    ];
            read[23:16] <= dat[addr + 1];
            read[15: 8] <= dat[addr + 2];
            read[ 7: 0] <= dat[addr + 3];
        end
        else
            read <= 'bZZZZZZZZ;
    
    always @(negedge clk, negedge rst_n)
    begin
        if (!rst_n)
        begin
            for (i = 0; i < 128; i = i + 1)
                dat[i] <= 0;
        end
        else
        begin
            if (enable)
            begin
                if (rw == `MEM_WRITE)
                begin
                    dat[addr    ] <= write[31:24];
                    dat[addr + 1] <= write[23:16];
                    dat[addr + 2] <= write[15: 8];
                    dat[addr + 3] <= write[ 7: 0];
                end
            end
        end
    end
endmodule
