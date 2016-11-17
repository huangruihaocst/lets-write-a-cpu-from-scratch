`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:46:23 11/16/2016 
// Design Name: 
// Module Name:    pc_id 
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
module pc_id(
	 input [15:0] pii_addr,
	 input [15:0] pii_instr,
	 input pii_clk,
	 input pii_rst,
	 input pii_en,
	 output [15:0] pio_addr,
	 output [15:0] pio_instr
    );
	reg [15:0] addr;
	reg [15:0] instr;
	always @(posedge pii_clk or negedge pii_rst) begin
		if (pii_rst == 0) begin
			addr = 16'h0;
			instr = 16'h0;
		end else if (pii_en == 1) begin 
			addr = pii_addr;
			instr = pii_instr;
		end
	end
	
	assign pio_addr = addr;
	assign pio_instr = instr;

endmodule
