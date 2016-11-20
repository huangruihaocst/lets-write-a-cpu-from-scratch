`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:54:18 11/16/2016 
// Design Name: 
// Module Name:    reg_file 
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
module reg_file(
	 input [3:0] regi_addr1,
	 input [3:0] regi_addr2,
	 input [3:0] regi_waddr,
	 input [15:0] regi_wdata,
	 input regi_wrn,
	 input regi_clk,
	 input regi_rst,
	 output [15:0] rego_data1,
	 output [15:0] rego_data2,
	 
	 output [15:0] rego_debug_data,
	 input [3:0] regi_debug_addr
    );

	reg [15:0] regs[0:15];
	reg [15:0] reg_out1;
	reg [15:0] reg_out2;
	integer i;
	
	assign rego_debug_data = regs[regi_debug_addr];
	
	always @(posedge regi_clk or negedge regi_rst) begin
		if (regi_rst == 0) begin
			for (i = 0; i < 16; i = i + 1) begin
				 regs[i] = i;
			end
		end else begin
			if (regi_wrn == 1) begin
				regs[regi_waddr] = regi_wdata;
			end
		end
	end
	
	assign rego_data1 = regs[regi_addr1];
	assign rego_data2 = regs[regi_addr2];

endmodule
