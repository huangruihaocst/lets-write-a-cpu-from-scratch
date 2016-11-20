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
	
	wire my_clk;

	
	reg slow_clk;
	reg [31:0] counter;
	always @(posedge cpu_clk50 or negedge cpu_rst) begin
		if (cpu_rst == 0) begin
			counter = 0;
			slow_clk = 0;
		end else begin
			counter = counter + 1;
			if (counter == {8'h0, cpu_sw[15:8], 16'h0}) begin
				counter = 0;
				slow_clk = !slow_clk;
			end
		end
	end
	//assign my_clk = cpu_clk;
	assign my_clk = slow_clk;
	
	wire pci_en;
	wire [15:0] pci_new_addr;
	wire pci_branch;
	wire [15:0] pii_addr;
	wire [15:0] pii_instr;
	wire [15:0] pci_ram2_data;
	wire pco_ram2_oe;

	wire [15:0] scho_epc;
	wire scho_interrupt_set_pc;
	
	pc cpu_pc (
		.pci_clk(my_clk),
		.pci_rst(cpu_rst),
		.pci_branch(pci_branch),
		.pci_new_addr(pci_new_addr),
		.pci_interrupt(scho_interrupt_set_pc),
		.pci_epc(scho_epc),
		.pci_en(pci_en),
		.pco_instr(pii_instr),
		.pco_addr(pii_addr),
		.pci_ram2_data(pci_ram2_data),
		.pco_ram2_oe(pco_ram2_oe)
	);
	
	wire pii_en;
	wire [15:0] pio_addr;
	wire [15:0] pio_instr;
	pc_id cpu_pc_id (
		.pii_addr(pii_addr),
		.pii_instr(pii_instr),
		.pii_clk(my_clk),
		.pii_rst(cpu_rst),
		.pii_en(pii_en),
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
	wire [15:0] iei_write_to_mem_data;
	wire [1:0] iei_rwe;
	
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
	
	wire scho_read_from_last2;
	wire schi_pause_request;
	wire [3:0] schi_count;
	wire [3:0] schi_type;
	wire schi_int;
	wire [3:0] schi_int_id;
	
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
		.ido_int(schi_int),
		.ido_int_id(schi_int_id),
	 
		.ido_addr(iei_addr),
		.ido_instr(iei_instr),
		.ido_alu_opcode(iei_alu_opcode),
		.ido_op1(iei_op1),
		.ido_op2(iei_op2),
		.ido_wreg_addr(iei_wreg_addr),
		.ido_write_to_mem_data(iei_write_to_mem_data),
		.ido_rwe(iei_rwe),
		.ido_new_pc(pci_new_addr),
		.ido_branch(pci_branch),
		
		.ido_reg1_addr(regi_addr1),
		.ido_reg2_addr(regi_addr2),
		
		.ido_pause_request(schi_pause_request),
		.ido_sched_type(schi_type),
		.ido_sched_count(schi_count),
		.idi_read_from_last2(scho_read_from_last2)
	);

	wire [3:0] regi_debug_addr;
	wire [15:0] rego_debug_data;
	reg_file cpu_reg_file (
		.regi_addr1(regi_addr1),
		.regi_addr2(regi_addr2),
		.regi_waddr(regi_waddr),
		.regi_wdata(regi_wdata),
		.regi_wrn(regi_wrn),
		.regi_clk(my_clk),
		.regi_rst(cpu_rst),
		.rego_data1(rego_data1),
		.rego_data2(rego_data2),
		.regi_debug_addr(regi_debug_addr),
		.rego_debug_data(rego_debug_data)
	);
	
	wire iei_en;
	wire [15:0] ieo_instr;
	wire [15:0] ieo_pc;
	wire [7:0] ieo_alu_opcode;
	wire [15:0] ieo_op1;
	wire [15:0] ieo_op2;
	wire [3:0] ieo_wreg_addr;
	wire [1:0] ieo_rwe;
	wire [15:0] ieo_write_to_mem_data;
	id_exe cpu_id_exe (
		.iei_clk(my_clk),
		.iei_rst(cpu_rst),
		.iei_en(iei_en),
	
		.iei_instr(iei_instr),
		.iei_pc(iei_pc),
		.iei_alu_opcode(iei_alu_opcode),
		.iei_op1(iei_op1),
		.iei_op2(iei_op2),
		.iei_wreg_addr(iei_wreg_addr),
		.iei_write_to_mem_data(iei_write_to_mem_data),
		.iei_rwe(iei_rwe),
	
		.ieo_instr(ieo_instr),
		.ieo_pc(ieo_pc),
		.ieo_alu_opcode(ieo_alu_opcode),
		.ieo_op1(ieo_op1),
		.ieo_op2(ieo_op2),
		.ieo_wreg_addr(ieo_wreg_addr),
		.ieo_write_to_mem_data(ieo_write_to_mem_data),
		.ieo_rwe(ieo_rwe)
	);
	
	wire [15:0] emi_instr;
	wire [15:0] emi_pc;
	wire [15:0] emi_write_to_mem_data;

	exe cpu_exe (
		.exei_instr(ieo_instr),
		.exei_pc(ieo_pc),
		.exei_alu_opcode(ieo_alu_opcode),
		.exei_op1(ieo_op1),
		.exei_op2(ieo_op2),
		.exei_wreg_addr(ieo_wreg_addr),
		.exei_write_to_mem_data(ieo_write_to_mem_data),
		.exei_rwe(ieo_rwe),
	
		.exeo_instr(emi_instr),
		.exeo_pc(emi_pc),
		.exeo_result(emi_data),
		.exeo_wreg_addr(emi_wreg_addr),
		.exeo_write_to_mem_data(emi_write_to_mem_data),
		.exeo_rwe(emi_rwe)
	);
	
	wire emi_en;
	wire [15:0] emo_instr;
	wire [15:0] emo_pc;
	wire [15:0] emo_data;
	wire [3:0] emo_wreg_addr;
	wire [1:0] emo_rwe;
	wire [15:0] emo_write_to_mem_data;
	
	exe_mem cpu_exe_mem(
		.emi_clk(my_clk),
		.emi_rst(cpu_rst),
		.emi_en(emi_en),
	 
		.emi_instr(emi_instr),
		.emi_pc(emi_pc),
		.emi_data(emi_data),
		.emi_wreg_addr(emi_wreg_addr),
		.emi_write_to_mem_data(emi_write_to_mem_data),
		.emi_rwe(emi_rwe),
	 
		.emo_instr(emo_instr),
		.emo_pc(emo_pc),
		.emo_data(emo_data),
		.emo_wreg_addr(emo_wreg_addr),
		.emo_write_to_mem_data(emo_write_to_mem_data),
		.emo_rwe(emo_rwe)
	);
	
	wire [15:0] mwi_instr;
	wire [15:0] mwi_pc;

	mem cpu_mem(
		.memi_instr(emo_instr),
		.memi_pc(emo_pc),
		.memi_data(emo_data),
		.memi_wreg_addr(emo_wreg_addr),
		.memi_write_to_mem_data(emo_write_to_mem_data),
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
		.memio_ram1_data(ram1_data_bus),
		
		.memi_uart_data_ready(uart_data_ready),
		.memo_uart_wrn(uart_wrn),
		.memo_uart_rdn(uart_rdn)
	);
	
	wire mwi_en;
	wire [15:0] mwo_instr;
	wire [15:0] mwo_pc;
	wire [15:0] mwo_result;
	wire [3:0] mwo_wreg_addr;
	wire mwo_reg_wrn;
	mem_wb cpu_mem_wb(
		.mwi_clk(my_clk),
		.mwi_rst(cpu_rst),
		.mwi_en(mwi_en),
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
	
	wire schi_hard_int;
	wire [15:0] scho_epc_in;
	wire [3:0] scho_test_int_id;
	
	assign schi_hard_int = ~cpu_btn[0];
	scheduler cpu_sched(
		.schi_clk(my_clk),
		.schi_rst(cpu_rst),
		.schi_pause_request(schi_pause_request),
		.schi_count(schi_count),
		.schi_type(schi_type),
		
		.schi_hard_int(schi_hard_int),
		.schi_int(schi_int),
		.schi_int_id(schi_int_id),
		.schi_epc(pio_addr),
		.scho_epc(scho_epc),
		.scho_interrupt_set_pc(scho_interrupt_set_pc),
		.scho_epc_in(scho_epc_in),
		.scho_test_int_id(scho_test_int_id),
	
		.scho_pc_en(pci_en),
		.scho_pi_en(pii_en),
		.scho_ie_en(iei_en),
		.scho_em_en(emi_en),
		.scho_mw_en(mwi_en),
		.scho_reg_en(regi_en),
		
		.scho_read_from_last2(scho_read_from_last2)

	);

//	assign cpu_led[7:0] =mwo_result[7:0];
//	assign cpu_led[15] = pci_en;
//	assign cpu_led[14] = pii_en;
//	assign cpu_led[13] = iei_en;
//	assign cpu_led[12] = emi_en;
//	assign cpu_led[11] = mwi_en;
//	assign cpu_led[10] = schi_pause_request;
//	assign cpu_led[9] = uart_rdn;
//	assign cpu_led[8] = uart_data_ready;
	assign cpu_led[15] = uart_data_ready;
	assign cpu_led[14:8] = rego_debug_data;
	assign cpu_led[7:0] = mwi_result[7:0];
	assign cpu_digit_data = pii_addr[7:0]; 
	assign regi_debug_addr = cpu_sw[7:0];
	
	//assign ram1_en = 0;
	//assign ram1_we = 1;
	//assign ram1_oe = 1;
	//assign ram1_addr_bus = 16'h0;
	//assign ram1_data_bus = 16'hZZ;
	
	assign ram2_en = 0;
	assign ram2_we = 1;
	assign ram2_oe = pco_ram2_oe;
	assign ram2_addr_bus = pii_addr;
	assign pci_ram2_data = ram2_data_bus;
	
	//assign uart_wrn = 1;
	//assign uart_rdn = 1;

endmodule
