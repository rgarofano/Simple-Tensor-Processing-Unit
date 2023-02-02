library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.systolic_package.all;

ENTITY tb_STPUv2 IS
--empty
END tb_STPUv2;

ARCHITECTURE test of tb_STPUv2 IS

COMPONENT STPUv2 IS

PORT( clock, reset, hard_reset, setup, GO, stall : in std_logic;
			weights, a_in : in std_logic_vector(23 downto 0);
			y0, y1, y2 : out bus_width;
			done : out std_logic );

END COMPONENT;

constant PERIOD : time := 5 ns;
signal clk : std_logic := '1';
signal rst,hrst,setup,GO,stall,done : std_logic;
signal w,a : std_logic_vector(23 downto 0);
signal y0,y1,y2 : bus_width; 

BEGIN

DUT : STPUv2
PORT MAP(clk,rst,hrst,setup,GO,stall,w,a,y0,y1,y2,done);

clk <= not clk after PERIOD;

PROCESS IS
BEGIN

rst <= '0';
hrst <= '0';
setup <= '1';
GO <= '0';
stall <= '0';
w <= "000000010000001000000011"; -- 1, 2, 3
a <= "000000010000001000000011";
-------------1-------1-------1
wait for 10 ns;

setup <= '0';
w <= "000001000000010100000110"; -- 4, 5, 6
a <= "000001000000010100000110";
-------------1-------1-------1
wait for 10 ns;

w <= "000001110000100000001001"; -- 7, 8, 9
a <= "000001110000100000001001";
-------------1-------1-------1
wait for 10 ns;

w <= "000000100000001100000100"; -- 2, 3, 4
a <= "000000100000001100000100"; -- 2, 3, 4
-------------1-------1-------1
wait for 10 ns;

w <= "000001010000011000000111"; -- 5, 6, 7
a <= "000001010000011000000111";
-------------1-------1-------1
wait for 10 ns;

a <= "000010000000100100001010"; -- 8, 9, 10
w <= "000010000000100100001010";
-------------1-------1-------1
wait for 10 ns;

a <= "000000110000001100000011";
-------------1-------1-------1
wait for 10 ns;

a <= "000000110000001100000011";
-------------1-------1-------1
wait for 10 ns;

a <= "000000110000001100000011";
-------------1-------1-------1
wait for 10 ns;

GO <= '1';

wait for 100 ns;

GO <= '0';

wait for 100 ns;

stall <= '0';

wait for 50 ns;

stall <= '0';

wait for 300 ns;

stall <= '0';

wait for 50 ns;

stall <= '0';

WAIT;
END PROCESS;

END test;