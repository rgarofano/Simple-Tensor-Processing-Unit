library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_MMUv2 IS
--empty
END tb_MMUv2;

ARCHITECTURE test of tb_MMUv2 IS

COMPONENT MMUv2 IS

PORT (
		clock : std_logic;
		reset, hard_reset, ld, ld_w, stall : std_logic;
		a0, a1, a2, w2, w1, w0 : in signed(7 downto 0);
		y0, y1, y2 : out signed(15 downto 0));

END COMPONENT;

constant PERIOD : time := 5 ns;
signal clock, reset, hard_reset, ld, ld_w, stall : std_logic;
signal a0, a1, a2, w2, w1, w0 : signed(7 downto 0);
signal y0, y1, y2 : signed(15 downto 0);

BEGIN

DUT : MMUv2
PORT MAP(clock => clock,reset => reset,hard_reset => hard_reset,ld => ld,ld_w => ld_w,
			stall => stall,a0=>a0,a1=>a1,a2=>a2,w2=>w2,w1=>w1,w0=>w0,y0=>y0,y1=>y1,y2=>y2);

clock <= '0' when reset = '1' else not clock after PERIOD;

PROCESS IS
BEGIN

reset <= '1';
hard_reset <= '1';
ld <= '0';
ld_w <= '0';
stall <= '0';
a0 <= (others=>'0');
a1 <= (others=>'0');
a2 <= (others=>'0');
w2 <= (others=>'0');
w1 <= (others=>'0');
w0 <= (others=>'0');
wait for 14 ns;

reset <= '0';
hard_reset <= '0';
ld <= '0';
ld_w <= '1';
stall <= '0';
a0 <= (others=>'0');
a1 <= (others=>'0');
a2 <= (others=>'0');
w2 <= "00000001";
w1 <= "00000001";
w0 <= "00000001";
wait for 14 ns;

reset <= '0';
hard_reset <= '0';
ld <= '0';
ld_w <= '1';
stall <= '0';
a0 <= (others=>'0');
a1 <= (others=>'0');
a2 <= (others=>'0');
w2 <= "00000001";
w1 <= "00000001";
w0 <= "00000001";
wait for 10 ns;

reset <= '0';
hard_reset <= '0';
ld <= '0';
ld_w <= '1';
stall <= '0';
a0 <= "00000000";
a1 <= "00000000";
a2 <= "00000001";
w2 <= "00000001";
w1 <= "00000001";
w0 <= "00000001";
wait for 10 ns;

reset <= '0';
hard_reset <= '0';
ld <= '1';
ld_w <= '0';
stall <= '0';
a0 <= "00000001";
a1 <= "00000000";
a2 <= "00000000";
w2 <= "00000001";
w1 <= "00000001";
w0 <= "00000001";
wait for 16 ns;

reset <= '0';
hard_reset <= '0';
ld <= '1';
ld_w <= '0';
stall <= '0';
a0 <= "00000001";
a1 <= "00000001";
a2 <= "00000000";
w2 <= "00000001";
w1 <= "00000001";
w0 <= "00000001";
wait for 14 ns;

reset <= '0';
hard_reset <= '0';
ld <= '1';
ld_w <= '0';
stall <= '0';
a0 <= "00000001";
a1 <= "00000001";
a2 <= "00000001";
w2 <= "00000001";
w1 <= "00000001";
w0 <= "00000001";
wait for 16 ns;

reset <= '0';
hard_reset <= '0';
ld <= '1';
ld_w <= '0';
stall <= '0';
a0 <= "00000000";
a1 <= "00000001";
a2 <= "00000001";
w2 <= "00000001";
w1 <= "00000001";
w0 <= "00000001";
wait for 14 ns;

reset <= '0';
hard_reset <= '0';
ld <= '1';
ld_w <= '0';
stall <= '0';
a0 <= "00000000";
a1 <= "00000000";
a2 <= "00000011";
w2 <= "00000001";
w1 <= "00000001";
w0 <= "00000001";
wait for 8 ns;

reset <= '0';
hard_reset <= '0';
ld <= '1';
ld_w <= '0';
stall <= '0';
a0 <= "00000000";
a1 <= "00000000";
a2 <= "00000011";
w2 <= "00000001";
w1 <= "00000001";
w0 <= "00000001";
wait for 14 ns;

wait;

END PROCESS;
END test;