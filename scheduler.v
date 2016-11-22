`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:54:58 11/18/2016 
// Design Name: 
// Module Name:    scheduler 
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
module scheduler(
	input schi_clk,
	input schi_rst,
	input schi_int_disable,
	input schi_int_enable,
	output scho_int_en,
	input schi_pause_request,
	input [3:0] schi_count,
	input [3:0] schi_type,
	
	input schi_hard_int,
	input schi_int,
	input schi_is_in_branch_delay_slot,
	input schi_is_branch_instr,
	input [3:0] schi_int_id,
	input [15:0] schi_epc,
	output [15:0] scho_epc,
	output [15:0] scho_ecause,
	output scho_interrupt_set_pc,
	output [15:0] scho_epc_in,
	output [3:0] scho_test_int_id,
	
	input schi_ps2_data_ready,
	input [7:0] schi_ps2_scan_code,
	output [7:0] scho_ps2_scan_code,
	output scho_ps2_rdn,
	
	output scho_pc_en,
	output scho_pi_en,
	output scho_ie_en,
	output scho_em_en,
	output scho_mw_en,
	output scho_reg_en,
	output scho_read_from_last2,
	output scho_handling_interrupt
    );
	
	wire interrupt_en;
	reg pc_en;
	reg pi_en;
	reg ie_en;
	reg em_en;
	reg mw_en;
	reg reg_en;
	
	reg rest;
	reg a;
	reg read_from_last2;
	
	reg [15:0] epc_in;
	reg [15:0] epc_out;
	reg [15:0] epc_buf_soft;
	reg [15:0] epc_buf_hard;
	reg [3:0] int_id_buf;
	
	reg is_in_branch_delay_slot;
	reg is_branch_instr;
	reg interrupt_set_pc;
	reg hard_int_p1;
	reg hard_int_p2;
	
	reg [15:0] ecause;
	reg handling_interrupt;
	reg interrupt_external_en;
	// TODO
	// 1. 现在如果屏蔽中断， 那么即使中断之后被启用， 期间发生的中断也没了
	// 2. 如果时钟频率比较快， 那么中断处理程序有时会被执行2次
	// process interrupt enable
	always @(posedge schi_int_enable or posedge schi_int_disable or negedge schi_rst) begin 
		if (schi_rst == 0) begin
			interrupt_external_en = 0;
		end
		else if (schi_int_enable) begin
			interrupt_external_en = 1;
		end else begin
			interrupt_external_en = 0;
		end
	end
	assign scho_handling_interrupt = handling_interrupt;
	assign interrupt_en = interrupt_external_en & ~handling_interrupt;
	assign scho_int_en = interrupt_en;
	
	// hard int is a edge triggered signal
	always @(negedge schi_hard_int or negedge schi_rst) begin
		if (schi_rst == 0) begin
			hard_int_p1 = 0;
			epc_buf_hard = 0;
			is_in_branch_delay_slot = 0;
			is_branch_instr = 0;
		end else if (interrupt_en) begin
			hard_int_p1 = ~hard_int_p1;
			epc_buf_hard = schi_epc;
			is_in_branch_delay_slot = schi_is_in_branch_delay_slot;
			is_branch_instr = schi_is_branch_instr;
		end
	end
	
	reg ps2_int_p1;
	reg ps2_int_p2;
	reg [15:0] epc_buf_ps2;
	reg in_bds_ps2;
	reg branch_ps2;
	reg [7:0] buffered_ps2_scan_code;
	reg ps2_rdn;

	// keyboard int is a edge triggered signal
	always @(posedge schi_clk or negedge schi_rst) begin
		if (schi_rst == 0) begin
			ps2_int_p1 = 0;
			epc_buf_ps2 = 0;
			in_bds_ps2 = 0;
			branch_ps2 = 0;
			buffered_ps2_scan_code = 0;
			ps2_rdn = 1;
		end else begin
			if (schi_ps2_data_ready && ps2_rdn) begin
				ps2_rdn = 0;
				ps2_int_p1 = ~ps2_int_p1;
				// pending ps2 interruption
				buffered_ps2_scan_code = schi_ps2_scan_code;
				epc_buf_ps2 = schi_epc;
				in_bds_ps2 = schi_is_in_branch_delay_slot;
				branch_ps2 = schi_is_branch_instr;
			end else begin
				ps2_rdn = 1;
			end
		end
	end
	
	assign scho_ps2_scan_code = buffered_ps2_scan_code;
	assign scho_ps2_rdn = ps2_rdn;
	// soft int is level triggered signal
	// This is where all interrupt is processed,
	// 	in the order of priority.
	always @(negedge schi_rst or posedge schi_clk) begin
		if (schi_rst == 0) begin
			epc_out = 0;
			interrupt_set_pc = 0;
			hard_int_p2 = 0;
			ecause = 0;
			ps2_int_p2 = 0;
			handling_interrupt = 0;
		end else begin
			interrupt_set_pc = 0;
			if (schi_int) begin
				// pending soft int or eret
				interrupt_set_pc = 1;
				if (schi_int_id == 4'b1111) begin
					epc_out = epc_in;
					ecause = `ECAUSE_NO_EXCEPTION;
					handling_interrupt = 0;
				end else begin
					epc_out = 16'h4;
					epc_in = schi_epc + 1;
					ecause = schi_int_id;
					handling_interrupt = 1;
				end
			end else if (interrupt_en) begin
				if (hard_int_p2 != hard_int_p1) begin
					hard_int_p2 = hard_int_p1;
					// pending hard int
					interrupt_set_pc = 1;
					epc_out = 16'h4;
					ecause = `ECAUSE_EXTERNAL;
					if (is_in_branch_delay_slot) begin
						epc_in = epc_buf_hard - 1;
					end else if (is_branch_instr) begin
						epc_in = epc_buf_hard;
					end else begin 
						epc_in = epc_buf_hard + 1;
					end
					handling_interrupt = 1;
				end else if (ps2_int_p2 != ps2_int_p1) begin
					ps2_int_p2 = ps2_int_p1;
					// pending ps2 int
					interrupt_set_pc = 1;
					epc_out = 16'h4;
					ecause = `ECAUSE_KEYBOARD;
					if (in_bds_ps2) begin
						epc_in = epc_buf_ps2 - 1;
					end else if (branch_ps2) begin
						epc_in = epc_buf_ps2;
					end else begin 
						epc_in = epc_buf_ps2 + 1;
					end
					handling_interrupt = 1;
				end
			end
		end
	end
	
	assign scho_epc = epc_out;
	assign scho_epc_in = epc_in;
	assign scho_ecause = ecause;
	assign scho_interrupt_set_pc = interrupt_set_pc;
	assign scho_test_int_id = int_id_buf;
	
	reg [3:0] pause_for_int;
	// pause assembly line
	always @(negedge schi_rst or posedge schi_clk) begin
		if (schi_rst == 0) begin
			pc_en = 1;
			pi_en = 1;
			ie_en = 1;
			em_en = 1;
			mw_en = 1;
			reg_en = 1;
			rest = 0;
			a = 0;
		end else begin
			if (schi_pause_request) begin
				a = ~a;
			end
		end
	end
//	assign scho_pc_en = ~schi_pause_request || a;
//	assign scho_pi_en = ~schi_pause_request || a;
//	assign scho_ie_en = ~schi_pause_request || a;
	assign scho_pc_en = pc_en;
	assign scho_pi_en = ~interrupt_set_pc;
	assign scho_ie_en = ie_en;
	assign scho_em_en = em_en;
	assign scho_mw_en = mw_en;
	assign scho_reg_en = reg_en;
	assign scho_read_from_last2 = a;
endmodule
