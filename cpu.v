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
module cpu(
	 input cpu_rst,
	 input cpu_clk,
	 input cpu_clk50,
	 input cpu_clk11,
	 
	 input [15:0] cpu_sw,
	 input [3:0] cpu_btn,
	 output [15:0] cpu_led,
	 output [6:0] cpu_digit1,
	 output [6:0] cpu_digit2,
	 
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
	wire pci_branch;
	wire [15:0] pii_addr;
	wire [15:0] pii_instr;
	wire [15:0] pci_ram2_data;
	wire pco_ram2_oe;

	pc cpu_pc (
		.pci_clk(cpu_clk),
		.pci_rst(cpu_rst),
		.pci_branch(pci_branch),
		.pci_new_addr(pci_new_addr),
		.pci_interrupt(0),
		.pci_epc(0),
		.pci_en(1),
		.pco_instr(pii_instr),
		.pco_addr(pii_addr),
		.pci_ram2_data(pci_ram2_data),
		.pco_ram2_oe(pco_ram2_oe)
	);
	
	wire [15:0] pio_addr;
	wire [15:0] pio_instr;
	pc_id cpu_pc_id (
		.pii_addr(pii_addr),
		.pii_instr(pii_instr),
		.pii_clk(cpu_clk),
		.pii_rst(cpu_rst),
		.pii_en(1),
		.pio_addr(pio_addr),
		.pio_instr(pio_instr)
	);
	
	wire [15:0] rego_data1;
	wire [15:0] rego_data2;
	wire [15:0] iei_addr;
	wire [15:0] iei_instr;
	wire [7:0] iei_alu_opcode;
	wire [15:0] iei_op1;
	wire [15:0] iei_op2;
	wire [3:0] iei_wreg_addr;
	wire [1:0] iei_rwe;
	wire ido_interrupt;
	
	wire [3:0] regi_addr1;
	wire [3:0] regi_addr2;
	wire [3:0] regi_waddr;
	wire [15:0] regi_wdata;
	wire regi_wrn;
	
	wire [15:0] emi_data;
	wire [3:0] emi_wreg_addr;
	wire [1:0] emi_rwe;
	
	wire [15:0] mwi_result;
	wire [3:0] mwi_wreg_addr;
	wire mwi_reg_wrn;
	
	id cpu_id (
		.idi_addr(pio_addr),
		.idi_instr(pio_instr),
		.idi_reg1_data(rego_data1),
		.idi_reg2_data(rego_data2),
		
		.idi_last_reg(emi_wreg_addr),
		.idi_last_result(emi_data),
		.idi_last_rwe(emi_rwe),
		.idi_last2_reg(mwi_wreg_addr),
		.idi_last2_result(mwi_result),
		
		.idi_cause(0),
	 
		.ido_addr(iei_addr),
		.ido_instr(iei_instr),
		.ido_alu_opcode(iei_alu_opcode),
		.ido_op1(iei_op1),
		.ido_op2(iei_op2),
		.ido_wreg_addr(iei_wreg_addr),
		.ido_rwe(iei_rwe),
		.ido_new_pc(pci_new_addr),
		.ido_branch(pci_branch),
		.ido_interrupt(ido_interrupt),
		
		.ido_reg1_addr(regi_addr1),
		.ido_reg2_addr(regi_addr2)
	);

	reg_file cpu_reg_file (
		.regi_addr1(regi_addr1),
		.regi_addr2(regi_addr2),
		.regi_waddr(regi_waddr),
		.regi_wdata(regi_wdata),
		.regi_wrn(regi_wrn),
		.regi_clk(cpu_clk),
		.regi_rst(cpu_rst),
		.rego_data1(rego_data1),
		.rego_data2(rego_data2)
	);
	
	wire [15:0] ieo_instr;
	wire [15:0] ieo_pc;
	wire [7:0] ieo_alu_opcode;
	wire [15:0] ieo_op1;
	wire [15:0] ieo_op2;
	wire [15:0] ieo_wreg_addr;
	wire [1:0] ieo_rwe;
	id_exe cpu_id_exe (
		.iei_clk(cpu_clk),
		.iei_rst(cpu_rst),
		.iei_en(1),
	
		.iei_instr(iei_instr),
		.iei_pc(iei_pc),
		.iei_alu_opcode(iei_alu_opcode),
		.iei_op1(iei_op1),
		.iei_op2(iei_op2),
		.iei_wreg_addr(iei_wreg_addr),
		.iei_rwe(iei_rwe),
	
		.ieo_instr(ieo_instr),
		.ieo_pc(ieo_pc),
		.ieo_alu_opcode(ieo_alu_opcode),
		.ieo_op1(ieo_op1),
		.ieo_op2(ieo_op2),
		.ieo_wreg_addr(ieo_wreg_addr),
		.ieo_rwe(ieo_rwe)
	);
	
	wire [15:0] emi_instr;
	wire [15:0] emi_pc;

	exe cpu_exe (
		.exei_instr(ieo_instr),
		.exei_pc(ieo_pc),
		.exei_alu_opcode(ieo_alu_opcode),
		.exei_op1(ieo_op1),
		.exei_op2(ieo_op2),
		.exei_wreg_addr(ieo_wreg_addr),
		.exei_rwe(ieo_rwe),
	
		.exeo_instr(emi_instr),
		.exeo_pc(emi_pc),
		.exeo_result(emi_data),
		.exeo_mem_addr(emi_mem_addr),
		.exeo_wreg_addr(emi_wreg_addr),
		.exeo_rwe(emi_rwe)
	);
	
	wire [15:0] emo_instr;
	wire [15:0] emo_pc;
	wire [15:0] emo_data;
	wire [3:0] emo_wreg_addr;
	wire [15:0] emo_mem_addr;
	wire [1:0] emo_rwe;
	exe_mem cpu_exe_mem(
		.emi_clk(cpu_clk),
		.emi_rst(cpu_rst),
		.emi_en(1),
	 
		.emi_instr(emi_instr),
		.emi_pc(emi_pc),
		.emi_data(emi_data),
		.emi_wreg_addr(emi_wreg_addr),
		.emi_mem_addr(emi_mem_addr),
		.emi_rwe(emi_rwe),
	 
		.emo_instr(emo_instr),
		.emo_pc(emo_pc),
		.emo_data(emo_data),
		.emo_wreg_addr(emo_wreg_addr),
		.emo_mem_addr(emo_mem_addr),
		.emo_rwe(emo_rwe)
	);
	
	wire [15:0] mwi_instr;
	wire [15:0] mwi_pc;

	mem cpu_mem(
		.memi_instr(emo_instr),
		.memi_pc(emo_pc),
		.memi_data(emo_data),
		.memi_wreg_addr(emo_wreg_addr),
		.memi_mem_addr(emo_mem_addr),
		.memi_rwe(emo_rwe),

		.memo_instr(mwi_instr),
		.memo_pc(mwi_pc),
		.memo_result(mwi_result),
		.memo_wreg_addr(mwi_wreg_addr),
		.memo_reg_wrn(mwi_reg_wrn),
		
		.memo_ram1_en(ram1_en),
		.memo_ram1_we(ram1_we),
		.memo_ram1_oe(ram1_oe),
		.memo_ram1_addr(ram1_addr_bus),
		.memio_ram1_data(ram1_data_bus)
	);
	
	wire [15:0] mwo_instr;
	wire [15:0] mwo_pc;
	wire [15:0] mwo_result;
	wire [3:0] mwo_wreg_addr;
	wire mwo_reg_wrn;
	mem_wb cpu_mem_wb(
		.mwi_clk(cpu_clk),
		.mwi_rst(cpu_rst),
		.mwi_en(1),
	 
		.mwi_instr(mwi_instr),
		.mwi_pc(mwi_pc),
		.mwi_result(mwi_result),
		.mwi_wreg_addr(mwi_wreg_addr),
		.mwi_reg_wrn(mwi_reg_wrn),
	 
		.mwo_instr(mwo_instr),
		.mwo_pc(mwo_pc),
		.mwo_result(mwo_result),
		.mwo_wreg_addr(mwo_wreg_addr),
		.mwo_reg_wrn(mwo_reg_wrn)
	);
	
	wb cpu_wb(
		.wbi_instr(mwo_instr),
		.wbi_wreg_data(mwo_result),
		.wbi_wreg_addr(mwo_wreg_addr),
		.wbi_reg_wrn(mwo_reg_wrn),
		
		.wbo_wreg_addr(regi_waddr),
		.wbo_wreg_data(regi_wdata),
		.wbo_reg_wrn(regi_wrn)
	);
	
	wire [7:0] cpu_digit_data;
	digit cpu_digit(
		.digiti_data(cpu_digit_data),
		.digito_1(cpu_digit1),
		.digito_2(cpu_digit2)
	);

	assign cpu_led[3:0] = regi_waddr;
	assign cpu_led[7:4] = iei_wreg_addr;
	assign cpu_led[15] = mwo_reg_wrn;
	assign cpu_led[14:13] = emi_rwe;
	assign cpu_led[12:9] = emi_wreg_addr;
	assign cpu_led[8] = pci_branch;
	assign cpu_digit_data = regi_wdata[7:0]; 
	
	//assign ram1_en = 1;
	//assign ram1_we = 1;
	//assign ram1_oe = 1;
	//assign ram1_addr_bus = 16'h0;
	//assign ram1_data_bus = 16'hZZ;
	
	assign ram2_en = 0;
	assign ram2_we = 1;
	assign ram2_oe = pco_ram2_oe;
	assign ram2_addr_bus = pii_addr;
	assign pci_ram2_data = ram2_data_bus;
	
	assign uart_wrn = 1;
	assign uart_rdn = 1;

endmodule
