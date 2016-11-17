`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:23:09 11/16/2016 
// Design Name: 
// Module Name:    exe_mem 
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
module exe_mem(
	 input emi_clk,
	 input emi_rst,
	 input emi_en,
	 
	 input [15:0] emi_instr,
	 input [15:0] emi_pc,
	 input [15:0] emi_data,
	 input [3:0] emi_wreg_addr,
	 input [15:0] emi_mem_addr,
	 input [1:0] emi_rwe,
	 
	 output [15:0] emo_instr,
	 output [15:0] emo_pc,
	 output [15:0] emo_data,
	 output [3:0] emo_wreg_addr,
	 output [15:0] emo_mem_addr,
	 output [1:0] emo_rwe
    );
	
	reg [15:0] instr;
	reg [15:0] pc;
	reg [15:0] data;
	reg [3:0] wreg_addr;
	reg [15:0] mem_addr;
	reg [1:0] rwe;
	
	initial begin
		instr = 0;
		pc = 0;
		data = 0;
		wreg_addr = `REG_INVALID;
		mem_addr = 0;
		rwe = 0;
	end
	 
	always @(posedge emi_clk or negedge emi_rst) begin
		if (emi_rst == 0) begin
			instr = 0;
			pc = 0;
			data = 0;
			wreg_addr = `REG_INVALID;
			mem_addr = 0;
			rwe = 0;
		end else begin
			instr = emi_instr;
			pc = emi_pc;
			data = emi_data;
			wreg_addr = emi_wreg_addr;
			mem_addr = emi_mem_addr;
			rwe = emi_rwe;
		end
	end
	assign emo_instr = instr;
	assign emo_pc = pc;
	assign emo_data = data;
	assign emo_wreg_addr = wreg_addr;
	assign emo_mem_addr = mem_addr;
	assign emo_rwe = rwe;

endmodule
