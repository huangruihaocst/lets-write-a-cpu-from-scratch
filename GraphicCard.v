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
	 input ppu_fclk, 
	 input ppu_rst,
	 
	 input ppu_wrn,
	 input [9:0] ppu_sprite_x,
	 input [8:0] ppu_sprite_y,
	 input [7:0] ppu_sprite_id,
	 
	 output ppu_hs,
	 output ppu_vs,
	 output [2:0] ppu_red,
	 output [2:0] ppu_green,
	 output [2:0] ppu_blue
);

wire [7:0] kb_code;
wire [2:0] r;
wire [2:0] g;
wire [2:0] b;
wire [18:0] addr;

GraphRam gr (
	.ored(r), .ogreen(g), .oblue(b),
	.addr(addr), .sprite_x(ppu_sprite_x), .sprite_y(ppu_sprite_y),
	.sprite_id(ppu_sprite_id), .wrn(ppu_wrn)
);

VGA_Controller vga (
	.hs(ppu_hs), .vs(ppu_vs),
	.ored(ppu_red), .ogreen(ppu_green), .oblue(ppu_blue),
	.R(r), .G(g), .B(b),
	.reset(ppu_rst), .CLK_in(ppu_fclk),
	.addr(addr)
);

endmodule
