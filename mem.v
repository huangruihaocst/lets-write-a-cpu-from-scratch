`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:11:22 11/16/2016 
// Design Name: 
// Module Name:    mem 
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
module mem(
	 input memi_rst,
	 input memi_clk,
	 input [15:0] memi_instr,
	 input [15:0] memi_pc,
	 input [15:0] memi_data,
	 input [3:0] memi_wreg_addr,
	 input [15:0] memi_write_to_mem_data,
	 input [1:0] memi_rwe,
	 
	 output [15:0] memo_instr,
	 output [15:0] memo_pc,
	 output [15:0] memo_result,
	 output [3:0] memo_wreg_addr,
	 output memo_reg_wrn,
	 
	 output memo_ram1_en,
	 output memo_ram1_we,
	 output memo_ram1_oe,
	 output [15:0] memo_ram1_addr,
	 inout [15:0] memio_ram1_data,
	 
	 output memo_ram2_we,
	 output memo_ram2_oe,
	 output [15:0] memo_ram2_addr,
	 inout [15:0] memio_ram2_data,
	 output memo_ram2_pause_request,
	 
	 output memo_uart_wrn,
	 output memo_uart_rdn,
	 input memi_uart_data_ready,
	 
	 input [7:0] memi_ps2_scan_code,
	 input [15:0] memi_ps2_ascii,
	 input memi_ps2_data_ready,
	 output memo_ps2_rdn,
	 output memo_data_ready,
	 output memo_currently_reading_uart,
	 output uart_writeable,
	 output [15:0] memo_user_clk_cycles
    );
	 
	reg [15:0] result;
	reg [15:0] data;
	reg [15:0] addr;
	reg ram1_en;
	reg ram1_oe;
	reg ram1_we;
	reg uart_wrn;
	reg uart_rdn;
	reg write_to_data_bus;
	reg currently_reading_uart;
	reg data_ready = 0;
	
	reg ram2_we;
	reg ram2_oe;
	reg [15:0] ram2_addr;
	reg [15:0] ram2_data;
	reg ram2_pause_request;
	reg write_to_ram2;
	
	reg ps2_rdn;
	
	initial begin
		ram1_en = 0;
		ram1_oe = 1;
		ram1_we = 1;
		ram2_we = 1;
		ram2_oe = 1;
		ram2_pause_request = 0;
		write_to_ram2 = 0;
		data = 16'hcc;
		uart_wrn = 1;
		uart_rdn = 1;
		write_to_data_bus = 0;
		currently_reading_uart = 0;
		ram2_data = 0;
	end
	
	always @(posedge memi_uart_data_ready or negedge memi_rst or posedge memo_uart_rdn) begin
		if (memi_rst == 0) begin
			data_ready = 0;
		end else begin
			if (memo_uart_rdn == 1) begin
				if (memi_uart_data_ready) begin
					data_ready = 1;
				end else begin
					data_ready = 0;
				end
			end else begin
				data_ready = 0;
			end
		end
	end
	
	reg [31:0] user_clk_cnt;
	reg [15:0] user_clk_cycles;
	reg user_clk;
	always @(negedge memi_rst or posedge memi_clk) begin
		if (memi_rst == 0) begin
			user_clk_cnt = 0;
			user_clk_cycles = 0;
		end else begin
			if (user_clk_cnt == `CLK_USER_100HZ) begin
				user_clk = ~user_clk;
				if (user_clk) begin
					user_clk_cycles = user_clk_cycles + 1;
				end
				user_clk_cnt = 0;
			end else begin
				user_clk_cnt = user_clk_cnt + 1;
			end
		end
	end
	
	// f = 9600bit/s / 10bit = 960Hz
	//wire uart_writeable;
	reg uart_write_clk;
	reg uart_write_state;
	reg [31:0] clk_480hz_cnt;
	always @(negedge memi_rst or posedge memi_clk) begin
		if (memi_rst == 0) begin
			uart_write_clk = 1;
			clk_480hz_cnt = 0;
			uart_write_state = 0;
		end else begin
			if (uart_wrn == 0) begin
				uart_write_state = 1;
			end
			if (clk_480hz_cnt == `CLK_50M_TO_480HZ) begin
				uart_write_clk = ~uart_write_clk;
				clk_480hz_cnt = 0;
				if (uart_write_clk == 0) begin
					uart_write_state = 0;
				end
			end else begin
				clk_480hz_cnt = clk_480hz_cnt + 1;
			end
		end
	end
	assign uart_writeable = uart_write_clk && ~uart_write_state;
	
	always @* begin
		ram1_oe = 1;
		ram1_we = 1;
		ram2_we = 1;
		ram2_oe = 1;
		ram2_pause_request = 0;
		uart_rdn = 1;
		uart_wrn = 1;
		write_to_data_bus = 0;
		write_to_ram2 = 0;
		ps2_rdn = 1;
		if (memi_rwe == `RWE_READ_MEM || memi_rwe == `RWE_WRITE_MEM) begin
			addr = memi_data;
			if (memi_rwe == `RWE_READ_MEM) begin
				write_to_data_bus = 0;
				if (addr == `ADDR_SERIAL_PORT) begin
					//if (data_ready) begin
						uart_rdn = 0;
						result = {8'h0, memio_ram1_data[7:0]};
						currently_reading_uart = 1;
//					end else begin
//						result = 0;
//						currently_reading_uart = 0;
//					end
				end else if (addr == `ADDR_SERIAL_PORT_STATE) begin
					result = {14'h0, memi_uart_data_ready, uart_writeable};
					currently_reading_uart = 0;
				end else if (addr == `ADDR_KEYBOARD) begin
					// read keyboard;
					ps2_rdn = 0;
					result = memi_ps2_ascii;
					currently_reading_uart = 0;
				end else if (addr == `ADDR_KEYBOARD_STATE) begin
					result = memi_ps2_data_ready;
					currently_reading_uart = 0;
				end else if (addr == `ADDR_USER_CLK) begin
					result = user_clk_cycles;
					currently_reading_uart = 0;
				end else if (addr[15] == 0) begin
					// addr < `ADDR_RAM1_START, read ram2
					ram2_addr = memi_data;
					ram2_oe = 0;
					result = memio_ram2_data;
					currently_reading_uart = 0;
					ram2_pause_request = 1;
				end else begin
					ram1_oe = 0;
					result = memio_ram1_data;
					currently_reading_uart = 0;
				end
			end else begin // RWE_WRITE_MEM
				write_to_data_bus = 1;
				currently_reading_uart = 0;
				data = memi_write_to_mem_data;
				result = 0;
				if (addr == `ADDR_SERIAL_PORT) begin
					// write uart
					uart_wrn = 0;
				end else if (addr[15] == 0) begin
					ram2_we = 0;
					write_to_ram2 = 1;
					ram2_pause_request = 1;
					ram2_data = memi_write_to_mem_data;
					ram2_addr = memi_data;
				end 
				else begin
					// write memory
					ram1_we = 0;
				end
			end
		end else begin // WRITE_REG or DO NOTHING
			addr = 0;
			// We don't read/write memory, so pass the input data to result.
			result = memi_data;
			currently_reading_uart = 0;
		end
	end

	assign memo_instr = memi_instr;
	assign memo_pc = memi_pc;
	assign memo_wreg_addr = memi_wreg_addr;
	assign memo_result = result;
	assign memo_reg_wrn = memi_rwe == `RWE_WRITE_REG || memi_rwe == `RWE_READ_MEM;
	
	assign memo_ram1_en = ram1_en;
	assign memo_ram1_oe = ram1_oe;
	assign memo_ram1_we = ram1_we;
	assign memo_ram1_addr = addr;
	assign memio_ram1_data = write_to_data_bus ? data : 16'bZZZZZZZZZZZZZZZZ;
	
	assign memo_ram2_we = ram2_we;
	assign memo_ram2_oe = ram2_oe;
	assign memo_ram2_addr = ram2_addr;
	assign memio_ram2_data = write_to_ram2 ? ram2_data : 16'bZZZZZZZZZZZZZZZZ;
	assign memo_ram2_pause_request = ram2_pause_request;
	
	assign memo_ps2_rdn = ps2_rdn;
	
	assign memo_uart_wrn = uart_wrn;
	assign memo_uart_rdn = uart_rdn;
	
	assign memo_data_ready = data_ready;
	assign memo_currently_reading_uart = currently_reading_uart;
	assign memo_user_clk_cycles = user_clk_cycles;
endmodule
