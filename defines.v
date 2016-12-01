`ifndef DEFINES_V
`define DEFINES_v

`define RWE_IDLE		 			2'b00
`define RWE_WRITE_REG 			2'b01
`define RWE_READ_MEM				2'b10
`define RWE_WRITE_MEM			2'b11

`define ALU_OPCODE_NOP			0
`define ALU_OPCODE_ADD			1
`define ALU_OPCODE_SUB			2
`define ALU_OPCODE_AND			3
`define ALU_OPCODE_OR			4
`define ALU_OPCODE_CMP			5
`define ALU_OPCODE_SHIFT_LEFT	8
`define ALU_OPCODE_SHIFT_RIGHT_ARITH 9
`define ALU_OPCODE_SHIFT_RIGHT_LOGIC 10

`define INSTR_OPCODE5_NOP			5'b00001
`define INSTR_OPCODE5_B				5'b00010
`define INSTR_OPCODE5_BEQZ			5'b00100
`define INSTR_OPCODE5_BNEZ			5'b00101
`define INSTR_OPCODE5_SHIFT		5'b00110
`define INSTR_OPCODE5_ADDIU3		5'b01000
`define INSTR_OPCODE5_ADDIU		5'b01001
`define INSTR_OPCODE5_BRANCH_T	5'b01100
`define INSTR_OPCODE5_LI			5'b01101
`define INSTR_OPCODE5_LW_SP		5'b10010
`define INSTR_OPCODE5_LW			5'b10011
`define INSTR_OPCODE5_SW_SP		5'b11010
`define INSTR_OPCODE5_SW			5'b11011
`define INSTR_OPCODE5_SUBU			5'b11100
`define INSTR_OPCODE5_CMP			5'b11101
`define INSTR_OPCODE5_MFTIH		5'b11110
`define INSTR_OPCODE5_INT			5'b11111

`define INSTR_OPCODE_HIGH7_INT	7'b0000000
`define INSTR_OPCODE_LOW2_SUBU	2'b11
`define INSTR_OPCODE_LOW2_ADDU	2'b01
`define INSTR_OPCODE_HIGH3_BTEQZ	3'b000
`define INSTR_OPCODE_HIGH3_BTNEZ	3'b001
`define INSTR_OPCODE_HIGH3_ADDSP	3'b011
`define INSTR_OPCODE_LOW2_SLL		2'b00
`define INSTR_OPCODE_LOW2_SRL		2'b10
`define INSTR_OPCODE_LOW2_SRA		2'b11
`define INSTR_OPCODE_LOW8_JR		8'h0
`define INSTR_OPCODE_LOW5_CMP		5'b01010
`define INSTR_OPCODE_LOW8_MFPC	8'b01000000
`define INSTR_OPCODE_LOW5_AND		5'b01100
`define INSTR_OPCODE_LOW5_OR		5'b01101
`define INSTR_OPCODE_LOW8_MFIH	8'h0
`define INSTR_OPCODE_LOW8_MTIH	8'h1
`define INSTR_OPCODE_HIGH3_MTSP	3'b100
`define INSTR_OPCODE_LOW5_MTSP	5'b00000

`define REG_INVALID					4'b1111
`define REG_T							4'h9
`define REG_SP							4'ha

`define ADDR_SERIAL_PORT			16'hbf00
`define ADDR_SERIAL_PORT_STATE	16'hbf01
`define ADDR_KEYBOARD				16'hbf05
`define ADDR_KEYBOARD_STATE		16'hbf06
`define ADDR_USER_CLK				16'hbf07
`define ADDR_PLATE1_X				16'hbf08
`define ADDR_PLATE1_Y				16'h7991
`define ADDR_PLATE2_X				16'h7992
`define ADDR_PLATE2_Y				16'h7993
`define ADDR_BALL_X					16'hbf09
`define ADDR_BALL_Y					16'h7995
`define ADDR_RAM1_START				16'h8000

`define ECAUSE_NO_EXCEPTION		16'h00
`define ECAUSE_ERET					16'h0f
`define ECAUSE_EXTERNAL				16'h11
`define ECAUSE_KEYBOARD				16'h12

`define INT_ID_ERET					4'hf

`define SCHED_CONTINUE			0
`define SCHED_PAUSE_FOR_LW		1

`define CLK_50M_TO_480HZ			32'hcb72
`define CLK_USER_100HZ				32'h3d090

`define KEYBOARD_UP					16'ha0
`define KEYBOARD_DOWN				16'ha1
`define KEYBOARD_LEFT				16'ha2
`define KEYBOARD_RIGHT				16'ha3

`define SPRITE_ID_PLATE1			0
`define SPRITE_ID_PLATE2			1
`define SPRITE_ID_BALL				2

`endif
