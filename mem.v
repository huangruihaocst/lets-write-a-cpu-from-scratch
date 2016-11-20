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
	 
	 output memo_uart_wrn,
	 output memo_uart_rdn,
	 input memi_uart_data_ready
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
	
	initial begin
		ram1_en = 0;
		ram1_oe = 1;
		ram1_we = 1;
		data = 16'hcc;
		uart_wrn = 1;
		uart_rdn = 1;
		write_to_data_bus = 0;
		currently_reading_uart = 0;
	end
	
	always @* begin
		if (memi_rwe == `RWE_READ_MEM || memi_rwe == `RWE_WRITE_MEM) begin
			addr = memi_data;
			if (memi_rwe == `RWE_READ_MEM) begin
				write_to_data_bus = 0;
				uart_wrn = 1;
				ram1_we = 1;
				if (addr == `ADDR_SERIAL_PORT) begin
					if (memi_uart_data_ready || currently_reading_uart) begin
						uart_rdn = 0;
						result = {8'h0, memio_ram1_data[7:0]};
						currently_reading_uart = 1;
					end else begin
						uart_rdn = 1;
						result = 0;
						currently_reading_uart = 0;
					end
					ram1_oe = 1;
				end else if (addr == `ADDR_SERIAL_PORT_STATE) begin
					uart_rdn = 1;
					ram1_oe = 1;
					result = memi_uart_data_ready ? 16'h3 : 16'h1; //{14'h1f, memi_uart_data_ready, 1};
					currently_reading_uart = 0;
				end else begin	
					uart_rdn = 1;
					ram1_oe = 0;
					result = memio_ram1_data;
					currently_reading_uart = 0;
				end
			end else begin // RWE_WRITE_MEM
				write_to_data_bus = 1;
				currently_reading_uart = 0;
				data = memi_write_to_mem_data;
				result = 0;
				ram1_oe = 1;
				uart_rdn = 1;
				if (addr == `ADDR_SERIAL_PORT) begin
					// write uart
					uart_wrn = 0;
					ram1_we = 1;
				end else begin
					// write memory
					uart_wrn = 1;
					ram1_we = 0;
				end
			end
		end else begin // WRITE_REG or DO NOTHING
			write_to_data_bus = 0;
			uart_wrn = 1;
			uart_rdn = 1;
			addr = 0;
			ram1_oe = 1;
			ram1_we = 1;
			// We don't read/write memory, so pass the input data to result.
			result = memi_data;
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
	
	assign memo_uart_wrn = uart_wrn;
	assign memo_uart_rdn = uart_rdn;
endmodule
