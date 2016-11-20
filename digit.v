module digit (
    input [3:0] code,
    output [6:0] leds
);

reg [6:0] led;

always @(*) begin
    case (code)
        4'h0: led = 7'b0111111;
        4'h1: led = 7'b0000011;
        4'h2: led = 7'b1101101;
        4'h3: led = 7'b1001111;
        4'h4: led = 7'b1010011;
        4'h5: led = 7'b1011110;
        4'h6: led = 7'b1111110;
        4'h7: led = 7'b0000111;
        4'h8: led = 7'b1111111;
        4'h9: led = 7'b1011111;
        4'ha: led = 7'b1110111;
        4'hb: led = 7'b1111010;
        4'hc: led = 7'b0111100;
        4'hd: led = 7'b1101011;
        4'he: led = 7'b1111100;
		  4'hf: led = 7'b1110100;
    endcase
end

assign leds = led;

endmodule