module testKeyboard (
    input datain, 
	 input clkin,
	 input fclk, 
	 input rst,
	 output [7:0] keycode,
    output [6:0] dig0,
	 output [6:0] dig1
);

wire [7:0] sc;

assign keycode = sc;

keyboard kb (
    .datain(datain), 
	 .clkin(clkin), 
	 .fclk(fclk), 
	 .rst(rst),
    .scancode(sc)
);
 
digit d0 (
    sc[3:0], dig0
);

digit d1 (
    sc[7:4], dig1
);

endmodule