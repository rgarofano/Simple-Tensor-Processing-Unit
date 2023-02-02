Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.systolic_package.all;

entity AUv2 is
	port( clock, reset, hard_reset, stall, start : in std_logic;
			y_in0, y_in1, y_in2 : in signed(15 downto 0);
			done : out std_logic := '0';
			row0, row1, row2 : out bus_width );

end entity;

architecture behaviour of AUv2 is

	signal state : integer := 0;
	signal y11, y12, y13,
			 y21, y22, y23,
			 y31, y32, y33 : signed(15 downto 0) := (others => '0');
	signal row0Reg, row0Intermediate, row1Reg, row1Intermediate, row2Reg : bus_width;

begin
	
	row0 <= row0Reg;
	row1 <= row1Reg;
	row2 <= row2Reg;

	process(clock, reset, hard_reset)
	
	begin
	
		if(reset = '1' or hard_reset = '1') then
			
			y11 <= (others => '0');
			y12 <= (others => '0');
			y13 <= (others => '0');
			y21 <= (others => '0');
			y22 <= (others => '0');
			y23 <= (others => '0');
			y31 <= (others => '0');
			y32 <= (others => '0');
			y33 <= (others => '0');
			
			row0Reg(0) <= (others => '0');
			row0Reg(1) <= (others => '0');
			row0Reg(2) <= (others => '0');
			row1Reg(0) <= (others => '0');
			row1Reg(1) <= (others => '0');
			row1Reg(2) <= (others => '0');
			row2Reg(0) <= (others => '0');
			row2Reg(1) <= (others => '0');
			row2Reg(2) <= (others => '0');
			
			row0Intermediate(0) <= (others => '0');
			row0Intermediate(1) <= (others => '0');
			row0Intermediate(2) <= (others => '0');
			row1Intermediate(0) <= (others => '0');
			row1Intermediate(1) <= (others => '0');
			row1Intermediate(2) <= (others => '0');
			
			state <= 0;
			
		elsif(rising_edge(clock) and stall = '0') then
		
			-- FSM
			if(start = '0' and state = 0) then
				
				state <= 0;
				
			elsif(state = 5) then
				
				state <= 3; -- continuous output
				
			else
			
				state <= state + 1;
				
			end if;
			
			
			y13 <= y_in0; -- row0
			y12 <= y13;
			y11 <= y12;
			
			y23 <= y_in1; -- row1
			y22 <= y23;
			y21 <= y22;
			
			y33 <= y_in2; -- row2
			y32 <= y33;
			y31 <= y32;
			
			if(state = 3) then
				
				if(to_integer(y11) > 0) then
					row0Intermediate(0) <= y11;
				else
					row0Intermediate(0) <= (others=>'0');
					
				end if;
				
				if(to_integer(y12) > 0) then
					row0Intermediate(1) <= y12;
				else
					row0Intermediate(1) <= (others=>'0');
				
				end if;
				
				if(to_integer(y13) > 0) then
					row0Intermediate(2) <= y13;
				else
					row0Intermediate(2) <= (others=>'0');
				
				end if;
					
			end if;
		
			if(state = 4) then
				
				if(to_integer(y21) > 0) then
					row1Intermediate(0) <= y21;
				else
					row1Intermediate(0) <= (others=>'0');
				
				end if;
				
				if(to_integer(y22) > 0) then
					row1Intermediate(1) <= y22;
				else
					row1Intermediate(1) <= (others=>'0');
				
				end if;
				
				if(to_integer(y23) > 0) then
					row1Intermediate(2) <= y23;
				else
					row1Intermediate(2) <= (others=>'0');
					
				end if;
				
			end if;
		
			if(state = 5) then
				
				if(to_integer(y31) > 0) then
					row2Reg(0) <= y31;
				else
					row2Reg(0) <= (others=>'0');
				
				end if;
				
				if(to_integer(y32) > 0) then
					row2Reg(1) <= y32;
				else
					row2Reg(1) <= (others=>'0');
				
				end if;
				
				if(to_integer(y33) > 0) then
					row2Reg(2) <= y33;
				else
					row2Reg(2) <= (others=>'0');
					
				end if;
				
				row1Reg <= row1Intermediate;
				row0Reg <= row0Intermediate;
				done <= '1';
				
			else
				done <= '0';
			
			end if;
			
		end if;	
			
	end process;

end architecture;