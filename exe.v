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
	 input [1:0] exei_rwe,
	
	 output [15:0] exeo_instr,
	 output [15:0] exeo_pc,
	 output [15:0] exeo_result,
	 output [15:0] exeo_mem_addr,
	 output [3:0] exeo_wreg_addr,
	 output [1:0] exeo_rwe
	 );
	reg [15:0] result;
	
	initial begin
		result = 1;
	end
	
	always begin
		case (exei_alu_opcode) 
			`ALU_OPCODE_ADD: begin
				result = exei_op1 + exei_op2;
			end
			default: begin
				result = 16'hfe;
			end
		endcase
	end

	assign exeo_instr = exei_instr;
	assign exeo_pc = exeo_pc;
	assign exeo_result = result;
	assign exeo_wreg_addr = exei_wreg_addr;
	assign exeo_rwe = exei_rwe;
endmodule
