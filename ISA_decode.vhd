library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ISA_decode IS

PORT(clock : in std_logic;
	  mode : in std_logic_vector(3 downto 0);
	  num_feature,num_weight : out INTEGER);
	  
END ISA_decode;

ARCHITECTURE behaviour of ISA_decode IS

COMPONENT ISA IS

PORT
	(
		address		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);

END COMPONENT;

signal ISA_OUT : std_logic_vector(3 downto 0);

BEGIN

Instruction_Gen : ISA
PORT MAP(address=>mode,clock=>clock,q=>ISA_OUT);

num_feature <= to_integer(unsigned(ISA_OUT(3 downto 2)));
num_weight <= to_integer(unsigned(ISA_OUT(1 downto 0)));

END behaviour;