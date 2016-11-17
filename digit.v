`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:04:52 11/17/2016 
// Design Name: 
// Module Name:    digit 
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
module digit(
	input [7:0] digiti_data,
	output [6:0] digito_1,
	output [6:0] digito_2
    );
	 
	reg [6:0] d1;
	reg [6:0] d2;
	always begin
		case (digiti_data[3:0])
			0: d1 = 7'b0111111;
			1: d1 = 7'b0000110;
			2: d1 = 7'b1011011;
			3: d1 = 7'b1001111;
			4: d1 = 7'b1100110;
			5: d1 = 7'b1101101;
			6: d1 = 7'b1111101;
			7: d1 = 7'b0000111;
			8: d1 = 7'b1111111;
			9: d1 = 7'b1101111;
			10:d1 = 7'b1110111;
			11:d1 = 7'b1111100;
			12:d1 = 7'b0111001;
			13:d1 = 7'b1011110;
			14:d1 = 7'b1111001;
			15:d1 = 7'b1110001;
			default: d1 = 7'b0;
		endcase
	end
	
	always begin
		case (digiti_data[7:4])
			0: d2 = 7'b0111111;
			1: d2 = 7'b0000110;
			2: d2 = 7'b1011011;
			3: d2 = 7'b1001111;
			4: d2 = 7'b1100110;
			5: d2 = 7'b1101101;
			6: d2 = 7'b1111101;
			7: d2 = 7'b0000111;
			8: d2 = 7'b1111111;
			9: d2 = 7'b1101111;
			10:d2 = 7'b1110111;
			11:d2 = 7'b1111100;
			12:d2 = 7'b0111001;
			13:d2 = 7'b1011110;
			14:d2 = 7'b1111001;
			15:d2 = 7'b1110001;
			default: d2 = 7'b0;
		endcase
	end
	
	assign digito_1 = d1;
	assign digito_2 = d2;
endmodule
