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
	 input pci_keep,
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
	reg [15:0] reg_instr;
	reg reg_oe;

	always @(posedge pci_clk or negedge pci_rst) begin
		if (pci_rst == 0) begin
			reg_pc = 0;
			reg_oe = 0;
		end else begin
			if (!pci_en) begin
				reg_oe = 1;
				if (pci_branch == 1) begin
					reg_pc = pci_new_addr - 1;
				end 
			end else if (pci_keep) begin
				reg_oe = 1;
				// keep
			end else begin
				reg_oe = 0;
				if (pci_interrupt == 1) begin
					reg_pc = pci_epc;
				end else if (pci_branch == 1) begin
					reg_pc = pci_new_addr;
				end else begin
					reg_pc = reg_pc + 1;
				end
			end
		end
	end
	always @* begin
		if (!pci_en) 
			reg_instr = 0;
		else if (!pci_keep)
			reg_instr = pci_ram2_data;
	end

	assign pco_addr = reg_pc;
	assign pco_instr = reg_instr;
	assign pco_ram2_oe = reg_oe;

endmodule
