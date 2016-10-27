----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:18:45 10/25/2016 
-- Design Name: 
-- Module Name:    RAM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           wrn, rdn: out std_logic;
           sw : in  STD_LOGIC_VECTOR (15 downto 0);
           ram1_en,ram1_oe,ram1_we : out  STD_LOGIC;
           ram2_en,ram2_oe,ram2_we : out  STD_LOGIC;
           ram1_addr, ram2_addr : out  STD_LOGIC_VECTOR (17 downto 0);
           ram1_data, ram2_data : inout  STD_LOGIC_VECTOR (15 downto 0);
           led : out  STD_LOGIC_VECTOR (15 downto 0);

           digit1, digit2: out std_logic_vector(6 downto 0));
end RAM;

architecture Behavioral of RAM is
    --×´Ì¬
    type BState is (bstate0, bstate1, bstate2, bstate3, bstate4, bstate5, bstate6, bstate7, bstate8);
    type SState is (sstate0, sstate1, sstate2);

    --¼ÇÂ¼µ±Ç°×´Ì¬
    signal nows: BState := bstate0;
    signal wrstate: SState := sstate0;

    signal addr: std_logic_vector(17 downto 0) := (others => '0');
    signal data: std_logic_vector(15 downto 0) := (others => '0');
    shared variable count: integer range 0 to 10;
begin
    led(15 downto 8) <= addr(7 downto 0);
    led(7 downto 0) <= data(7 downto 0);

    process (nows,wrstate)
    begin 
        case nows is
            when bstate0  =>  digit1 <= "0111111";
            when bstate1  =>  digit1 <= "0000110";
            when bstate2  =>  digit1 <= "1011011";
            when bstate3  =>  digit1 <= "1001111";
            when bstate4  =>  digit1 <= "1100110";
            when bstate5  =>  digit1 <= "1101101";
            when bstate6  =>  digit1 <= "1111101";
            when bstate7  =>  digit1 <= "0000111";
            when bstate8  =>  digit1 <= "1111111";
            when others   =>  digit1 <= "0000000";
        end case;
        case wrstate is
            when sstate0  =>  digit2 <= "0111111";
            when sstate1  =>  digit2 <= "0000110";
            when sstate2  =>  digit2 <= "1011011";
            when others   =>  digit2 <= "0000000";
        end case;
    end process;

    --×´Ì¬»ú
    process (clk, rst)
    begin
        --reset
        if rst = '0' then
            ram1_en <= '1';
            ram1_oe <= '1';
            ram1_we <= '1';
            ram2_en <= '1';
            ram2_oe <= '1';
            ram2_we <= '1';
            wrn     <= '1';
            rdn     <= '1';
            nows    <= bstate0;
            wrstate <= sstate0;
            count   := 0;
            addr    <= (others => '0');
            data    <= (others => '0');
        --clk
        elsif clk'event and clk = '0' then
            --  ram1
            case nows is
                when bstate0 => 
                    ram1_en                 <= '0';
                    ram2_en                 <= '1';
                    addr(15 downto 0)       <= sw;
                    ram1_addr(15 downto 0)  <= sw;
                    nows                    <= bstate1;
                when bstate1 => 
                    data        <= sw;
                    ram1_data   <= sw;
                    nows        <= bstate2;
                when bstate2 => 
                    case wrstate is
                        when sstate0 =>
                            ram1_we     <= '0';
                            wrstate     <= sstate1;    
                        when sstate1 =>
                            ram1_we <= '1';
                            data    <= data + 1;
                            addr    <= addr + 1;
                            wrstate <= sstate2;
                        when sstate2 =>
                            ram1_addr <= addr;
                            ram1_data <= data;
                            count     := count+1;
                            wrstate    <= sstate0;
                            if count = 10 then
                                count   := 0;
                                nows <= bstate3;
                            end if;
                    end case;
                when bstate3 => 
                    ram1_oe   <= '0';
                    addr      <= addr - 1;
                    ram1_addr <= addr - 1;
                    ram1_data <= (others => 'Z');
                    nows      <= bstate4;
                when bstate4 =>
                    case wrstate is
                        when sstate0 =>
                            data    <= ram1_data;
                            wrstate <= sstate1;
                        when sstate1 =>
                            ram1_data <= (others => 'Z');
                            addr      <= addr - 1;
                            ram1_addr <= addr - 1;
                            count     := count + 1;
                            wrstate   <= sstate0;
                            if count = 10 then
                                count   := 0;
                                ram1_oe <= '1';
                                nows    <= bstate5;
                            end if;
                        when others => null;
                    end case;
            --  ram2
                when bstate5 => 
                    ram1_en    <= '1';
                    ram2_en    <= '0';
                    addr       <= addr + 1;
                    ram2_addr  <= addr + 1;
                    ram2_data  <= data;
                    nows       <= bstate6;
                when bstate6 => 
                    case wrstate is
                        when sstate0 =>
                            ram2_we     <= '0';
                            wrstate     <= sstate1;
                        when sstate1 =>
                            ram2_we <= '1';
                            data    <= data + 1;
                            addr    <= addr + 1;
                            wrstate <= sstate2;
                        when sstate2 =>
                            ram2_addr <= addr;
                            ram2_data <= data;
                            count     := count+1;
                            wrstate    <= sstate0;
                            if count = 10 then
                                count   := 0;
                                nows <= bstate7;
                            end if;
                    end case;
                when bstate7 => 
                    ram2_oe   <= '0';
                    addr      <= addr - 1;
                    ram2_addr <= addr - 1;
                    ram2_data <= (others => 'Z');
                    nows      <= bstate8;
                when bstate8 =>
                    case wrstate is
                        when sstate0 =>
                            data    <= ram2_data;
                            wrstate <= sstate1;
                        when sstate1 =>
                            ram2_data <= (others => 'Z');
                            addr      <= addr - 1;
                            ram2_addr <= addr - 1;
                            count     := count + 1;
                            wrstate   <= sstate0;
                            if count = 10 then
                                count   := 0;
                                ram1_oe <= '1';
                                nows    <= bstate0;
                            end if;
                        when others => null;
                    end case;
                when others => null;
            end case;
        end if;
    end process;
end Behavioral;

