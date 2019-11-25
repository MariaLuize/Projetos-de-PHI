-----------------------------------------------
-- CLOCK DIVIDER
--
-- For a 50MHz I_clk:
--          
--      <I_clk in Hz> / <expected baud> =  I_clk_baud_count
--          50000000  /  9600           =  5208
--          50000000  /  115200         =  434
--
------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY UART_CLK_DIV is
	GENERIC(
				CNT0 : integer := 5208; -- BOUND RATE DE 9600
				CNT1 : integer := 434	-- BOUND RATE DE 115200)
	);
	PORT ( clk       : in STD_LOGIC;
	       rst       : in STD_LOGIC;	       
	       baud_rate : in STD_LOGIC;
	       uart_clk  : out STD_LOGIC);
END UART_CLK_DIV;

ARCHITECTURE UART_CLK_DIV_ARCH OF UART_CLK_DIV IS
	signal CNT    : integer;
	signal count  : integer  := 1;
	signal tmp    : STD_LOGIC := '0';
	
BEGIN

PROCESS (clk, rst)
	BEGIN
		if(baud_rate = '0') then
			CNT <= CNT0/2;
		else
			CNT <= CNT1/2;
		end if;

		if(rst ='1') then
			count <= 1;
			tmp <= '0';
		elsif(RISING_EDGE(clk)) then
			count <= count + 1;
			if(count >= CNT) then
				tmp <= NOT tmp;
				count <= 1;
			end if;
		end if;
END PROCESS;

uart_clk <= tmp;
	
END UART_CLK_DIV_ARCH;
