`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:50:34 11/16/2016 
// Design Name: 
// Module Name:    id 
// Project Name: 
// Target Devices: 
// Tool versions: 
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
module id(
	 input [15:0] idi_addr,
	 input [15:0] idi_instr,
	 input [15:0] idi_reg1_data,
	 input [15:0] idi_reg2_data,
	 
	 input [1:0] idi_last_rwe,
	 input [3:0] idi_last_reg,
	 input [15:0] idi_last_result,
	 
	 input [1:0] idi_read_from_last2,
	 input [3:0] idi_last2_reg,
	 input [15:0] idi_last2_result,
	 input [1:0] idi_last2_rwe,
	 
	 input [3:0] idi_last3_reg,
	 input [15:0] idi_last3_result,
	 input idi_last3_wrn,

	 input [7:0] idi_cause,
	 output ido_int,
	 output [3:0] ido_int_id,
	 
	 output [15:0] ido_addr,
	 output [15:0] ido_instr,
	 output [7:0] ido_alu_opcode,
	 output [15:0] ido_op1,
	 output [15:0] ido_op2,
	 output [3:0] ido_wreg_addr,
	 output [15:0] ido_write_to_mem_data,
	 output [15:0] ido_new_pc,
	 output [1:0] ido_rwe,
	 output ido_branch,
	 
	 output [3:0] ido_reg1_addr,
	 output [3:0] ido_reg2_addr,
	 
	 output ido_pause_request,
	 output [3:0] ido_sched_count,
	 output [3:0] ido_sched_type
    );
	
	wire [2:0] rx;
	wire [2:0] ry;
	wire [2:0] rz;
	wire [4:0] opcode5;
	wire [10:0] imm11;
	wire [7:0] imm8;
	wire [4:0] imm5;
	wire [15:0] sext_imm8;
	wire [15:0] zext_imm8;
	wire [15:0] sext_imm5;
	
	reg [3:0] try_r1;
	reg [3:0] try_r2;
	reg [15:0] r1_data;
	reg [15:0] r2_data;
	
	assign opcode5 = idi_instr[15:11];
	assign rx = idi_instr[10:8];
	assign ry = idi_instr[7:5];
	assign rz = idi_instr[4:2];
	assign imm11= idi_instr[10:0];
	assign imm8 = idi_instr[7:0];
	assign sext_imm8 = {{8{imm8[7]}},imm8};
	assign zext_imm8 = {8'h0, imm8};
	assign imm5 = idi_instr[4:0];
	assign sext_imm5 = {{11{imm5[4]}}, imm5};
	
	reg [3:0] reg1_addr;
	reg [3:0] reg2_addr;
	reg [7:0] alu_opcode;
	reg [15:0] op1;
	reg [15:0] op2;
	reg [3:0] wreg_addr;
	reg [1:0] rwe;
	reg [15:0] new_addr;
	reg branch;
	reg [15:0] write_to_mem_data;
	reg [3:0] sched_count;
	reg [3:0] sched_type;
	reg pause_request;
	reg int_happened;
	reg [3:0] int_id;
	
	initial begin
		op1 = 16'hee;
		op2 = 16'hcc;
		wreg_addr = 4'ha;
		reg1_addr = 0;
		reg2_addr = 0;
		alu_opcode = `ALU_OPCODE_ADD;
		rwe = `RWE_IDLE;
		new_addr = 0;
		branch = 0;
		write_to_mem_data = 16'h0;
		sched_type = `SCHED_CONTINUE;
		sched_count = 0;
		pause_request = 0;
		int_happened = 0;
		int_id = 0;
		try_r1 = `REG_INVALID;
		try_r2 = `REG_INVALID;
	end
	
	// solve register data conflict
	always @* begin
		r1_data = idi_reg1_data;
		r2_data = idi_reg2_data;
		
		if (idi_last3_wrn == 1) begin
			if (idi_last3_reg == try_r1) begin
				r1_data = idi_last3_result;
			end
			if (idi_last3_reg == try_r2) begin
				r2_data = idi_last3_result;
			end
		end
		if (idi_last2_rwe == `RWE_WRITE_REG || idi_last2_rwe == `RWE_READ_MEM) begin
			if (idi_last2_reg == try_r1) begin
				r1_data = idi_last2_result;
			end
			if (idi_last2_reg == try_r2) begin
				r2_data = idi_last2_result;
			end
		end 
		if (idi_last_rwe == `RWE_READ_MEM) begin
			// this is a big conflict
		end else if (idi_last_rwe == `RWE_WRITE_REG) begin
			// following are minor conflicts
			if (idi_last_reg == try_r1) begin
				r1_data = idi_last_result;
			end
			if (idi_last_reg == try_r2) begin
				r2_data = idi_last_result;
			end
		end 
	end

	always @* begin
		// default is nop
		reg1_addr = `REG_INVALID;
		reg2_addr = `REG_INVALID;
		wreg_addr = `REG_INVALID;
		branch = 0;
		op1 = 0;
		op2 = 0;
		alu_opcode = `ALU_OPCODE_NOP;
		rwe = `RWE_IDLE;
		sched_type = `SCHED_CONTINUE;
		sched_count = 0;
		pause_request = 0;
		int_happened = 0;
		int_id = 0;
		case (opcode5)
			`INSTR_OPCODE5_NOP: begin
			end
			`INSTR_OPCODE5_ADDIU: begin
//				if (idi_read_from_last2) begin
//					sched_type = `SCHED_CONTINUE;
//					op1 = idi_last2_result;
//					wreg_addr = rx;
//				end else if (idi_last_reg == rx && idi_last_rwe == `RWE_READ_MEM) begin
//					pause_request = 1;
//					sched_type = `SCHED_PAUSE_FOR_LW;
//					wreg_addr = `REG_INVALID;
//					op1 = idi_last2_result;
//				end else if (idi_last_reg == rx && idi_last_rwe == `RWE_WRITE_REG) begin
//					// delay1 data conflict
//					op1 = idi_last_result;
//					wreg_addr = rx;
//				end else begin
//					op1 = idi_reg1_data;
//					reg1_addr = rx;
//					wreg_addr = rx;
//				end
				try_r1 = rx;
				op1 = r1_data;
				op2 = sext_imm8;
				wreg_addr = rx;
				alu_opcode = `ALU_OPCODE_ADD;
				rwe = `RWE_WRITE_REG;
			end
			`INSTR_OPCODE5_SUBU: begin
				if (idi_instr[1:0] == `INSTR_OPCODE_LOW2_SUBU) begin
					try_r1 = rx;
					try_r2 = ry;
					op1 = r1_data;
					op2 = r2_data;
					wreg_addr = rz;
					alu_opcode = `ALU_OPCODE_SUB;
					rwe = `RWE_WRITE_REG;
				end
			end
			`INSTR_OPCODE5_LI: begin
				op1 = zext_imm8;
				op2 = 0;
				wreg_addr = rx;
				alu_opcode = `ALU_OPCODE_ADD;
				rwe = `RWE_WRITE_REG;
			end
			`INSTR_OPCODE5_SLL: begin
				if (idi_instr[1:0] == `INSTR_OPCODE_LOW2_SLL) begin
					try_r1 = ry;
					op1 = r1_data;
					op2 = (idi_instr[4:2] == 3'b000) ? 16'h8 : idi_instr[4:2];
					wreg_addr = rx;
					alu_opcode = `ALU_OPCODE_SHIFT_LEFT;
					rwe = `RWE_WRITE_REG;
				end
			end
			`INSTR_OPCODE5_CMP: begin
				if (idi_instr[4:0] == `INSTR_OPCODE_LOW5_CMP) begin
					try_r1 = rx;
					try_r2 = ry;
					op1 = r1_data;
					op2 = r2_data;
					wreg_addr = `REG_T;
					alu_opcode = `ALU_OPCODE_CMP;
					rwe = `RWE_WRITE_REG;
				end else if (idi_instr[7:0] == `INSTR_OPCODE_LOW8_JR) begin
					try_r1 = rx;
					op1 = r1_data;
					new_addr = op1;
					branch = 1;
				end else if (idi_instr[7:0] == `INSTR_OPCODE_LOW8_MFPC) begin
					op1 = idi_addr + 1;
					op2 = 0;
					wreg_addr = rx;
					alu_opcode = `ALU_OPCODE_ADD;
					rwe = `RWE_WRITE_REG;
				end else if (idi_instr[4:0] == `INSTR_OPCODE_LOW5_AND) begin
					try_r1 = rx;
					try_r2 = ry;
					op1 = r1_data;
					op2 = r2_data;
					wreg_addr = rx;
					alu_opcode = `ALU_OPCODE_AND;
					rwe = `RWE_WRITE_REG;
				end
			end
			// Memory instructions
			`INSTR_OPCODE5_LW: begin
				try_r1 = rx;
				op1 = r1_data;
				op2 = {{11{imm5[4]}},imm5};
				wreg_addr = ry;
				alu_opcode = `ALU_OPCODE_ADD;
				rwe = `RWE_READ_MEM;
			end
			`INSTR_OPCODE5_SW: begin
				try_r1 = rx;
				try_r2 = ry;
				op1 = r1_data;
				write_to_mem_data = r2_data;
				op2 = sext_imm5;
				alu_opcode = `ALU_OPCODE_ADD;
				wreg_addr = `REG_INVALID;
				rwe = `RWE_WRITE_MEM;
			end
			// Branch instructions
			`INSTR_OPCODE5_B: begin
				new_addr = idi_addr + {{5{imm11[10]}}, imm11} + 1;
				branch = 1;
			end
			`INSTR_OPCODE5_BNEZ: begin
				try_r1 = rx;
				op1 = r1_data;
				new_addr = idi_addr + sext_imm8 + 1;
				branch = !(op1 == 0);
			end
			`INSTR_OPCODE5_BEQZ: begin
				try_r1 = rx;
				op1 = r1_data;
				new_addr = idi_addr + sext_imm8 + 1;
				branch = op1 == 0;
			end
			`INSTR_OPCODE5_BRANCH_T: begin
				try_r1 = `REG_T;
				op1 = r1_data;
				new_addr = idi_addr + sext_imm8 + 1;
				if (rx == `INSTR_OPCODE_HIGH3_BTEQZ) begin
					branch = (op1 == 0);
				end else if (rx == `INSTR_OPCODE_HIGH3_BTNEZ) begin
					branch = (op1 != 0);
				end
			end
			// Interruptions
			`INSTR_OPCODE5_INT: begin
				if (idi_instr[10:4] == `INSTR_OPCODE_HIGH7_INT) begin
					// "INT 0xf" is defined as "ERET", but they are similar instructions
					int_happened = 1;
					int_id = idi_instr[3:0];
				end
			end
		endcase
	end

	assign ido_reg1_addr = try_r1; //reg1_addr;
	assign ido_reg2_addr = try_r2; // reg2_addr;
	assign ido_addr = idi_addr;
	assign ido_instr = idi_instr;
	assign ido_alu_opcode = alu_opcode;
	assign ido_op1 = op1;
	assign ido_op2 = op2;
	assign ido_wreg_addr = wreg_addr;
	assign ido_new_pc = new_addr;
	assign ido_branch = branch;
	assign ido_rwe = rwe;
	assign ido_write_to_mem_data = write_to_mem_data;
	assign ido_pause_request = pause_request;
	assign ido_sched_count = sched_count;
	assign ido_sched_type = sched_type;
	assign ido_int = int_happened;
	assign ido_int_id = int_id;
endmodule
