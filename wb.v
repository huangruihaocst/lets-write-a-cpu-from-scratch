`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:19:59 11/16/2016 
// Design Name: 
// Module Name:    wb 
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
module wb(
	 input [15:0] wbi_instr,
	 input [15:0] wbi_wreg_data,
	 input [3:0] wbi_wreg_addr,
	 input wbi_reg_wrn,
	 
	 output [3:0] wbo_wreg_addr,
	 output [15:0] wbo_wreg_data,
	 output wbo_reg_wrn
    );
	assign wbo_reg_wrn = wbi_reg_wrn;
	assign wbo_wreg_data = wbi_wreg_data;
	assign wbo_wreg_addr = wbi_wreg_addr;

endmodule
