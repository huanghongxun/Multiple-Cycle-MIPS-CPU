`ifndef DEFINES_V
`define DEFINES_V

`define XILINX_SIM
`ifdef XILINX_SIM

`define DEBUG_ALU
`define DEBUG_INST
`define DEBUG_DATA
`define DEBUG_ALU
`define DEBUG_DEC
`define DEBUG_BRAM
`define DEBUG_MEMCTRL
`define DEBUG_REG
`define DEBUG_EXCEPT

`define DEBUG_MODE

`ifdef DEBUG_MODE
    `define DEBUG 1
`else
    `define DEBUG 0
`endif

`endif

`define TRUE 1'b1
`define FALSE 1'b0

/**************
 *            *
 *   Decode   *
 *            *
 **************/

`define RS_EN 1
`define RS_DIS 0

`define RT_EN 1
`define RT_DIS 0

`define EX_SRC_WIDTH 2
`define EX_SRC_BUS 1:0

`define EXT_BUS 1:0
`define ADDR_EXT 2'b10
`define SHAMT_IMM 2'b11
`define SIGN_EXT 2'b01
`define ZERO_EXT 2'b00

`define EX_NOP 0
`define EX_ALU 1
`define EX_MOV 2
`define EX_FPU 3

`define B_REG 0
`define B_IMM 1

`define MEM_WORD 2'b00
`define MEM_HALF 2'b01
`define MEM_BYTE 2'b10

`define MEM_READ 0
`define MEM_WRITE 1

`define MEM_EN 1
`define MEM_DIS 0

`define WB_ALU 0
`define WB_MEM 1

`define REG_WB 1
`define REG_N 0

`define JUMP_BUS 1:0
`define JUMP_COND 2'b11
`define JUMP_REG 2'b10
`define JUMP 2'b01
`define JUMP_N 2'b00

`define BR 1
`define BR_N 0

`define TRAP 1
`define TRAP_N 0

`define TEST_PASS 0
`define TEST_FAIL 1
`define TEST_DONE 2

/*****************
 *               *
 *      Bus      *
 *               *
 *****************/

`define DATA_BUS DATA_WIDTH-1:0
`define BRAM_ADDR_BUS BRAM_ADDR_WIDTH-1:0
`define BRAM_ADDR_RANGE BRAM_ADDR_WIDTH+1:2
`define ADDR_BUS DATA_WIDTH-3:0 // We partition memory into dozens of words, but address locates data by byte.
`define VREG_BUS 4:0
`define PREG_BUS 5:0
`define REG_SIZE 32

/******************
 *                *
 * State Control  *
 *                *
 ******************/
 
`define STATE_BUS 2:0
`define STATE_INIT 3'b000
`define STATE_IF 3'b001
`define STATE_ID 3'b010
`define STATE_EXE 3'b011
`define STATE_MEM 3'b100
`define STATE_WB 3'b101
`define STATE_INVALID 3'b110
`define STATE_HALT 3'b111

/*******************
 *                 *
 *   Coprocessor   *
 *                 *
 *******************/

`define CP0_REG_BUS 4:0
 
`define CP0_REG_COUNT 9
`define CP0_REG_COMPARE 11
`define CP0_REG_STATUS 12
`define CP0_REG_CAUSE 13
`define CP0_REG_EPC 14
`define CP0_REG_PRID 15
`define CP0_REG_CONFIG 16

/******************
 *                *
 *   Exceptions   *
 *                *
 ******************/
`define EXCEPT_MASK_BUS 13:0

`define EXCEPT_NONE 0
`define EXCEPT_INTERRUPT 1
`define EXCEPT_SYSCALL 2
`define EXCEPT_ILLEGAL 3
`define EXCEPT_OVERFLOW 4
`define EXCEPT_TRAP    5
`define EXCEPT_ERET    6
`define EXCEPT_ADDRL   7
`define EXCEPT_ADDRS   8
 
`define EXCEPT_INTERRUPT_ADDR 32'h00000020
`define EXCEPT_SYSCALL_ADDR 32'h00000040
`define EXCEPT_ILLEGAL_ADDR 32'h00000040
`define EXCEPT_OVERFLOW_ADDR 32'h00000040
`define EXCEPT_TRAP_ADDR    32'h00000040

`define CODE_INT 0 // Interrupt
`define CODE_ADDRL 4 // Load from an illegal address
`define CODE_ADDRS 5 // Store to an illegal address
`define CODE_IBUS 6 // Bus error on instruction fetch
`define CODE_DBUS 7 // Bus error on data reference
`define CODE_SYS 8 // syscall executed
`define CODE_BKPT 9 // break executed
`define CODE_RI 10 // Reserved instruction
`define CODE_OVF 12 // Arithmetic overflow
`define CODE_TRAP 13 // trap instruction executed
`define CODE_ERET 14

/**************************
 *                        *
 *   Exec Stage Op-code   *
 *                        *
 **************************/

`define ALU_OP_WIDTH 4
`define ALU_OP_BUS `ALU_OP_WIDTH-1:0

`define ALU_OP_NOP  4'b0000
`define ALU_OP_SLL  4'b0001
`define ALU_OP_SRL  4'b0010
`define ALU_OP_SRA  4'b0011
`define ALU_OP_ADD  4'b0100
`define ALU_OP_SUB  4'b0101
`define ALU_OP_AND  4'b0110
`define ALU_OP_OR   4'b0111
`define ALU_OP_XOR  4'b1000
`define ALU_OP_NOR  4'b1001
`define ALU_OP_LU   4'b1010
`define ALU_OP_LE   4'b1011
`define ALU_OP_LT   4'b1100
`define ALU_OP_EQ   4'b1101
`define ALU_OP_NE   4'b1110
`define ALU_OP_LTU  4'b1111

/********************
 *                  *
 *   Instructions   *
 *                  *
 ********************/

`define INST_WIDTH 7
`define INST_BUS `INST_WIDTH-1:0
`define RAW_INST_BUS 31:0

`define RAW_INST_OP_BUS 31:26
`define RAW_INST_RS_BUS 25:21
`define RAW_INST_RT_BUS 20:16
`define RAW_INST_RD_BUS 15:11
`define RAW_INST_SHAMT_BUS 10:6
`define RAW_INST_FUNCT_BUS 5:0
`define RAW_INST_IMM_BUS 15:0
`define RAW_INST_ADDR_BUS 25:0

`define INST_NOP  7'b0000000

`define INST_SLL  7'b0000001
`define INST_SRL  7'b0000010
`define INST_SRA  7'b0000011

`define INST_HALT 7'b0000100

`define INST_MFHI 7'b0000110
`define INST_MFLO 7'b0000111
`define INST_MUL  7'b0001000
`define INST_MULU 7'b0001001
`define INST_DIV  7'b0001010
`define INST_DIVU 7'b0001011

`define INST_ADD  7'b0001100
`define INST_ADDU 7'b0001101
`define INST_SUB  7'b0001110
`define INST_SUBU 7'b0001111
`define INST_AND  7'b0010000
`define INST_OR   7'b0010001
`define INST_XOR  7'b0010010
`define INST_NOR  7'b0010011

`define INST_SLT  7'b0010100
`define INST_SLTU 7'b0010101

`define INST_LU   7'b0010110

`define INST_BLEZ 7'b0011010
`define INST_BGTZ 7'b0011011
`define INST_BEQ  7'b0011100
`define INST_BNE  7'b0011101
`define INST_BLTZ 7'b0011110
`define INST_BGEZ 7'b0011111

`define INST_LB   7'b0100000
`define INST_LBU  7'b0100001
`define INST_LH   7'b0100010
`define INST_LHU  7'b0100011
`define INST_LW   7'b0100100
`define INST_LWL  7'b0100101
`define INST_LWR  7'b0100110

`define INST_SB   7'b0101000
`define INST_SH   7'b0101001
`define INST_SW   7'b0101010
`define INST_SWL  7'b0101011
`define INST_SWR  7'b0101100

`define INST_J    7'b0101101
`define INST_JAL  7'b0101110
`define INST_JR   7'b0101111
`define INST_JALR 7'b0100111

`define INST_TEQ  7'b0110000
`define INST_TGE  7'b0110001
`define INST_TGEU 7'b0110010
`define INST_TLT  7'b0110011
`define INST_TLTU 7'b0110100
`define INST_TNE  7'b0110101

`define INST_SYSCALL 7'b0111100
`define INST_ERET 7'b0111101

`define INST_MTC0 7'b0111110
`define INST_MFC0 7'b0111111

`endif
