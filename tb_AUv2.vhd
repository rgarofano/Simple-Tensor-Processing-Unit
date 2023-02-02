Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.systolic_package.all;

entity tb_AUv2 is
end entity;

architecture testbench of tb_AUv2 is

	component AUv2 is
		port( clock, reset, hard_reset, stall, start : in std_logic;
			y_in0, y_in1, y_in2 : in signed(15 downto 0);
			done : out std_logic := '0';
			row0, row1, row2 : out bus_width );
	
	end component;
	
	signal clockS : std_logic := '1';
	signal resetS, hard_resetS, stallS, startS : std_logic := '0';
	signal y0, y1, y2 : signed(15 downto 0) := (others=>'0');
	signal doneS : std_logic;
	signal row0S, row1S, row2S : bus_width;
	
	constant period : time := 5 ns;
	
begin

	clockS <= not clockS after period;

	DUT : AUv2
		port map(clock => clockS, reset => resetS, hard_reset => hard_resetS, stall => stallS, start => startS,
					y_in0 => y0, y_in1 => y1, y_in2 => y2, done => doneS, row0 => row0S, row1 => row1S, row2 => row2S);
	
	
	process is
	
	begin
	
		resetS <= '1';
		
		wait for 5 ns;
		
		resetS <= '0';
				
		wait for 5 ns;
		
		startS <= '1';
		
		y0 <= "0000000000000001";
		y1 <= "0000000011111111";
		y2 <= "0000000001111111";
		
		wait for 10 ns;
				
		y0 <= "0000000000000010";
		y1 <= "0000000000000100";
		y2 <= "1000000011111111";
		
		startS <= '0';
		
		wait for 10 ns;
				
		y0 <= "0000000000000011";
		y1 <= "0000000000000101";
		y2 <= "1000011100000000";
		
		wait for 10 ns;
		
		y0 <= "0000010000000000";
		y1 <= "0000011000000000";
		y2 <= "0000100000000000";
		
		wait for 10 ns;
		
		y0 <= "0000010100000000";
		y1 <= "0000011100000000";
		y2 <= "0000100100000000";
		
		wait for 10 ns;
		
		y0 <= "0000011000000000";
		y1 <= "0000100000000000";
		y2 <= "0000101000000000";
		
		wait for 10 ns;
		
		y0 <= "0000011100000000";
		y1 <= "0000100100000000";
		y2 <= "0000101100000000";
		
		wait for 10 ns;
		
		y0 <= "0000100000000000";
		y1 <= "0000101000000000";
		y2 <= "0000110000000000";
		
		wait for 10 ns;
		
		y0 <= "0000100100000000";
		y1 <= "0000101100000000";
		y2 <= "0000110100000000";
		
		wait for 10 ns;
		
		y0 <= "0000101000000000";
		y1 <= "0000110000000000";
		y2 <= "0000111000000000";
		
		wait for 10 ns;
		
		y0 <= "0000101100000000";
		y1 <= "0000110100000000";
		y2 <= "0000110000000011";
		
		wait;
	
	end process;

end architecture;