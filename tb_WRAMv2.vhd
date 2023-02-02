library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_WRAMv2 IS
--empty
END ENTITY;

ARCHITECTURE test of tb_WRAMv2 IS

COMPONENT WRAMv2 IS

PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		address		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);

END COMPONENT;

constant PERIOD : time := 5 ns;
signal clk : std_logic := '0';
signal rst,rd,wr : std_logic := '0';
signal add : std_logic_vector(2 downto 0);
signal D,Q : std_logic_vector(23 downto 0);

BEGIN

DUT : WRAMv2
PORT MAP(rst,add,clk,D,rd,wr,Q);

clk <= not clk after PERIOD;

PROCESS IS
BEGIN

--Load Data Into Unique Addresses

add <= "001";
wr <= '1';
D <= "000000010000000100000001";
wait for 6 ns;

add <= "010";
wr <= '1';
D <= "000000100000001000000010";
wait for 10 ns;

add <= "011";
wr <= '1';
D <= "000000110000001100000011";
wait for 10 ns;

add <= "100";
wr <= '1';
D <= "000001000000010000000100";
wait for 10 ns;

add <= "101";
wr <= '1';
D <= "000001010000010100000101";
wait for 10 ns;

add <= "110";
wr <= '1';
D <= "000001100000011000000110";
wait for 10 ns;

--Read Loaded Data

add <= "001";
wr <= '0';
rd <= '1';
wait for 10 ns;

add <= "010";
wait for 10 ns;

add <= "011";
wait for 10 ns;

add <= "100";
wait for 10 ns;

add <= "101";
wait for 10 ns;

add <= "110";
wait for 10 ns;

WAIT;
END PROCESS;

END test;