LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
------------------------------------
ENTITY traffic_light IS
	PORT(			clk			      : 	IN		STD_LOGIC;
					rst			      : 	IN		STD_LOGIC;
					ena			      : 	IN		STD_LOGIC;
					syn_clr		      :	IN		STD_LOGIC;
					LedR			  	   : 	OUT 	STD_LOGIC;
					LedY					:	OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0);
					LedG					:  OUT 	STD_LOGIC);
END ENTITY;
-------------------------------------
ARCHITECTURE rtl OF traffic_light IS

	SIGNAL stby																: STD_LOGIC;
	SIGNAL TimerR, TimerRY, TimerG, TimerY							: STD_LOGIC;
	SIGNAL ena_timerR, ena_timerRY, ena_timerG, ena_timerY 	: STD_LOGIC; 
	SIGNAL syn_clr_timerR, syn_clr_timerRY, syn_clr_timerG, syn_clr_timerY	: STD_LOGIC;
	SIGNAL counterR, counterRY, counterG, counterY 				: STD_LOGIC_VECTOR (27 DOWNTO 0);
	
		SIGNAL q0	: STD_LOGIC;
		SIGNAL q1	: STD_LOGIC;
		SIGNAL q2	: STD_LOGIC;
		SIGNAL q3	: STD_LOGIC;
		SIGNAL q4	: STD_LOGIC;
	
		SIGNAL d0	: STD_LOGIC;
		SIGNAL d1	: STD_LOGIC;
		SIGNAL d2	: STD_LOGIC;
		SIGNAL d3	: STD_LOGIC;
		SIGNAL d4	: STD_LOGIC;	
BEGIN
	 ---------------Logic for the Finite State Machine-------------------
	 stby <= NOT ena ;
	 d0 <= stby AND q0;
    d1 <= (q0 AND NOT (stby)) OR (q1 AND NOT(TimerR)) OR (q4 AND TimerY);
    d2 <= (q2 AND NOT(TimerRY)) OR (q1 AND TimerR);
    d3 <= (q3 AND NOT(TimerG)) OR (q2 AND TimerRY);
    d4 <= (q4 AND NOT(TimerY)) OR (q3 AND TimerG);
	--------------Process to light up LEDS verifying the states q-----------
	PROCESS(q0,q1,q2,q3,q4)
	BEGIN
		IF(q0='1') THEN
			-----Initial state, Yellow ---------
			LedR <= '1';
			LedY <="00";
			LedG <='1';
		ELSIF(q1='1') THEN
		-------Red Light-----------
			IF(TimerR = '0') THEN
					LedR <='0';
					LedY<="11";
					LedG<='1';
    				ena_timerR <= '1';
					ena_timerRY <= '0';
					ena_timerG <= '0';
					ena_timerY <= '0';
					syn_clr_timerR <= '0';
					syn_clr_timerRY<='1';
					syn_clr_timerG<='1';
					syn_clr_timerY<='1';
			ELSE 
				ena_timerR <= '0';
				ena_timerRY <= '1';
				ena_timerG <= '0';
				ena_timerY <= '0';
				syn_clr_timerR<='1';
				syn_clr_timerRY<='1';
				syn_clr_timerG<='1';
				syn_clr_timerY<='1';
			 END IF;
		-------Red and Yellow Light------
		ELSIF(q2='1') THEN
			IF(TimerRY = '0') THEN
				   LedR <='0';
					LedY<="00";
					LedG<='1';
					ena_timerR <= '0';
					ena_timerRY <= '1';
					ena_timerG <= '0';
					ena_timerY <= '0';
					syn_clr_timerR <= '1';
					syn_clr_timerRY<='0';
					syn_clr_timerG<='1';
					syn_clr_timerY<='1';
			ELSE 
				ena_timerR <= '0';
				ena_timerRY <= '0';
				ena_timerG <= '1';
				ena_timerY <= '0';
				syn_clr_timerR<='1';
				syn_clr_timerRY<='1';
				syn_clr_timerG<='1';
				syn_clr_timerY<='1';
			 END IF;
		---------Green Light------------
		ELSIF(q3='1') THEN
			IF(TimerG = '0') THEN
					LedR <='1';
					LedY<="11";
					LedG<='0';
			   	ena_timerR <= '0';
					ena_timerRY <= '0';
					ena_timerG <= '1';
					ena_timerY <= '0';
					syn_clr_timerR <= '1';
					syn_clr_timerRY<='1';
					syn_clr_timerG<='0';
					syn_clr_timerY<='1';
			ELSE 
				ena_timerR <= '0';
				ena_timerRY <= '0';
				ena_timerG <= '0';
				ena_timerY <= '1';
				syn_clr_timerR<='1';
				syn_clr_timerRY<='1';
				syn_clr_timerG<='1';
				syn_clr_timerY<='1';
				END IF;
		------------Yellow light------------
		ELSIF(q4='1') THEN
			IF(TimerY='0') THEN
					LedR <='1';
					LedY<="00";
					LedG<='1';
					ena_timerR <= '0';
					ena_timerRY <= '0';
					ena_timerG <= '0';
					ena_timerY <= '1';
					syn_clr_timerR <= '1';
					syn_clr_timerRY<='1';
					syn_clr_timerG<='1';
					syn_clr_timerY<='0';
			ELSE
				ena_timerR <= '1';
				ena_timerRY <= '0';
				ena_timerG <= '0';
				ena_timerY <= '0';
				syn_clr_timerR<='1';
				syn_clr_timerRY<='1';
				syn_clr_timerG<='1';
				syn_clr_timerY<='1';
			END IF;
		END IF;
	END PROCESS;
	-------------Timers for each color---------------
		Red_Timer:	ENTITY WORK.cronometro_red
		GENERIC MAP( N => 28)
		PORT MAP		(  clk		=> clk,
							rst		=> rst,	
							ena		=> ena_timerR,	
							syn_clr	=> syn_clr_timerR,	
							max_tick	=> TimerR,
							counter	=> counterR );
								
		Yellow_Timer:	ENTITY WORK.cronometro_y
		 GENERIC MAP( N => 28)
		 PORT MAP		(  clk		=> clk,
								rst		=> rst,	
								ena		=> ena_timerY,	
								syn_clr	=> syn_clr_timerY,	
								max_tick	=> TimerY,
								counter	=> counterY );
	
		Green_Timer:	ENTITY WORK.cronometro_g
		 GENERIC MAP( N => 28)
		 PORT MAP		(  clk		=> clk,
							   rst		=> rst,	
								ena		=> ena_timerG,	
								syn_clr	=> syn_clr_timerG,	
								max_tick	=> TimerG,
								counter	=> counterG );
		
		YellowRed_Timer:	ENTITY WORK.cronometro_ry
			GENERIC MAP( N => 28)
			PORT MAP		(  clk		=> clk,
								rst		=> rst,	
								ena		=> ena_timerRY,	
								syn_clr	=> syn_clr_timerRY,	
								max_tick	=> TimerRY,
								counter	=> counterRY );
		      ---------------Entity for each state--------------
      state0: ENTITY WORK.my_dff
		PORT MAP (clk => clk,
					 rst => rst,
				    ena  => ena,
				    prn => '0',
				    d => d0,
			       q => q0);
		state1: ENTITY WORK.my_dff
		PORT MAP (clk => clk,
					 rst => rst,
				    ena  => ena,
				    prn => '1',
				    d => d1,
			       q => q1);			
		state2: ENTITY WORK.my_dff
		PORT MAP (clk => clk,
					 rst => rst,
				    ena  => ena,
				    prn => '1',
				    d => d2,
			       q => q2);
		state3: ENTITY WORK.my_dff
		PORT MAP (clk => clk,
					 rst => rst,
				    ena  => ena,
				    prn => '1',
				    d => d3,
			       q => q3);			
		state4: ENTITY WORK.my_dff
		PORT MAP (clk => clk,
					 rst => rst,
				    ena  => ena,
				    prn => '1',
				    d => d4,
			       q => q4);	
END ARCHITECTURE;		