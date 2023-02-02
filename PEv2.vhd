Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PEv2 is
	port( clock, reset, hard_reset, ld, ld_w : in std_logic;
			a_in, w_in : in signed(7 downto 0);
			part_in : in signed(15 downto 0);
			a_out : out signed(7 downto 0);
			partial_sum : out signed(15 downto 0));
end entity;

architecture behaviour of PEv2 is

	signal A_reg, W_reg : signed(7 downto 0);
	signal MAC, Y_reg : signed(15 downto 0);
	signal MACIntermediate : integer;

begin

	process(clock, reset, hard_reset)
	
	begin
	
		if(hard_reset = '1') then
		
			A_reg <= (others => '0');
			Y_reg <= (others => '0');
			W_reg <= (others => '0');
			
		elsif(reset = '1') then
		
			A_reg <= (others => '0');
			Y_reg <= (others => '0');
			
		elsif(rising_edge(clock)) then
		
			if(ld = '1') then
				A_reg <= a_in;
				Y_reg <= MAC;
			end if;
			
			if(ld_w = '1') then
				W_reg <= w_in;
			end if;
			
		end if;
		
	end process;
	
	
	MACIntermediate <= to_integer(a_in) * to_integer(W_reg) + to_integer(part_in);
	
	-- Rounding
	MAC <= to_signed(MACIntermediate, 16) when MACIntermediate < 65536 else (others => '1');
	
	-- Outputs
	partial_sum <= Y_reg;
	
	a_out <= A_reg;
	

end architecture;