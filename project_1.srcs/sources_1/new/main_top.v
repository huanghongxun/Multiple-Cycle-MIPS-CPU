`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sun Yat-sen University
// Engineer: Huang Yuhui
// 
// Create Date: 2018/11/16 00:05:25
// Design Name: 
// Module Name: main_top
// Project Name: Multiple Cycle CPU
// Target Devices: Basys3
// Tool Versions: Vivado 2018.1
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main_top(
    input clk, // 系统时钟
    input btn0, // 中心按钮的信号
    output [6:0] seg, // 七段显示管的显示信号
    output reg [3:0] an, // 位选信号
    input [15:0] sw, // 16 个开关的信号
    output reg [15:0] LED // 16 盏 LED 的控制端口
    );
    
    wire trigger; // 按钮信号防抖后的信号
    debouncer deb(clk, btn0, trigger); // 将 btn0 防抖同步后输出 trigger
    
    wire rst_n = sw[0]; // 令 0 号开关提供复位信号
    wire [2:0] mode = sw[15:13]; // 令 13~15 号开关提供
    
    reg [3:0] S[0:3];
    reg [3:0] BCD;
    reg [1:0] display_digit = 0;
    reg [3:0] display_digit_bit;
    wire clk_display;
    
    clock_div#(50000, 19) div2(clk, rst_n, clk_display); // 分频器
    bcd_encoder encoder(1, BCD, seg); // BCD 码转七段显示管信号
    
    // output
    wire [31:0] inst; // 当前指令
    wire [31:0] pc; // 当前指令的地址
    wire [31:0] next_pc; // 下一条指令的地址（ID 阶段后有效）
    wire [31:0] alu_res; // 当前指令的运算结果（EXE 阶段后有效）
    wire [31:0] reg_write_data; // 回写寄存器的数据（WB 阶段后有效）
    wire [31:0] reg_write_read; // rd 寄存器的实际值
    wire [4:0] reg_write_addr; // 回写寄存器的编号（WB 阶段后有效）
    wire reg_write_en; // 是否回写寄存器（WB 阶段后有效）
    wire [4:0] rs_addr; // rs 寄存器编号（ID 阶段后有效）
    wire [31:0] rs_data; // rs 寄存器值（ID 阶段后有效）
    wire [4:0] rt_addr; // rt 寄存器编号（ID 阶段后有效）
    wire [31:0] rt_data; // rt 寄存器值（ID 阶段后有效）
    wire [31:0] imm; // 扩展后的立即数（ID 阶段后有效）
    wire [31:0] branch_target; // 跳转目标地址（ID 阶段后有效）
    wire [31:0] mem_read; // 内存数据读取（lw 指令的 MEM 阶段后有效）
    wire [`ALU_OP_BUS] alu_op; // ALU 操作码（ID 阶段后有效）
    wire zero; // ALU 的 zero 信号（EXE 阶段后有效）
    wire b_ctrl; // rt 二选一信号（ID 阶段后有效）
    wire [`JUMP_BUS] jump; // 跳转类型信号（ID 阶段后有效）
    wire take_branch; // 条件跳转指令是否应用跳转（EXE 阶段后有效）
    wire fetch_rw; // 是否覆盖 PC 寄存器的值（在指令的最后一个阶段有效）
    wire [5:0] opcode; // 指令的 opcode（ID 阶段后有效）
    wire [`STATE_BUS] state, next_state; // 当前指令的当前/下一个阶段的编号
    wire halt; // 是否停机（ID 阶段后有效）
    
    // 提供给 CPU 的时钟信号必须与系统时钟同步/防抖
    // 否则会综合失败
    main main(
        .clk(trigger),
        .rst_n(rst_n),
        .inst(inst),
        .pc(pc),
        .next_pc(next_pc),
        .alu_res(alu_res),
        .reg_write_data(reg_write_data),
        .reg_write_addr(reg_write_addr),
        .reg_write_read(reg_write_read),
        .reg_write_en(reg_write_en),
        .rs_addr(rs_addr),
        .rs_data(rs_data),
        .rt_addr(rt_addr),
        .rt_data(rt_data),
        .imm(imm),
        .branch_target(branch_target),
        .mem_read(mem_read),
        .alu_op(alu_op),
        .zero(zero),
        .b_ctrl(b_ctrl),
        .jump(jump),
        .take_branch(take_branch),
        .fetch_rw(fetch_rw),
        .state(state),
        .next_state(next_state));
    
    always @(posedge clk_display)
        display_digit = display_digit + 1;
    
    always @*
    begin
        case(display_digit) // 枚举位选信号
            0: an <= 4'b1110;
            1: an <= 4'b1101;
            2: an <= 4'b1011;
            3: an <= 4'b0111;
            default: an <= 4'b0000;
        endcase
        BCD <= S[display_digit];
    end
    
    always @* // LED 灯显示的信号表请参见下文
    begin
        LED[0] <= 1; // 常亮表示 CPU 是否在运行
        LED[1] <= fetch_rw; // PC 寄存器是 +4 还是被跳转指令覆盖
        LED[2] <= zero; // ALU 的 zero 信号
        LED[3] <= reg_write_en; // 是否回写寄存器
        LED[4] <= b_ctrl; // 使用寄存器还是立即数作为第二操作数
        LED[5] <= take_branch; // 是否跳转
        LED[6] <= jump[0]; // 跳转指令信号低位（0 不跳转、1 j、jal）
        LED[7] <= jump[1]; // 跳转指令信号高位（2 jr、jalr、3 bne、beq、bltz）
        LED[10] <= state[0]; // 当前指令状态（0 刚复位、1 IF、2 ID）
        LED[11] <= state[1]; // 当前指令状态（3 EXE、4 MEM、5 WB）
        LED[12] <= state[2]; // 当前指令状态（6 不合法、7 HALT）
        LED[15] <= state == `STATE_HALT; // CPU 是否结束运行
    end
    
    always @* // 数码管显示的信号表请参见下文
        case(mode)
            // 高位是当前指令的地址，低位是下一条指令的地址
            0: begin {S[3], S[2]} <= pc[7:0]; {S[1], S[0]} <= next_pc[7:0]; end
            // 高位是 rs 寄存器的编号，低位是其数据
            1: begin S[3] <= rs_addr / 10; S[2] <= rs_addr % 10; {S[1], S[0]} <= rs_data[7:0]; end
            // 高位是 rt 寄存器的编号，低位是其数据
            2: begin S[3] <= rt_addr / 10; S[2] <= rt_addr % 10; {S[1], S[0]} <= rt_data[7:0]; end
            // 高位是 ALU 运算结果，低位是内存读数据的结果
            3: begin {S[3], S[2]} <= alu_res[7:0]; {S[1], S[0]} <= mem_read[7:0]; end
            // 高位是回写寄存器的编号，低位是回写寄存器的写入值
            4: begin S[3] <= reg_write_addr / 10; S[2] <= reg_write_addr % 10; {S[1], S[0]} <= reg_write_data[7:0]; end
            // 高位是立即数，低位是跳转指令目标地址
            5: begin {S[3], S[2]} <= imm[7:0]; {S[1], S[0]} <= branch_target[7:0]; end
            // 高位是 ALU 操作码，低位是回写寄存器的实际值，用于检查是否成功写入
            6: begin S[3] <= alu_op; {S[2], S[1], S[0]} <= reg_write_read; end
            // 高位是当前阶段编号，低位是下一个阶段的编号
            7: begin {S[3], S[2]} <= state; {S[1], S[0]} <= next_state; end
            default: begin {S[3], S[2], S[1], S[0]} <= 0; end
        endcase
endmodule
