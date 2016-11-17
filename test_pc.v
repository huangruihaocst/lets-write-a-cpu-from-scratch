`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:10:59 11/16/2016 
// Design Name: 
// Module Name:    cpu 
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
module test_pc(
	 input cpu_rst,
	 input cpu_clk,
	 input cpu_clk50,
	 input cpu_clk11,
	 
	 input [15:0] cpu_sw,
	 input [3:0] cpu_btn,
	 output [15:0] cpu_led,
	 
	 output ram1_en,
	 output ram1_we,
	 output ram1_oe,
	 output [15:0] ram1_addr_bus,
	 inout [15:0] ram1_data_bus,
	 
	 output ram2_en,
	 output ram2_we,
	 output ram2_oe,
	 output [15:0] ram2_addr_bus,
	 input [15:0] ram2_data_bus,
	 
	 input uart_tbre,
	 input uart_tsre,
	 input uart_data_ready,
	 output uart_wrn,
	 output uart_rdn,
	 input uart_framing_error,
	 input uart_parity_error
    );

	wire [15:0] pci_new_addr;
	wire [15:0] pco_addr;
	wire [15:0] pco_instr;
	wire [15:0] pci_ram2_data;
	wire pco_ram2_oe;
	 
	pc cpu_pc (
		.pci_clk(cpu_clk),
		.pci_rst(cpu_rst),
		.pci_branch(~cpu_btn[0]),
		.pci_new_addr(pci_new_addr),
		.pci_epc(0),
		.pci_en(1),
		.pco_instr(pco_instr),
		.pco_addr(pco_addr),
		.pci_ram2_data(pci_ram2_data),
		.pco_ram2_oe(pco_ram2_oe)
	);

	assign pci_new_addr = {8'h0, cpu_sw[15:8]};
	assign cpu_led[7:0] = pco_instr[7:0];
	assign cpu_led[15:8] = pco_addr[7:0];
	
	assign ram1_en = 1;
	assign ram1_we = 1;
	assign ram1_oe = 1;
	assign ram1_addr_bus = 16'h0;
	assign ram1_data_bus = 16'hZ;
	
	assign ram2_en = 0;
	assign ram2_we = 1;
	assign ram2_oe = pco_ram2_oe;
	assign ram2_addr_bus = pco_addr;
	assign pci_ram2_data = ram2_data_bus;
	
	assign uart_wrn = 1;
	assign uart_rdn = 1;

endmodule
