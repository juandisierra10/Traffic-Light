LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
----------------------------------
ENTITY my_dff IS
	PORT (	clk  :	IN		STD_LOGIC;
				rst  :   IN    STD_LOGIC;
				ena  :   IN    STD_LOGIC;
				prn  :   IN    STD_LOGIC;
				d    :   IN    STD_LOGIC;
				q    :   OUT   STD_LOGIC);
END my_dff;
--------------------------------------
ARCHITECTURE rtl OF my_dff IS
BEGIN

	dff: PROCESS(clk, rst,d)
	BEGIN
		IF(rst = '1') THEN
			IF (prn='0') THEN
				q<='1';
			ELSE 
			q <= '0';
		END IF;
		ELSIF(rising_edge(clk)) THEN
			IF(ena = '1') THEN
				q <= d;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;