`include "defines.v"
module keyboard (
input datain, clkin,
input fclk, rst,
input rdn,
output data_ready,
output reg [7:0] scancode,
output reg [15:0] outascii
);

reg [4:0] state;
reg [2:0] kstate;
reg [7:0] code;
reg [15:0] ascii;

reg data, clk1, clk2;
reg dataready;
reg CAPS;
reg p2, p1;
wire clk, odd;

localparam  DELAY   = 5'b00000,
            START   = 5'b00001,
            D0      = 5'b00010,
            D1      = 5'b00011,
            D2      = 5'b00100,
            D3      = 5'b00101,
            D4      = 5'b00110,
            D5      = 5'b00111,
            D6      = 5'b01000,
            D7      = 5'b01001,
            PARITY  = 5'b01010,
            STOP    = 5'b01011,
            FINISH  = 5'b01100,
            DROP    = 5'b01101,
            K_BEGIN = 3'b000,
            K_HOLD  = 3'b001,
            K_STOP  = 3'b010;


initial begin
    CAPS   = 0;
    kstate = 0;
    state  = 0;
    dataready = 0;
    p1     = 0;
    p2     = 0;
end

assign data_ready = dataready;
assign clk = (~clk1) & clk2;
assign odd = code[0] ^ code[1] ^ code[2] ^ code[3]
            ^ code[4] ^ code[5] ^ code[6] ^ code[7]; 

always @(posedge fclk) begin
    clk1 <= clkin;
    clk2 <= clk1;
    data <= datain;
end

always @(posedge fclk or negedge rst) begin
    if (rst == 0) begin
        // reset
        CAPS      <= 0;
        dataready <= 0;
        p2        <= 0;
        state     <= DELAY;
        kstate    <= K_BEGIN;
        code      <= 8'b00000000;
        ascii     <= 16'b0000000000000000;
    end
    else begin
        //when rdn is enabled (means the data is read over)
        //we can set the dataready back to zero
         if (p2 != p1) begin
             p2 <= p1;
             dataready <= 0;
        end
        case (state)
            DELAY:
                state <= START;
            START:
                if (clk) begin
                    if (!datain) begin
                        state <= D0;
                    end else begin
                        state <= DELAY;
                    end
                end
            D0:
                if (clk) begin
                    code[0] <= data;
                    state   <= D1;
                end
            D1:
                if (clk) begin
                    code[1] <= data;
                    state   <= D2;
                end
            D2:
                if (clk) begin
                    code[2] <= data;
                    state   <= D3;
                end
            D3:
                if (clk) begin
                    code[3] <= data;
                    state   <= D4;
                end
            D4:
                if (clk) begin
                    code[4] <= data;
                    state   <= D5;
                end
            D5:
                if (clk) begin
                    code[5] <= data;
                    state   <= D6;
                end
            D6:
                if (clk) begin
                    code[6] <= data;
                    state   <= D7;
                end
            D7:
                if (clk) begin
                    code[7] <= data;
                    state   <= PARITY;
                end 
            PARITY:
                if (clk) begin
                    if (datain ^ odd == 1) begin
                        state <= STOP;
                    end else begin
                        state <= DELAY;
                    end
                end
            STOP:
                if (clk) begin
                    if (data) begin
                        //for dataready (each key down only one dataready)
                        if (code == 8'hF0 || code == 8'hE0 || kstate == K_STOP) begin
                            state <= DROP;
                        end else begin
                            state <= FINISH;
                        end
                        case (kstate)
                        K_BEGIN:
                            case (code)
                            8'hF0:
                                kstate <= K_STOP;
                            8'h1C: //A
                                if (CAPS) begin
                                    ascii <= 16'h41;
                                end else begin
                                    ascii <= 16'h61;
                                end
                            8'h32: //B
                                if (CAPS) begin
                                    ascii <= 16'h42;
                                end else begin
                                    ascii <= 16'h62;
                                end
                            8'h21: //C
                                if (CAPS) begin
                                    ascii <= 16'h43;
                                end else begin
                                    ascii <= 16'h63;
                                end
                            8'h23: //D
                                if (CAPS) begin
                                    ascii <= 16'h44;
                                end else begin
                                    ascii <= 16'h64;
                                end
                            8'h24: //E
                                if (CAPS) begin
                                    ascii <= 16'h45;
                                end else begin
                                    ascii <= 16'h65;
                                end
                            8'h2B: //F
                                if (CAPS) begin
                                    ascii <= 16'h46;
                                end else begin
                                    ascii <= 16'h66;
                                end
                            8'h34: //G
                                if (CAPS) begin
                                    ascii <= 16'h47;
                                end else begin
                                    ascii <= 16'h67;
                                end
                            8'h33: //H
                                if (CAPS) begin
                                    ascii <= 16'h48;
                                end else begin
                                    ascii <= 16'h68;
                                end
                            8'h43: //I
                                if (CAPS) begin
                                    ascii <= 16'h49;
                                end else begin
                                    ascii <= 16'h69;
                                end
                            8'h3B: //J
                                if (CAPS) begin
                                    ascii <= 16'h4A;
                                end else begin
                                    ascii <= 16'h6A;
                                end
                            8'h42: //K
                                if (CAPS) begin
                                    ascii <= 16'h4B;
                                end else begin
                                    ascii <= 16'h6B;
                                end
                            8'h4B: //L
                                if (CAPS) begin
                                    ascii <= 16'h4C;
                                end else begin
                                    ascii <= 16'h6C;
                                end
                            8'h3A: //M
                                if (CAPS) begin
                                    ascii <= 16'h4D;
                                end else begin
                                    ascii <= 16'h6D;
                                end
                            8'h31: //N
                                if (CAPS) begin
                                    ascii <= 16'h4E;
                                end else begin
                                    ascii <= 16'h6E;
                                end
                            8'h44: //O
                                if (CAPS) begin
                                    ascii <= 16'h4F;
                                end else begin
                                    ascii <= 16'h6F;
                                end
                            8'h4D: //P
                                if (CAPS) begin
                                    ascii <= 16'h50;
                                end else begin
                                    ascii <= 16'h70;
                                end
                            8'h15: //Q
                                if (CAPS) begin
                                    ascii <= 16'h51;
                                end else begin
                                    ascii <= 16'h71;
                                end
                            8'h2D: //R
                                if (CAPS) begin
                                    ascii <= 16'h52;
                                end else begin
                                    ascii <= 16'h72;
                                end
                            8'h1B: //S
                                if (CAPS) begin
                                    ascii <= 16'h53;
                                end else begin
                                    ascii <= 16'h73;
                                end
                            8'h2C: //T
                                if (CAPS) begin
                                    ascii <= 16'h54;
                                end else begin
                                    ascii <= 16'h74;
                                end
                            8'h3C: //U
                                if (CAPS) begin
                                    ascii <= 16'h55;
                                end else begin
                                    ascii <= 16'h75;
                                end
                            8'h2A: //V
                                if (CAPS) begin
                                    ascii <= 16'h56;
                                end else begin
                                    ascii <= 16'h76;
                                end
                            8'h1D: //W
                                if (CAPS) begin
                                    ascii <= 16'h57;
                                end else begin
                                    ascii <= 16'h77;
                                end
                            8'h22: //X
                                if (CAPS) begin
                                    ascii <= 16'h58;
                                end else begin
                                    ascii <= 16'h78;
                                end
                            8'h35: //Y
                                if (CAPS) begin
                                    ascii <= 16'h59;
                                end else begin
                                    ascii <= 16'h79;
                                end
                            8'h1A: //Z
                                if (CAPS) begin
                                    ascii <= 16'h5A;
                                end else begin
                                    ascii <= 16'h7A;
                                end
                            8'h45: //0
                                if (CAPS) begin
                                    ascii <= 16'h29;
                                end else begin
                                    ascii <= 16'h30;
                                end
                            8'h16: //1
                                if (CAPS) begin
                                    ascii <= 16'h21;
                                end else begin
                                    ascii <= 16'h31;
                                end
                            8'h1E: //2
                                if (CAPS) begin
                                    ascii <= 16'h40;
                                end else begin
                                    ascii <= 16'h32;
                                end
                            8'h26: //3
                                if (CAPS) begin
                                    ascii <= 16'h23;
                                end else begin
                                    ascii <= 16'h33;
                                end
                            8'h25: //4
                                if (CAPS) begin
                                    ascii <= 16'h24;
                                end else begin
                                    ascii <= 16'h34;
                                end
                            8'h2E: //5
                                if (CAPS) begin
                                    ascii <= 16'h25;
                                end else begin
                                    ascii <= 16'h35;
                                end
                            8'h36: //6
                                if (CAPS) begin
                                    ascii <= 16'h36;
                                end else begin
                                    ascii <= 16'h36;
                                end
                            8'h3D: //7
                                if (CAPS) begin
                                    ascii <= 16'h26;
                                end else begin
                                    ascii <= 16'h37;
                                end
                            8'h3E: //8
                                if (CAPS) begin
                                    ascii <= 16'h2A;
                                end else begin
                                    ascii <= 16'h38;
                                end
                            8'h46: //9
                                if (CAPS) begin
                                    ascii <= 16'h28;
                                end else begin
                                    ascii <= 16'h39;
                                end
                            8'h4E: //-
                                if (CAPS) begin
                                    ascii <= 16'h5F;
                                end else begin
                                    ascii <= 16'h2D;
                                end
                            8'h55: //=
                                if (CAPS) begin
                                    ascii <= 16'h2B;
                                end else begin
                                    ascii <= 16'h3D;
                                end
                            8'h5D: //\
                                if (CAPS) begin
                                    ascii <= 16'h7C;
                                end else begin
                                    ascii <= 16'h5C;
                                end
                            8'h54: //[
                                if (CAPS) begin
                                    ascii <= 16'h7B;
                                end else begin
                                    ascii <= 16'h5C;
                                end
                            8'h5B: //]
                                if (CAPS) begin
                                    ascii <= 16'h7D;
                                end else begin
                                    ascii <= 16'h5D;
                                end
                            8'h4C: //;
                                if (CAPS) begin
                                    ascii <= 16'h3A;
                                end else begin
                                    ascii <= 16'h3B;
                                end
                            8'h52: //'
                                if (CAPS) begin
                                    ascii <= 16'h22;
                                end else begin
                                    ascii <= 16'h27;
                                end
                            8'h41: //,
                                if (CAPS) begin
                                    ascii <= 16'h3C;
                                end else begin
                                    ascii <= 16'h2C;
                                end
                            8'h49: //.
                                if (CAPS) begin
                                    ascii <= 16'h3E;
                                end else begin
                                    ascii <= 16'h2E;
                                end
                            8'h4A: ///
                                if (CAPS) begin
                                    ascii <= 16'h3F;
                                end else begin
                                    ascii <= 16'h2F;
                                end
                            8'h66: // BACKSPACE
                                begin
                                    ascii <= 16'h08;
                                end
                            8'h29: // SPACE
                                begin
                                    ascii <= 16'h20;
                                end
                            8'h5A: // ENTER
                                begin
                                    ascii <= 16'h0A;
                                end
                            8'h58: // CAPS
                                begin
                                    ascii <= 16'h0000;
                                    CAPS  <= 1-CAPS;
                                end
                            8'hE0: ///
                                begin
                                    kstate <= K_HOLD;
                                end
                            default:
                                begin
                                    kstate <= K_BEGIN;
                                    ascii <= 16'h0000;
                                end
                            endcase
                        K_HOLD:
                            case (code)
                            8'hF0:
                                kstate <= K_STOP;
                            8'h75: // UP
                                begin
                                    ascii <= `KEYBOARD_UP;
                                end
                            8'h72: // DOWN
                                begin
                                    ascii <= `KEYBOARD_DOWN;
                                end
                            8'h6B: // LEFT
                                begin
                                    ascii <= `KEYBOARD_LEFT;
                                end
                            8'h74: // RIGHT
                                begin
                                    ascii <= `KEYBOARD_RIGHT;
                                end
                            default:
                                begin
                                    kstate <= K_BEGIN;
                                    ascii <= 16'h0000;
                                end
                            endcase
                        K_STOP:
                            begin
                                ascii  <= 16'h0000;
                                kstate <= K_BEGIN;
                            end
                        endcase
                    end else begin
                        state <= DELAY;
                    end
                end
            FINISH:
                begin
                    state <= DELAY;
                    scancode <= code;
						  outascii <= ascii;
                    dataready <= 1;
                end
            DROP:
                begin
                    state <= DELAY;
                    scancode <= code;
                end
            endcase
    end
end

always @(posedge rdn, negedge rst)  begin
    if (rst == 0)
        p1 <= 0;
    else begin
        p1 <= ~p1;
    end
end
endmodule