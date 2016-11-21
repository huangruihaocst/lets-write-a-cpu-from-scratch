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
	
	output scho_pc_en,
	output scho_pi_en,
	output scho_ie_en,
	output scho_em_en,
	output scho_mw_en,
	output scho_reg_en,
	output scho_read_from_last2
    );
	
	reg interrupt_en;
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
	reg int_p1;
	reg int_p2;
	reg hard_int_p1;
	reg hard_int_p2;
	
	reg [15:0] ecause;
	// 没有处理延迟操中发生中断的情况
	always @(posedge schi_int_enable or posedge schi_int_disable or negedge schi_rst) begin 
		if (schi_rst == 0) begin
			interrupt_en = 0;
		end
		else if (schi_int_enable) begin
			interrupt_en = 1;
		end else begin
			interrupt_en = 0;
		end
	end
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
	// soft int is level triggered signal
	always @(negedge schi_rst or posedge schi_clk) begin
		if (schi_rst == 0) begin
			epc_out = 0;
			interrupt_set_pc = 0;
			int_p2 = 0;
			hard_int_p2 = 0;
			ecause = 0;
		end else if (interrupt_en) begin
			if (schi_int) begin
				// pending soft int or eret
				interrupt_set_pc = 1;
				if (schi_int_id == 4'b1111) begin
					epc_out = epc_in;
					ecause = `ECAUSE_NO_EXCEPTION;
				end else begin
					epc_out = 16'h4;
					epc_in = schi_epc + 1;
					ecause = schi_int_id;
				end
			end else if (hard_int_p2 != hard_int_p1) begin
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
				
			end else begin
				interrupt_set_pc = 0;
			end
		end
	end
	
	assign scho_epc = epc_out;
	assign scho_epc_in = epc_in;
	assign scho_ecause = ecause;
	assign scho_interrupt_set_pc = interrupt_set_pc;
	assign scho_test_int_id = int_id_buf;
	
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
//			if (rest == 1) begin
//				pc_en = 1;
//				pi_en = 1;
//				ie_en = 1;
//				em_en = 1;
//				mw_en = 1;
//				reg_en = 1;
//				rest = 0;
//			end else if (rest == 0) begin 
//				 keep enable/disable state
//				 ERROR, should never happen
//			end else begin
//				rest = rest - 1;
//			end 
		end
	end
	assign scho_pc_en = ~schi_pause_request || a;
	assign scho_pi_en = ~schi_pause_request || a;
	assign scho_ie_en = ~schi_pause_request || a;
	assign scho_em_en = em_en;
	assign scho_mw_en = mw_en;
	assign scho_reg_en = reg_en;
	assign scho_read_from_last2 = a;
endmodule
