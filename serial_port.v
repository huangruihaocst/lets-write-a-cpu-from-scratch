`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:07:39 10/25/2016 
// Design Name: 
// Module Name:    serial_port 
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
module serial_port(
	inout [7:0] bus_data,
	output [7:0] ram1_addr,
	
	output ram1_oe,
	output ram1_rw,
	output ram1_en,
	output ram2_en,
	output [15:0] my_leds,
	input uart_tbre,
	input uart_tsre,
	input uart_data_ready,
	output uart_rdn,
	output uart_wrn,
	input [7:0] sw_addr,
	input [7:0] sw_data,
	input clk,
	input rst,
	input clk50
    );

	parameter
			spWait = 0, 
			spDataReady = 1,
			spWrite = 2,
			ram1Read = 3,
			ram1Write = 4;
			
	parameter
			sIdle = 0,
			sError = 8'hff;
			
	parameter
			opRead = 1,
			opWrite = 2;

	parameter 
			spwInit = 0,
			spwReady = 1,
			spwDone = 2;
			
	parameter
			nxtWaitForOp = 0,
			nxtReadMemWaitForAddr = 1,
			nxtReadMemReady = 2,
			nxtReadMemOe = 3,
			nxtRam1DataReady = 4,
			nxtWriteMemWaitForAddr = 5,
			nxtWriteMemWaitForData = 6;
	parameter
			ram1rInit = 0,
			ram1rDataReady = 1,
			ram1rDataReady2 = 2;
	parameter 
			ram1wInit = 0,
			ram1wReady = 1;
	
	reg [7:0] sp_state;
	reg [7:0] sp_write_state;
	reg [7:0] next_op;
	reg [7:0] ram1r_state;
	reg [7:0] ram1w_state;
	
	reg sel_write_to_bus;
	reg [7:0] buf_write_to_bus;
	reg [7:0] buf_display;
	reg [7:0] buf_ram1_addr;
	reg buf_ram1_oe;
	reg buf_ram1_rw;
	reg buf_ram1_en;
	reg buf_wrn;
	reg buf_rdn;
	
	reg [7:0] reg_uart_read_data;
	reg [7:0] reg_ram1_addr;
	reg [7:0] reg_write_to_bus;
	reg [7:0] reg_sp_write_data;
	
	always @(posedge clk50) begin
		if (rst == 0) begin
			sp_state = spWait;
			sp_write_state = spwInit;
			next_op = nxtWaitForOp;
			ram1r_state = ram1rInit;
			ram1w_state = ram1wInit;
			
			sel_write_to_bus = 0;
			buf_write_to_bus = 8'h0;
			buf_display = 8'h0;
			buf_ram1_addr = 8'h0;
			buf_ram1_oe = 1;
			buf_ram1_en = 1;
			buf_ram1_rw = 1;
			buf_wrn = 1;
			buf_rdn = 1;
			
			reg_uart_read_data = 8'h0;
			reg_ram1_addr = 8'h0;
			reg_write_to_bus = 8'h0;
			reg_sp_write_data = 8'h0;
		end else begin
			case (sp_state) 
				spWait: begin
					if (uart_data_ready == 1) begin
						buf_rdn = 0;
						sp_state = spDataReady;
					end
				end
				spDataReady: begin
					sp_state = spWait;
					if (next_op == nxtWaitForOp) begin
						buf_display = bus_data;
						case (bus_data) 
							opRead: begin
								next_op = nxtReadMemWaitForAddr;
							end
							opWrite: begin
								next_op = nxtWriteMemWaitForAddr;
							end
							default: begin
								sp_state = sError;
							end
						endcase
					end else begin
						case (next_op)
							nxtReadMemWaitForAddr: begin
								buf_ram1_addr = bus_data;
								next_op = nxtWaitForOp;
								sp_state = ram1Read;
							end
							nxtWriteMemWaitForAddr: begin
								buf_ram1_addr = bus_data;
								next_op = nxtWriteMemWaitForData;
							end
							nxtWriteMemWaitForData: begin
								buf_write_to_bus = bus_data;
								next_op = nxtWaitForOp;
								sp_state = ram1Write;
							end
							default: begin
								sp_state = sError;
							end
						endcase
					end
					buf_rdn = 1;
				end
				// write `buf_write_to_bus` to serial port
				spWrite: begin
					if (sp_write_state == spwInit) begin
						buf_ram1_en = 0;
						sel_write_to_bus = 1;
						sp_write_state = spwReady;
					end else if(sp_write_state == spwReady) begin
						buf_wrn = 0;
						sp_write_state = spwDone;
					end else if(sp_write_state == spwDone) begin
						//buf_display = buf_write_to_bus;
						buf_wrn = 1;
						buf_ram1_en = 1;
						sel_write_to_bus = 0;
						sp_write_state = spwInit;
						sp_state = spWait;
					end else begin
						sp_state = sError;
					end
				end
				// buf_write_to_bus = mem[buf_ram1_addr]
				ram1Read: begin
					case (ram1r_state)
						ram1rInit: begin
							buf_ram1_oe = 0;
							ram1r_state = ram1rDataReady;
						end
						ram1rDataReady: begin
							buf_write_to_bus = bus_data;
							buf_display = bus_data;
							ram1r_state = ram1rDataReady2;
						end
						ram1rDataReady2: begin
							buf_ram1_oe = 1;
							sp_state = spWrite;
							ram1r_state = ram1rInit;
						end
						default: begin
							sp_state = sError;
						end
					endcase
				end
				// mem[buf_ram1_addr] = buf_write_to_bus
				ram1Write: begin
					case (ram1w_state)
						ram1wInit: begin
							buf_ram1_rw = 0;
							sel_write_to_bus = 1;
							ram1w_state = ram1wReady;
						end
						ram1wReady: begin
							buf_display = buf_write_to_bus;
							buf_ram1_rw = 1;
							sel_write_to_bus = 0;
							ram1w_state = ram1wInit;
							sp_state = spWait;
						end
						default: sp_state = sError;
					endcase
				end
			endcase
		end
	end

	assign bus_data = sel_write_to_bus ? buf_write_to_bus : 8'bZZZZZZZZ;
	assign my_leds[7:0] = buf_display;
	
	assign ram1_en = 0;
	assign ram1_rw = buf_ram1_rw;
	assign ram1_oe = 0;
	assign ram1_addr = buf_ram1_addr;
	assign ram2_en = 0;
	assign my_leds[15:13] = sp_state;
	assign my_leds[12:10] = next_op;
	assign my_leds[9:8] = 0;
	
	assign uart_wrn = buf_wrn;
	assign uart_rdn = buf_rdn;

endmodule
