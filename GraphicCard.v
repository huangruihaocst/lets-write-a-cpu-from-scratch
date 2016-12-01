`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:46:46 11/20/2016 
// Design Name: 
// Module Name:    GraphicCard 
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
module GraphicCard(
	 input datain, 
	 input clkin,
	 input fclk, 
	 input rst,
	 input wrn,
    output [6:0] dig0,
	 output [6:0] dig1,
	 
	 input [3:0] sprite_x,
	 input [3:0] sprite_y,
	 input [8:0] sprite_id,
	 
	 output hs,
	 output vs,
	 output [2:0] red,
	 output [2:0] green,
	 output [2:0] blue,
	 output [8:0] leds
);

wire [7:0] kb_code;
wire [2:0] r;
wire [2:0] g;
wire [2:0] b;
wire [18:0] addr;

testKeyboard kb (
	.datain(datain), 
	.clkin(clkin),
	.fclk(fclk),
	.rst(rst),
	.keycode(kb_code),
	.dig0(dig0),
	.dig1(dig1)
);

GraphRam gr (
	.kb_code(kb_code),
	.ored(r), .ogreen(g), .oblue(b),
	.addr(addr), .sprite_x(sprite_x), .sprite_y(sprite_y),
	.sprite_id(sprite_id), .wrn(wrn)
);

VGA_Controller vga (
	.hs(hs), .vs(vs),
	.ored(red), .ogreen(green), .oblue(blue),
	.R(r), .G(g), .B(b),
	.reset(rst), .CLK_in(fclk), .leds(leds),
	.addr(addr)
);

endmodule
