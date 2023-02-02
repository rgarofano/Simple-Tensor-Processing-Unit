library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY MMUv2 IS

PORT (
		clock, reset, hard_reset, ld, ld_w, stall : in std_logic;
		a0, a1, a2, w2, w1, w0 : in signed(7 downto 0);
		y0, y1, y2 : out signed(15 downto 0));
		
END MMUv2;

ARCHITECTURE RTL of MMUv2 IS

-- Components

COMPONENT PEv2 IS

Port (   clock, reset, hard_reset, ld, ld_w : in std_logic;
			a_in, w_in : in signed(7 downto 0);
			part_in : in signed(15 downto 0);
			a_out : out signed(7 downto 0);
			partial_sum : out signed(15 downto 0));

END COMPONENT;

-- Signals and States

type mmu_mode is (init,compute);

type init_state is (idle, load_col0, load_col1, load_col2);

signal STATE : init_state := idle;
signal MODE  : mmu_mode := init;

signal a11,a21,a31 : signed(7 downto 0) := (others=>'0');
signal ao11,ao12,ao21,ao22,ao31,ao32 : signed(7 downto 0);
signal ao13,ao23,ao33 : signed(7 downto 0);
signal w11,w12,w13,w21,w22,w23,w31,w32,w33 : signed(7 downto 0) := (others=>'0');
signal sumo11,sumo12,sumo13,sumo21,sumo22,sumo23 : signed(15 downto 0) := (others=>'0');
signal ld_wCol0, ld_wCol1, ld_wCol2 : std_logic; -- Fix 1
signal ld_w_reg : std_logic; -- Fix 2

BEGIN

PE11: PEv2 PORT MAP(clock=>clock,reset=>reset,hard_reset=>hard_reset,ld=>ld, ld_w=>ld_w_reg, a_in=>a11,  w_in=>w11, part_in=>(others=>'0'),partial_sum=>sumo11,a_out=>ao11);
PE12: PEv2 PORT MAP(clock=>clock,reset=>reset,hard_reset=>hard_reset,ld=>ld, ld_w=>ld_w_reg, a_in=>ao11, w_in=>w12, part_in=>(others=>'0'),partial_sum=>sumo12,a_out=>ao12);
PE13: PEv2 PORT MAP(clock=>clock,reset=>reset,hard_reset=>hard_reset,ld=>ld, ld_w=>ld_w_reg, a_in=>ao12, w_in=>w13, part_in=>(others=>'0'),partial_sum=>sumo13,a_out=>ao13);
PE21: PEv2 PORT MAP(clock=>clock,reset=>reset,hard_reset=>hard_reset,ld=>ld, ld_w=>ld_w_reg, a_in=>a21,  w_in=>w21, part_in=>sumo11,partial_sum=>sumo21,a_out=>ao21);
PE22: PEv2 PORT MAP(clock=>clock,reset=>reset,hard_reset=>hard_reset,ld=>ld, ld_w=>ld_w_reg, a_in=>ao21, w_in=>w22, part_in=>sumo12,partial_sum=>sumo22,a_out=>ao22);
PE23: PEv2 PORT MAP(clock=>clock,reset=>reset,hard_reset=>hard_reset,ld=>ld, ld_w=>ld_w_reg, a_in=>ao22, w_in=>w23, part_in=>sumo13,partial_sum=>sumo23,a_out=>ao23);
PE31: PEv2 PORT MAP(clock=>clock,reset=>reset,hard_reset=>hard_reset,ld=>ld, ld_w=>ld_w_reg, a_in=>a31,  w_in=>w31, part_in=>sumo21,partial_sum=>y0,a_out=>ao31);
PE32: PEv2 PORT MAP(clock=>clock,reset=>reset,hard_reset=>hard_reset,ld=>ld, ld_w=>ld_w_reg, a_in=>ao31, w_in=>w32, part_in=>sumo22,partial_sum=>y1,a_out=>ao32);
PE33: PEv2 PORT MAP(clock=>clock,reset=>reset,hard_reset=>hard_reset,ld=>ld, ld_w=>ld_w_reg, a_in=>ao32, w_in=>w33, part_in=>sumo23,partial_sum=>y2,a_out=>ao33);


PROCESS(clock) IS
BEGIN

IF (rising_edge(clock) and stall = '0') THEN

	ld_w_reg <= ld_w; -- Fix 2

	case MODE is
	
		when init =>
			
			case STATE is
				
				when idle =>
					
					IF ld_w = '1' THEN
						
						w11 <= w0;
						w21 <= w1;
						w31 <= w2;
						STATE <= load_col0;
						
					ELSE
						
						STATE <= idle;
						
					END IF;
					
				when load_col0 =>
					
					IF ld_w = '1' THEN
						
						w12 <= w0;
						w22 <= w1;
						w32 <= w2;
						STATE <= load_col1;
						
					ELSE
						
						STATE <= load_col0;
						
					END IF;
					
				when load_col1 =>
					
					IF ld_w = '1' THEN
						
						w13 <= w0;
						w23 <= w1;
						w33 <= w2;
						STATE <= load_col2;
						
					ELSE
						
						STATE <= load_col1;
						
					END IF;
					
				when load_col2 =>
					
					IF ld_w = '1' THEN
						
						STATE <= idle;
						
					ELSE
						
						MODE <= compute;
						STATE <= idle;
						
					END IF;
					
			end case;
			
		when compute =>
			
			IF stall = '1' THEN
				
				MODE <= compute;
				
			ELSE
				
				a11 <= a0;
				a21 <= a1;
				a31 <= a2;
				
			END IF;
			
	end case;
	
END IF;
END PROCESS;
	
END RTL;