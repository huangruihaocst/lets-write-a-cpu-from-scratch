`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:02:58 11/16/2016 
// Design Name: 
// Module Name:    pc 
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
module pc(
    input pci_clk,
    input pci_rst,
	 input pci_en,
    input pci_branch,
    input [15:0] pci_new_addr,
    input pci_interrupt,
    input [15:0] pci_epc,
    input [15:0] pci_ram2_data,

    output [15:0] pco_addr,
    output [15:0] pco_instr,
	 output pco_ram2_oe
    );
	
	reg [15:0] reg_pc;
	reg reg_oe;

	always @(posedge pci_clk or negedge pci_rst) begin
		if (pci_rst == 0) begin
			reg_pc = 0;
			reg_oe = 0;
		end else if (pci_en == 1) begin
			if (pci_branch == 1) begin
				reg_pc = pci_new_addr;
			end else begin
				reg_pc = reg_pc + 1;
			end
		end
	end

	assign pco_addr = reg_pc;
	assign pco_instr = pci_ram2_data;
	assign pco_ram2_oe = reg_oe;

endmodule
