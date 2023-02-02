library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_ISA IS
--empty
END tb_ISA;

ARCHITECTURE test of tb_ISA IS

COMPONENT ISA IS

PORT
	(
		address		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);

END COMPONENT;

constant PERIOD : time := 5 ns;
signal clk : std_logic := '1';
signal add,q : std_logic_vector(3 downto 0);

BEGIN

DUT : ISA
PORT MAP(address=>add,clock=>clk,q=>q);

clk <= not clk after PERIOD;

PROCESS IS
BEGIN

add <= "1010";
wait for 7 ns;

add <= "1011";
wait for 7 ns;

add <= "1100";
wait for 7 ns;

add <= "1101";
wait for 7 ns;

add <= "1110";
wait for 7 ns;

add <= "1111";
wait for 7 ns;

WAIT;

END PROCESS;

END test;