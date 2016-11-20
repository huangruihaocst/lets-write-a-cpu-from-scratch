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
	input schi_pause_request,
	input [3:0] schi_count,
	input [3:0] schi_type,
	
	input schi_hard_int,
	input schi_int,
	input [3:0] schi_int_id,
	input [15:0] schi_epc,
	output [15:0] scho_epc,
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
	reg interrupt_set_pc;
	
	reg int_p1;
	reg int_p2;
	reg hard_int_p1;
	reg hard_int_p2;
	
//	always @(negedge schi_int or negedge schi_rst) begin
//		if (schi_rst == 0) begin
//			int_p1 = 0;
//			epc_buf_soft = 0;
//			int_id_buf = 0;
//		end else begin
//			int_p1 = ~int_p1;
//			epc_buf_soft = schi_epc;
//			int_id_buf = schi_int_id;
//		end
//	end
	always @(negedge schi_hard_int or negedge schi_rst) begin
		if (schi_rst == 0) begin
			hard_int_p1 = 0;
			epc_buf_hard = 0;
		end else begin
			hard_int_p1 = ~hard_int_p1;
			epc_buf_hard = schi_epc;
		end
	end
	always @(negedge schi_rst or posedge schi_clk) begin
		if (schi_rst == 0) begin
			epc_out = 0;
			interrupt_set_pc = 0;
			int_p2 = 0;
			hard_int_p2 = 0;
		end else begin
			if (schi_int) begin
				// pending soft int or eret
				
				interrupt_set_pc = 1;
				if (schi_int_id == 4'b1111) begin
					epc_out = epc_in;
				end else begin
					epc_out = 16'h4;
					epc_in = schi_epc + 1;
				end
			end else if (hard_int_p2 != hard_int_p1) begin
				hard_int_p2 = hard_int_p1;
				// pending hard int
				
				interrupt_set_pc = 1;
				epc_out = 16'h4;
				epc_in = epc_buf_hard + 1;
			end else begin
				interrupt_set_pc = 0;
			end
		end
	end
	
//	always begin
//		if (schi_int) begin
//			interrupt_set_pc = 1;
//			if (schi_int_id == `INT_ID_ERET) begin
//				epc_out = epc_in;
//			end else begin
//				epc_out = 16'h4;
//			end
//		end else if (schi_hard_int) begin
//			interrupt_set_pc = 1;
//			epc_out = 16'h4;
//		end else begin
//			interrupt_set_pc = 0;
//		end
//	end
//	always @(posedge schi_hard_int or posedge schi_int or negedge schi_rst) begin
//		if (schi_rst == 0) begin
//			epc_in = 0;
//		end else if (schi_int) begin
//			if (schi_int_id != `INT_ID_ERET) begin		
//				epc_in = schi_epc;
//			end
//		end else if (schi_hard_int) begin
//			epc_in = schi_epc;
//		end
//	end
	
	assign scho_epc = epc_out;
	assign scho_epc_in = epc_in;
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
