library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_ISA_decode IS
--empty
END tb_ISA_decode;

ARCHITECTURE test of tb_ISA_decode IS

COMPONENT ISA_decode IS

PORT(clock : in std_logic;
	  mode : in std_logic_vector(3 downto 0);
	  num_feature,num_weight : out INTEGER);

END COMPONENT;

constant PERIOD : time := 5 ns;
signal clk : std_logic := '0';
signal mode : std_logic_vector(3 downto 0);
signal nf,nw : INTEGER;

BEGIN

DUT : ISA_decode
PORT MAP(clk,mode,nf,nw);

clk <= not clk after PERIOD;

PROCESS IS
BEGIN

mode <= "1010";
wait for 7 ns;

mode <= "1011";
wait for 7 ns;

mode <= "1100";
wait for 7 ns;

mode <= "1101";
wait for 7 ns;

mode <= "1110";
wait for 7 ns;

mode <= "1111";
wait for 7 ns;

WAIT;

END PROCESS;

END test;