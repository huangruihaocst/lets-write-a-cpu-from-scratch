`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:04:37 11/20/2016 
// Design Name: 
// Module Name:    GraphRam 
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
module GraphRam(
		input [7:0] kb_code,
		output [2:0] ored,
		output [2:0] ogreen,
		output [2:0] oblue
    );

reg [2:0] r;
reg [2:0] g;
reg [2:0] b;

always begin
	case (kb_code[7:0])
		8'h1C:
			begin 
				r = 3'b111;
				g = 3'b000;
				b = 3'b000;
			end
		8'h32:
			begin 
				r = 3'b000;
				g = 3'b000;
				b = 3'b111;
			end
		default:
			begin 
				r = 3'b010;
				g = 3'b100;
				b = 3'b110;
			end
	endcase
end

assign ored = r;
assign oblue = b;
assign ogreen = g;

endmodule
