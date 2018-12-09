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
    input clk, // ϵͳʱ��
    input btn0, // ���İ�ť���ź�
    output [6:0] seg, // �߶���ʾ�ܵ���ʾ�ź�
    output reg [3:0] an, // λѡ�ź�
    input [15:0] sw, // 16 �����ص��ź�
    output reg [15:0] LED // 16 յ LED �Ŀ��ƶ˿�
    );
    
    wire trigger; // ��ť�źŷ�������ź�
    debouncer deb(clk, btn0, trigger); // �� btn0 ����ͬ������� trigger
    
    wire rst_n = sw[0]; // �� 0 �ſ����ṩ��λ�ź�
    wire [2:0] mode = sw[15:13]; // �� 13~15 �ſ����ṩ
    
    reg [3:0] S[0:3];
    reg [3:0] BCD;
    reg [1:0] display_digit = 0;
    reg [3:0] display_digit_bit;
    wire clk_display;
    
    clock_div#(50000, 19) div2(clk, rst_n, clk_display); // ��Ƶ��
    bcd_encoder encoder(1, BCD, seg); // BCD ��ת�߶���ʾ���ź�
    
    // output
    wire [31:0] inst; // ��ǰָ��
    wire [31:0] pc; // ��ǰָ��ĵ�ַ
    wire [31:0] next_pc; // ��һ��ָ��ĵ�ַ��ID �׶κ���Ч��
    wire [31:0] alu_res; // ��ǰָ�����������EXE �׶κ���Ч��
    wire [31:0] reg_write_data; // ��д�Ĵ��������ݣ�WB �׶κ���Ч��
    wire [31:0] reg_write_read; // rd �Ĵ�����ʵ��ֵ
    wire [4:0] reg_write_addr; // ��д�Ĵ����ı�ţ�WB �׶κ���Ч��
    wire reg_write_en; // �Ƿ��д�Ĵ�����WB �׶κ���Ч��
    wire [4:0] rs_addr; // rs �Ĵ�����ţ�ID �׶κ���Ч��
    wire [31:0] rs_data; // rs �Ĵ���ֵ��ID �׶κ���Ч��
    wire [4:0] rt_addr; // rt �Ĵ�����ţ�ID �׶κ���Ч��
    wire [31:0] rt_data; // rt �Ĵ���ֵ��ID �׶κ���Ч��
    wire [31:0] imm; // ��չ�����������ID �׶κ���Ч��
    wire [31:0] branch_target; // ��תĿ���ַ��ID �׶κ���Ч��
    wire [31:0] mem_read; // �ڴ����ݶ�ȡ��lw ָ��� MEM �׶κ���Ч��
    wire [`ALU_OP_BUS] alu_op; // ALU �����루ID �׶κ���Ч��
    wire zero; // ALU �� zero �źţ�EXE �׶κ���Ч��
    wire b_ctrl; // rt ��ѡһ�źţ�ID �׶κ���Ч��
    wire [`JUMP_BUS] jump; // ��ת�����źţ�ID �׶κ���Ч��
    wire take_branch; // ������תָ���Ƿ�Ӧ����ת��EXE �׶κ���Ч��
    wire fetch_rw; // �Ƿ񸲸� PC �Ĵ�����ֵ����ָ������һ���׶���Ч��
    wire [5:0] opcode; // ָ��� opcode��ID �׶κ���Ч��
    wire [`STATE_BUS] state, next_state; // ��ǰָ��ĵ�ǰ/��һ���׶εı��
    wire halt; // �Ƿ�ͣ����ID �׶κ���Ч��
    
    // �ṩ�� CPU ��ʱ���źű�����ϵͳʱ��ͬ��/����
    // ������ۺ�ʧ��
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
        case(display_digit) // ö��λѡ�ź�
            0: an <= 4'b1110;
            1: an <= 4'b1101;
            2: an <= 4'b1011;
            3: an <= 4'b0111;
            default: an <= 4'b0000;
        endcase
        BCD <= S[display_digit];
    end
    
    always @* // LED ����ʾ���źű���μ�����
    begin
        LED[0] <= 1; // ������ʾ CPU �Ƿ�������
        LED[1] <= fetch_rw; // PC �Ĵ����� +4 ���Ǳ���תָ���
        LED[2] <= zero; // ALU �� zero �ź�
        LED[3] <= reg_write_en; // �Ƿ��д�Ĵ���
        LED[4] <= b_ctrl; // ʹ�üĴ���������������Ϊ�ڶ�������
        LED[5] <= take_branch; // �Ƿ���ת
        LED[6] <= jump[0]; // ��תָ���źŵ�λ��0 ����ת��1 j��jal��
        LED[7] <= jump[1]; // ��תָ���źŸ�λ��2 jr��jalr��3 bne��beq��bltz��
        LED[10] <= state[0]; // ��ǰָ��״̬��0 �ո�λ��1 IF��2 ID��
        LED[11] <= state[1]; // ��ǰָ��״̬��3 EXE��4 MEM��5 WB��
        LED[12] <= state[2]; // ��ǰָ��״̬��6 ���Ϸ���7 HALT��
        LED[15] <= state == `STATE_HALT; // CPU �Ƿ��������
    end
    
    always @* // �������ʾ���źű���μ�����
        case(mode)
            // ��λ�ǵ�ǰָ��ĵ�ַ����λ����һ��ָ��ĵ�ַ
            0: begin {S[3], S[2]} <= pc[7:0]; {S[1], S[0]} <= next_pc[7:0]; end
            // ��λ�� rs �Ĵ����ı�ţ���λ��������
            1: begin S[3] <= rs_addr / 10; S[2] <= rs_addr % 10; {S[1], S[0]} <= rs_data[7:0]; end
            // ��λ�� rt �Ĵ����ı�ţ���λ��������
            2: begin S[3] <= rt_addr / 10; S[2] <= rt_addr % 10; {S[1], S[0]} <= rt_data[7:0]; end
            // ��λ�� ALU ����������λ���ڴ�����ݵĽ��
            3: begin {S[3], S[2]} <= alu_res[7:0]; {S[1], S[0]} <= mem_read[7:0]; end
            // ��λ�ǻ�д�Ĵ����ı�ţ���λ�ǻ�д�Ĵ�����д��ֵ
            4: begin S[3] <= reg_write_addr / 10; S[2] <= reg_write_addr % 10; {S[1], S[0]} <= reg_write_data[7:0]; end
            // ��λ������������λ����תָ��Ŀ���ַ
            5: begin {S[3], S[2]} <= imm[7:0]; {S[1], S[0]} <= branch_target[7:0]; end
            // ��λ�� ALU �����룬��λ�ǻ�д�Ĵ�����ʵ��ֵ�����ڼ���Ƿ�ɹ�д��
            6: begin S[3] <= alu_op; {S[2], S[1], S[0]} <= reg_write_read; end
            // ��λ�ǵ�ǰ�׶α�ţ���λ����һ���׶εı��
            7: begin {S[3], S[2]} <= state; {S[1], S[0]} <= next_state; end
            default: begin {S[3], S[2], S[1], S[0]} <= 0; end
        endcase
endmodule
