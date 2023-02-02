library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_URAMv2 IS
--empty
END tb_URAMv2;

ARCHITECTURE test of tb_URAMv2 IS

COMPONENT URAMv2 IS

	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		address		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	
END COMPONENT;

constant PERIOD : time := 5 ns;
signal clk : std_logic := '0';
signal rst,rd,wr : std_logic := '0';
signal add : std_logic_vector(3 downto 0);
signal D,Q : std_logic_vector(7 downto 0);

BEGIN

DUT : URAMv2
PORT MAP(rst,add,clk,D,rd,wr,Q);

clk <= not clk after PERIOD;

PROCESS IS
BEGIN

--Load Data Into Unique Addresses

add <= "0001";
wr <= '1';
D <= "00000001";
wait for 6 ns;

add <= "0010";
wr <= '1';
D <= "00000010";
wait for 10 ns;

add <= "0011";
wr <= '1';
D <= "00000011";
wait for 10 ns;

add <= "0100";
wr <= '1';
D <= "00000100";
wait for 10 ns;

add <= "0101";
wr <= '1';
D <= "00000101";
wait for 10 ns;

add <= "0110";
wr <= '1';
D <= "00000110";
wait for 10 ns;

add <= "0111";
wr <= '1';
D <= "00000111";
wait for 10 ns;

add <= "1000";
wr <= '1';
D <= "00001000";
wait for 10 ns;

add <= "1001";
wr <= '1';
D <= "00001001";
wait for 10 ns;

--Read Loaded Data

add <= "0001";
wr <= '0';
rd <= '1';
wait for 10 ns;

add <= "0010";
wait for 10 ns;

add <= "0011";
wait for 10 ns;

add <= "0100";
wait for 10 ns;

add <= "0101";
wait for 10 ns;

add <= "0110";
wait for 10 ns;

add <= "0111";
wait for 10 ns;

add <= "1000";
wait for 10 ns;

add <= "1001";
wait for 10 ns;

WAIT;
END PROCESS;

END test;