`timescale 1ns / 1ps
`define plate_half_width 9'h40
`define plate_half_height 8'h4
`define ball_radius 9'h50
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
		input [19:0] addr,
		input [7:0] sprite_id,
		input [9:0] sprite_x,
		input [8:0] sprite_y,
		input wrn,
		output [2:0] ored,
		output [2:0] ogreen,
		output [2:0] oblue
    );
	 
//input [18:0] sprite_addr,
reg [2:0] r;
reg [2:0] g;
reg [2:0] b;

wire [9:0] x;
wire [8:0] y;

//wire [9:0] sprite_x;
//wire [8:0] sprite_y;

assign x = addr[18:9];
assign y = addr[8:0];
//assign sprite_x = sprite_addr[18:9];
//assign sprite_y = sprite_addr[8:0];

//center
reg [9:0] plate1_x;
reg [8:0] plate1_y;
reg [9:0] plate2_x;
reg [8:0] plate2_y;
reg [9:0] ball_x;
reg [8:0] ball_y;

always @(posedge wrn) begin
	case (sprite_id)
		8'h0: // plate 1
			begin
				plate1_x <= sprite_x;
				plate1_y <= sprite_y;
			end
		8'h1: // plate 2
			begin
				plate2_x <= sprite_x;
				plate2_y <= sprite_y;				
			end
		8'h2: // ball
			begin
				ball_x <= sprite_x;
				ball_y <= sprite_y;			
			end
	endcase
end

always @* begin
	r = 3'b111;
	g = 3'b000;
	b = 3'b000;
	if (x < plate1_x + `plate_half_width && x + `plate_half_width > plate1_x
	&& y < plate1_y + `plate_half_height && y + `plate_half_height > plate1_y)
	begin
		r = 3'b000;
		g = 3'b000;
		b = 3'b111;
	end
	else if (x < plate2_x + `plate_half_width && x + `plate_half_width > plate2_x
		&& y < plate2_y + `plate_half_height && y + `plate_half_height > plate2_y)
		begin
			r = 3'b000;
			g = 3'b000;
			b = 3'b111;
		end
	else if (x > ball_x && y > ball_y) begin
		if ((x - ball_x) * (x - ball_x) + (y - ball_y) * (y - ball_y) < `ball_radius) begin
			r = 3'b000;
			g = 3'b000;
			b = 3'b111;
		end
	end
	else if (x > ball_x && y <= ball_y) begin
			if ((x - ball_x) * (x - ball_x) + (ball_y - y) * (ball_y - y) < `ball_radius) begin
				r = 3'b000;
				g = 3'b000;
				b = 3'b111;
			end
	end
	else if (x <= ball_x && y > ball_y) begin
		if ((ball_x - x) * (ball_x - x) + (y - ball_y) * (y - ball_y) < `ball_radius) begin
			r = 3'b000;
			g = 3'b000;
			b = 3'b111;
		end
	end
	else if (x <= ball_x && y <= ball_y) begin
		if ((ball_x - x) * (ball_x - x) + (ball_y - y) * (ball_y - y) < `ball_radius) begin
			r = 3'b000;
			g = 3'b000;
			b = 3'b111;
		end
	end
end

assign ored = r;
assign oblue = b;
assign ogreen = g;

endmodule
