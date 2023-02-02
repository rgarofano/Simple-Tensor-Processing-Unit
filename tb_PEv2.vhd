Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.systolic_package.all;

entity tb_PEv2 is
end entity;

architecture testbench of tb_PEv2 is

	component PEv2 is
		port( clock, reset, hard_reset, ld, ld_w : in std_logic;
			a_in, w_in : in signed(7 downto 0);
			part_in : in signed(15 downto 0);
			a_out : out signed(7 downto 0);
			partial_sum : out signed(15 downto 0));
	end component;
	
	signal reset, hard_reset, ld, ld_w : std_logic := '0';
	signal a_in, w_in, a_out : signed(7 downto 0);
	signal part_in, partial_sum : signed(15 downto 0);
	
	signal clock : std_logic := '1';
	constant period : time := 5 ns;
	
begin

	clock <= not clock after period;
	
	DUT : PEv2
		port map(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld, ld_w => ld_w,
					a_in => a_in, w_in => w_in, part_in => part_in, partial_sum => partial_sum, a_out => a_out);
					
					
	process is
	
	begin
	
		a_in <= "00000000";
		w_in <= "00000000";
		part_in <= "0000000000000000";
		
		wait for 5 ns;
		
		w_in <= "00001000";
		ld_w <= '1';		
		
		wait for 10 ns;
		
		ld_w <= '0';
		a_in <= "00000011";
		part_in <= "0000000000000000";
		ld <= '1';
		
		wait for 10 ns;
		
		ld <= '0';
		
		reset <= '0';
		
		wait for 10 ns;
		
		reset <= '0';
		
		a_in <= "10001000";
		part_in <= "0000000000000001";
		ld <= '1';
		
		wait for 20 ns;
		
		hard_reset <= '1';
		
		
		wait;
		
	end process;

end architecture;