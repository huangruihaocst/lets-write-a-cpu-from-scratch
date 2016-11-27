`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:16:03 11/16/2016 
// Design Name: 
// Module Name:    mem_wb 
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
module mem_wb(
	 input mwi_clk,
	 input mwi_rst,
	 input mwi_en,
	 input mwi_keep,
	 
	 input [15:0] mwi_instr,
	 input [15:0] mwi_pc,
	 input [15:0] mwi_result,
	 input [3:0] mwi_wreg_addr,
	 input mwi_reg_wrn,
	 
	 output [15:0] mwo_instr,
	 output [15:0] mwo_pc,
	 output [15:0] mwo_result,
	 output [3:0] mwo_wreg_addr,
	 output mwo_reg_wrn
	 );
	
	reg [15:0] instr;
	reg [15:0] pc;
	reg [15:0] result;
	reg [3:0] wreg_addr;
	reg wrn;
	
	initial begin
		instr = 0;
		pc = 0;
		result = 16'hdd;
		wreg_addr = `REG_INVALID;
		wrn = 0;
	end
	
	always @(posedge mwi_clk or negedge mwi_rst) begin
		if (mwi_rst == 0) begin
			instr = 0;
			pc = 0;
			result = 16'hdd;
			wreg_addr = `REG_INVALID;
			wrn = 0;
		end else begin
			if (!mwi_en) begin
				instr = 0;
				pc = 0;
				result = 16'hdd;
				wreg_addr = `REG_INVALID;
				wrn = 0;
			end else if (mwi_keep) begin
				// keep
			end else begin
				instr = mwi_instr;
				pc = mwi_pc;
				result = mwi_result;
				wreg_addr = mwi_wreg_addr;
				wrn = mwi_reg_wrn;
			end
		end
	end
	
	assign mwo_instr = instr;
	assign mwo_pc = pc;
	assign mwo_result = result;
	assign mwo_wreg_addr = wreg_addr;
	assign mwo_reg_wrn = wrn;

endmodule
