library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VGA_Controller is
	port (
	--VGA Side
		hs,vs	: out std_logic;		--行同步、场同步信号
		oRed	: out std_logic_vector (2 downto 0);
		oGreen	: out std_logic_vector (2 downto 0);
		oBlue	: out std_logic_vector (2 downto 0);
	--RAM side
		R : in  std_logic_vector (2 downto 0);
		G : in  std_logic_vector (2 downto 0);
		B : in  std_logic_vector (2 downto 0);
		addr	: out std_logic_vector (18 downto 0);
	--Control Signals
		reset	: in  std_logic;
		CLK_in	: in  std_logic			--50M时钟输入
	);		
end entity VGA_Controller;

architecture behave of VGA_Controller is

--VGA
	signal CLK,CLK_2	: std_logic;
	signal rt,gt,bt	: std_logic_vector (2 downto 0);
	signal hst,vst	: std_logic;
	signal x		: std_logic_vector (9 downto 0);		--X坐标
	signal y		: std_logic_vector (8 downto 0);		--Y坐标

begin

CLK<=CLK_2;

 -----------------------------------------------------------------------
	process (CLK_in)
	begin
		if CLK_in'event and CLK_in = '1' then	--对50M输入信号二分频
			CLK_2 <= not CLK_2;
		end if;
	end process;

 -----------------------------------------------------------------------
	process (CLK, reset)	--行区间像素数（含消隐区）
	begin
		if reset = '0' then
			x <= (others => '0');
		elsif CLK'event and CLK = '1' then
			if x = 799 then
				x <= (others => '0');
			else
				x <= x + 1;
			end if;
		end if;
	end process;

  -----------------------------------------------------------------------
	 process (CLK, reset)	--场区间行数（含消隐区）
	 begin
	  	if reset = '0' then
	   		y <= (others => '0');
	  	elsif CLK'event and CLK = '1' then
	   		if x = 799 then
	    		if y = 524 then
	     			y <= (others => '0');
	    		else
	     			y <= y + 1;
	    		end if;
	   		end if;
	  	end if;
	 end process;
 
  -----------------------------------------------------------------------
	 process (CLK, reset)	--行同步信号产生（同步宽度96，前沿16）
	 begin
		  if reset = '0' then
		   hst <= '1';
		  elsif CLK'event and CLK = '1' then
		   	if x >= 656 and x < 752 then
		    	hst <= '0';
		   	else
		    	hst <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process (CLK, reset)	--场同步信号产生（同步宽度2，前沿10）
	 begin
	  	if reset = '0' then
	   		vst <= '1';
	  	elsif CLK'event and CLK = '1' then
	   		if y >= 490 and y< 492 then
	    		vst <= '0';
	   		else
	    		vst <= '1';
	   		end if;
	  	end if;
	 end process;
 -----------------------------------------------------------------------
	 process (CLK, reset)	--行同步信号输出
	 begin
	  	if reset = '0' then
	   		hs <= '0';
	  	elsif CLK'event and CLK = '1' then
	   		hs <=  hst;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process (CLK, reset)	--场同步信号输出
	 begin
	  	if reset = '0' then
	   		vs <= '0';
	  	elsif CLK'event and CLK='1' then
	   		vs <=  vst;
	  	end if;
	 end process;

------------------------------------------------------------------------
	process (CLK, reset) -- XY坐标定位控制
	begin	  	
		if reset = '0' then
			rt		<=	(others => '0');
			gt		<=	(others => '0');
			bt		<=	(others => '0');
			addr	<=	(others => '0');
	  	elsif CLK'event and CLK='1' then
			addr	<=	x&y;
			rt		<=	R;
			gt		<=	G;
			bt		<=	B;
	  	end if;
	end process;


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
	process (hst, vst, rt, gt, bt)	--色彩输出
	begin
		if hst = '1' and vst = '1' then
			oRed	<= rt;
			oGreen	<= gt;
			oBlue	<= bt;
		else
			oRed	<= (others => '0');
			oGreen	<= (others => '0');
			oBlue	<= (others => '0');
		end if;
	end process;

end behave;