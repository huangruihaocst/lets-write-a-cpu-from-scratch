`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:59:09 11/16/2016 
// Design Name: 
// Module Name:    exe 
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
module exe(
	 input [15:0] exei_instr,
	 input [15:0] exei_pc,
	 input [7:0] exei_alu_opcode,
	 input [15:0] exei_op1,
	 input [15:0] exei_op2,
	 input [3:0] exei_wreg_addr,
	 input [15:0] exei_write_to_mem_data, 
	 input [1:0] exei_rwe,
	 input exei_branch,
	
	 output [15:0] exeo_instr,
	 output [15:0] exeo_pc,
	 output [15:0] exeo_result,
	 output [3:0] exeo_wreg_addr,
	 output [15:0] exeo_write_to_mem_data,
	 output [1:0] exeo_rwe,
	 output exeo_branch
	 );
	reg [15:0] result;
	reg [31:0] intermediate;

	initial begin
		result = 1;
	end
	
	always @* begin
		case (exei_alu_opcode)
			`ALU_OPCODE_NOP: begin
				result = 0;
			end
			`ALU_OPCODE_ADD: begin
				result = exei_op1 + exei_op2;
			end
			`ALU_OPCODE_SUB: begin
				result = exei_op1 - exei_op2;
			end
			`ALU_OPCODE_AND: begin
				result = exei_op1 & exei_op2;
			end
			`ALU_OPCODE_OR: begin
				result = exei_op1 | exei_op2;
			end
			`ALU_OPCODE_NOT: begin
				result = ~exei_op1;
			end
			`ALU_OPCODE_CMP: begin
				result = exei_op1 == exei_op2 ? 0 : 1;
			end
			`ALU_OPCODE_SHIFT_LEFT: begin
				result = exei_op1 << exei_op2[3:0];
			end
			`ALU_OPCODE_SHIFT_RIGHT_ARITH: begin
				intermediate = {{16{exei_op1[15]}}, exei_op1};
				result = intermediate >> exei_op2[3:0];
			end
			`ALU_OPCODE_SHIFT_RIGHT_LOGIC: begin
				result = exei_op1 >> exei_op2[3:0];
			end
			default: begin
				result = 16'hfe;
			end
		endcase
	end

	assign exeo_instr = exei_instr;
	assign exeo_pc = exei_pc;
	assign exeo_result = result;
	assign exeo_wreg_addr = exei_wreg_addr;
	assign exeo_rwe = exei_rwe;
	assign exeo_write_to_mem_data = exei_write_to_mem_data;
	assign exeo_branch = exei_branch;
endmodule
