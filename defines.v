`ifndef DEFINES_V
`define DEFINES_v

`define RWE_IDLE		 	2'b00
`define RWE_WRITE_REG 	2'b01
`define RWE_READ_MEM		2'b10
`define RWE_WRITE_MEM	2'b11

`define ALU_OPCODE_ADD			1
`define ALU_OPCODE_SUB			2
`define ALU_OPCODE_AND			3
`define ALU_OPCODE_SHIFT_LEFT	8

`define INSTR_OPCODE5_NOP		5'b00001
`define INSTR_OPCODE5_ADDIU	5'b01001
`define INSTR_OPCODE5_LW		5'b10011
`define INSTR_OPCODE5_SW		5'b11011
`define INSTR_OPCODE5_B			5'b00010
`define INSTR_OPCODE5_LI		5'b01101

`define INSTR_OPCODE5_SLL		5'b00110
`define INSTR_OPCODE_LOW2_SLL	2'b00

`define REG_INVALID		4'b1111

`define ADDR_SERIAL_PORT		16'hbf00

`endif
