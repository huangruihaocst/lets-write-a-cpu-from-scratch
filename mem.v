`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:11:22 11/16/2016 
// Design Name: 
// Module Name:    mem 
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
module mem(
	 input [15:0] memi_instr,
	 input [15:0] memi_pc,
	 input [15:0] memi_data,
	 input [3:0] memi_wreg_addr,
	 input [15:0] memi_mem_addr,
	 input [1:0] memi_rwe,
	 
	 output [15:0] memo_instr,
	 output [15:0] memo_pc,
	 output [15:0] memo_result,
	 output [3:0] memo_wreg_addr,
	 output memo_reg_wrn,
	 
	 output memo_ram1_en,
	 output memo_ram1_we,
	 output memo_ram1_oe,
	 output [15:0] memo_ram1_addr,
	 inout [15:0] memio_ram1_data
    );
	 
	reg [15:0] result;
	reg [15:0] data;
	reg [15:0] addr;
	reg ram1_en;
	reg ram1_oe;
	reg ram1_we;
	
	initial begin
		ram1_en = 0;
		ram1_oe = 1;
		ram1_we = 1;
		data = 16'hcc;
	end
	
	always begin
		if (memi_rwe == `RWE_READ_MEM || memi_rwe == `RWE_WRITE_MEM) begin
			addr = memi_data;
			if (memi_rwe == `RWE_READ_MEM) begin
				ram1_oe = 0;
				ram1_we = 1;
				result = memio_ram1_data;
			end else begin
				ram1_we = 0;
				ram1_oe = 1;
				result = 0;
			end
		end else begin
			addr = 0;
			ram1_oe = 1;
			ram1_we = 1;
			// We don't read/write memory, so pass the input data to result.
			result = memi_data;
		end
	end

	assign memo_instr = memi_instr;
	assign memo_pc = memo_pc;
	assign memo_wreg_addr = memi_wreg_addr;
	assign memo_result = result;
	assign memo_reg_wrn = memi_rwe == `RWE_WRITE_REG || memi_rwe == `RWE_READ_MEM;
	
	assign memo_ram1_en = ram1_en;
	assign memo_ram1_oe = ram1_oe;
	assign memo_ram1_we = ram1_we;
	assign memo_ram1_addr = addr;
	assign memio_ram1_data = (ram1_we == 0) ? data : 16'bZZZZZZZZZZZZZZZZ;
endmodule
