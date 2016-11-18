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
	 input [3:0] idi_last2_reg,
	 input [15:0] idi_last2_result,
	 input [7:0] idi_cause,
	 
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
	 output ido_interrupt,
	 
	 output [3:0] ido_reg1_addr,
	 output [3:0] ido_reg2_addr
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
	end

	always begin
		// default is nop
		reg1_addr = `REG_INVALID;
		reg2_addr = `REG_INVALID;
		wreg_addr = `REG_INVALID;
		branch = 0;
		op1 = 0;
		op2 = 0;
		alu_opcode = `ALU_OPCODE_ADD;
		rwe = `RWE_IDLE;
		case (opcode5)
			`INSTR_OPCODE5_NOP: begin

			end
			`INSTR_OPCODE5_ADDIU: begin
				// check delay1-data-conflict
				// TODO: check data conflict in other instructions
				if (idi_last_reg == rx) begin
					op1 = idi_last_result;
				end else begin
					op1 = idi_reg1_data;
				end
				
				op2 = sext_imm8;
				wreg_addr = rx;
				reg1_addr = rx;
				alu_opcode = `ALU_OPCODE_ADD;
				rwe = `RWE_WRITE_REG;
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
					if (idi_last_reg == rx) begin
						op1 = idi_last_result;
					end else begin
						op1 = idi_reg1_data;
					end
					op2 = (idi_instr[4:2] == 3'b000) ? 16'h8 : {13'h0, idi_instr[4:2]};
					wreg_addr = rx;
					reg1_addr = ry;
					alu_opcode = `ALU_OPCODE_SHIFT_LEFT;
					rwe = `RWE_WRITE_REG;
				end
			end
			`INSTR_OPCODE5_LW: begin
				if (idi_last_reg == rx) begin
					op1 = idi_last_result;
				end else begin
					op1 = idi_reg1_data;
				end
				op2 = {{11{imm5[4]}},imm5};
				wreg_addr = ry;
				reg1_addr = rx;
				alu_opcode = `ALU_OPCODE_ADD;
				rwe = `RWE_READ_MEM;
			end
			`INSTR_OPCODE5_SW: begin
				if (idi_last_reg == rx) begin
					op1 = idi_last_result;
				end else begin
					op1 = idi_reg1_data;
				end 
				if (idi_last_reg == ry) begin
					write_to_mem_data = idi_last_result;
				end else begin
					write_to_mem_data = idi_reg2_data;
				end
				op2 = sext_imm5;
				reg1_addr = rx;
				reg2_addr = ry;
				wreg_addr = `REG_INVALID;
				rwe = `RWE_WRITE_MEM;
			end
			`INSTR_OPCODE5_B: begin
				new_addr = idi_addr + {{5{imm11[10]}}, imm11};
				branch = 1;
				rwe = `RWE_IDLE;
			end

		endcase
	end

	assign ido_reg1_addr = reg1_addr;
	assign ido_reg2_addr = reg2_addr;
	assign ido_addr = idi_addr;
	assign ido_instr = idi_instr;
	assign ido_alu_opcode = alu_opcode;
	assign ido_op1 = op1;
	assign ido_op2 = op2;
	assign ido_wreg_addr = wreg_addr;
	assign ido_new_pc = new_addr;
	assign ido_branch = branch;
	assign ido_rwe = rwe;
	assign ido_interrupt = 0;
	assign ido_write_to_mem_data = write_to_mem_data;
endmodule
