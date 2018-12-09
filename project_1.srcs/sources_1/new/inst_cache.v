`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sun Yat-sen University
// Engineer: Yuhui Huang
// 
// Create Date: 2018/05/25 00:13:18
// Design Name: Instruction Cache
// Module Name: inst_cache
// Project Name: SimpleCPU
// Target Devices: Basys3
// Tool Versions: Vivado 2018.1
// Description: 
//
//   physical address(width 32):
//   [group index | block index | block offset | 00]
//         22            3             5         2
//
//   2KB instruction cache
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//     See https://en.wikipedia.org/wiki/CPU_cache
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module inst_cache#(
    parameter DATA_WIDTH = 32,
    parameter DATA_PER_BYTE_WIDTH = 2 // $clog2(DATA_WIDTH/8)
)(
    input clk,
    input rst_n,

    // request
    input [`DATA_BUS] addr, // lowest 2 bits are assumed 2'b00.
    
    // outputs
    output reg [`RAW_INST_BUS] data
    );

    reg [7:0] dat[0:127];
    integer i;
    
    initial begin
        $readmemb("test_multi_cycle.txt", dat);
    end
    
    // determine which block is bound to the memory requested.
    always @*
    begin
        data[31:24] <= dat[addr    ];
        data[23:16] <= dat[addr + 1];
        data[15: 8] <= dat[addr + 2];
        data[ 7: 0] <= dat[addr + 3];
    end
endmodule
