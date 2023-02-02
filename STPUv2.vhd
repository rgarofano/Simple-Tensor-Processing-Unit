Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.systolic_package.all;

entity STPUv2 is
	port( clock, reset, hard_reset, setup, GO, stall : in std_logic;
			weights, a_in : in std_logic_vector(23 downto 0);
			y0, y1, y2 : out bus_width;
			done : out std_logic );
end entity;


ARCHITECTURE rtl of STPUv2 IS


---------- COMPONENTS ----------


COMPONENT ISA_decode IS

PORT(clock : in std_logic;
	  mode : in std_logic_vector(3 downto 0);
	  num_feature,num_weight : out INTEGER);
	  
END COMPONENT;

COMPONENT MMUv2 IS

PORT (
		clock, reset, hard_reset, ld, ld_w, stall : in std_logic;
		a0, a1, a2, w2, w1, w0 : in signed(7 downto 0);
		y0, y1, y2 : out signed(15 downto 0));
		
END COMPONENT;

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

COMPONENT AUv2 IS

port( clock, reset, hard_reset, stall, start : in std_logic;
			y_in0, y_in1, y_in2 : in signed(15 downto 0);
			done : out std_logic := '0';
			row0, row1, row2 : out bus_width );

END COMPONENT;


---------- SIGNALS ----------

signal setup_state, state1,state2,state3,state4,state5,state6 : INTEGER := 0;
signal ready,mode1_done,mode2_done,mode3_done,mode4_done,mode5_done,mode6_done : std_logic := '0'; 
signal stallDelayed : std_logic;

-- ==================== Instruction Memory

signal mode : std_logic_vector(3 downto 0);
signal num_f,num_w : INTEGER;

-- ==================== RAM

signal addressW : std_logic_vector(2 downto 0);
signal addressU0, addressU1, addressU2 : std_logic_vector(3 downto 0);
signal WREN, WWEN, U0REN, U1REN, U2REN, U0WEN, U1WEN, U2WEN : std_logic;
signal a0S, a1S, a2S : std_logic_vector(7 downto 0);
signal WRAM_out : std_logic_vector(23 downto 0);
	
-- ==================== MMU
	
signal ldS, ld_wS1, ld_wS2 : std_logic := '0';
signal y0S, y1S, y2S : signed(15 downto 0);
signal y0S1, y1S1, y2S1 : signed(15 downto 0);
signal y0S2, y1S2, y2S2 : signed(15 downto 0);
	
-- ==================== AU
	
signal startAU : std_logic := '0';
signal resetAU, resetAUOut : std_logic := '0';

BEGIN


---------- PORT MAPPING ----------


-- ==================== Instruction Memory

ISA : ISA_decode PORT MAP(clock=>clock,mode=>mode,num_feature=>num_f,num_weight=>num_w);

-- ==================== RAM

WEIGHT_RAM : WRAMv2 PORT MAP(aclr=>hard_reset,address=>addressW,clock=>clock,data=>weights,rden=>WREN,wren=>WWEN,q=>WRAM_out);
URAM0		  : URAMv2 PORT MAP(aclr=>hard_reset,address=>addressU0,clock=>clock,data=>a_in(23 downto 16),rden=>U0REN,wren=>U0WEN,q=>a0S);
URAM1		  : URAMv2 PORT MAP(aclr=>hard_reset,address=>addressU1,clock=>clock,data=>a_in(15 downto 8),rden=>U1REN,wren=>U1WEN,q=>a1S);
URAM2		  : URAMv2 PORT MAP(aclr=>hard_reset,address=>addressU2,clock=>clock,data=>a_in(7 downto 0),rden=>U2REN,wren=>U2WEN,q=>a2S);

-- ==================== MMU

Obj_MMU1 : MMUv2
		PORT MAP(clock=>clock, reset=>reset, hard_reset=>hard_reset, ld=>ldS,
					ld_w=>ld_wS1, stall=>stallDelayed, a0=>signed(a0S), a1=>signed(a1S),
					a2=>signed(a2S), w0=>signed(WRAM_out(23 downto 16)),
					w1=>signed(WRAM_out(15 downto 8)), w2=>signed(WRAM_out(7 downto 0)),
					y0=>y0S1, y1=>y1S1, y2=>y2S1 );
					
Obj_MMU2 : MMUv2
		PORT MAP(clock=>clock, reset=>reset, hard_reset=>hard_reset, ld=>ldS,
					ld_w=>ld_wS2, stall=>stallDelayed, a0=>signed(a0S), a1=>signed(a1S),
					a2=>signed(a2S), w0=>signed(WRAM_out(23 downto 16)),
					w1=>signed(WRAM_out(15 downto 8)), w2=>signed(WRAM_out(7 downto 0)),
					y0=>y0S2, y1=>y1S2, y2=>y2S2 );
					
-- ==================== AU

Obj_AU : AUv2
		port map(clock=>clock, reset=>resetAUOut, hard_reset=>hard_reset, stall=>stallDelayed,
					start=>startAU, y_in0=>y0S, y_in1=>y1S, y_in2=>y2S, done=>done,
					row0=>y0, row1=>y1, row2=>y2 );
					
					
---------- MAIN PROCESS ----------

PROCESS(clock) IS
BEGIN

-- ==================== STALL

	IF(rising_edge(clock)) THEN stallDelayed <= stall; END IF;

	

-- ==================== SETUP

	IF (setup = '1' or mode6_done = '1') THEN
	
		ready <= '0';
		
		mode1_done <= '0';
		mode2_done <= '0';
		mode3_done <= '0';
		mode4_done <= '0';
		mode5_done <= '0';
		mode6_done <= '0';
	
	END IF;
	
	if (hard_reset = '1') then
		
		setup_state <= 0;
		
		ready <= '0';
		
		mode1_done <= '0';
		mode2_done <= '0';
		mode3_done <= '0';
		mode4_done <= '0';
		mode5_done <= '0';
		mode6_done <= '0';
		
	ELSIF (ready = '0') THEN
		
		IF (setup_state = 10) then
			
			IF (GO = '1') THEN
			
				ready <= '1';
				
			END IF;
		
		ELSIF(rising_edge(clock) and (setup_state /= 0 or setup = '1')) THEN
		
			setup_state <= setup_state + 1;
		
		END IF;
		
	END IF;	

-- ==================== MODE 1 -> 1 feature, 1 weight

	IF (ready = '1' and num_f = 1 and num_w = 1) THEN
	
		if (state1 = 17) then
		
			mode1_done <= '1';
			state1 <= 0;
		
		elsif(rising_edge(clock) and stall = '0' and mode1_done = '0') then
		
			state1 <= state1 + 1;
		
		END IF;
	
	END IF;

-- ==================== MODE 2 -> 2 feature, 1 weight

	IF (num_f = 2 and num_w = 1) THEN
	
		IF (state2 = 16) THEN
		
			mode2_done <= '1';
			state2 <= 0;
		
		ELSIF (rising_edge(clock) and stall = '0' and mode2_done = '0') THEN
		
			state2 <= state2 + 1;
		
		END IF;
		
	END IF;

-- ==================== MODE 3 -> 3 feature, 1 weight

	IF (num_f = 3 and num_w = 1) THEN
	
		IF (state3 = 19) THEN
		
			mode3_done <= '1';
			state3 <= 0;
		
		ELSIF (rising_edge(clock) and stall = '0' and mode3_done = '0') THEN
		
			state3 <= state3 + 1;
		
		END IF;
		
	END IF;

-- ==================== MODE 4 -> 1 feature, 2 weight

	if  (num_f = 1 and num_w = 2) then
		
		if (state4 = 16) then
		
			mode4_done <= '1';
			state4 <= 0;
			
		elsif (rising_edge(clock) and stall = '0' and mode4_done = '0') then
		
			state4 <= state4 + 1;
			
		end if;
	
	end if;
	
-- ==================== MODE 5 -> 2 feature, 2 weight

	if  (num_f = 2 and num_w = 2) then
		
		if (state5 = 22) then
		
			mode5_done <= '1';
			state5 <= 0;
			
		elsif (rising_edge(clock) and stall = '0' and mode5_done = '0') then
		
			state5 <= state5 + 1;
			
		end if;
	
	end if;
	
-- ==================== MODE 6 -> 3 feature, 2 weight

	if  (num_f = 3 and num_w = 2) then
		
		if (state6 = 29) then
		
			mode6_done <= '1';
			state6 <= 0;
			
		elsif (rising_edge(clock) and stall = '0' and mode6_done = '0') then
		
			state6 <= state6 + 1;
			
		end if;
	
	end if;
	
end process;


---------- COMBINATIONAL LOGIC ----------


mode  <=  "1010" when (mode6_done = '1')
     else "1111" when (mode5_done = '1')
	  else "1110" when (mode4_done = '1')
	  else "1101" when (mode3_done = '1')
	  else "1100" when (mode2_done = '1')
	  else "1011" when (mode1_done = '1')
	  else "1010";


addressW  <=  "001" when (setup_state = 0 or state1 = 1)
			else "010" when (setup_state = 1 or state1 = 2)
			else "011" when (setup_state = 2 or state1 = 3)
			else "100" when (setup_state = 3 or 				state3 = 1)
			else "101" when (setup_state = 4 or 				state3 = 2)
			else "110" when (setup_state = 5 or 				state3 = 3)
			else "000";

WWEN  <=  '1' when (setup_state >= 0 and setup_state <= 5)
	  else '0';

WREN <= '1' when (stall = '0' and (state1 >= 1 and state1 <= 3)) -- Mode 1
	else '1' when (stall = '0' and (state3 >= 1 and state3 <= 3)) -- Mode 3
	else '0';

	  
addressU0  <=  "0001" when (setup_state = 0 or state1 = 5 or state2 = 1 or state3 = 1 or state4 = 1 or state4 = 4 or state5 = 1 or state5 = 7  or state6 = 1 or state6 = 10)
          else "0010" when (setup_state = 1 or state1 = 6 or state2 = 2 or state3 = 2 or state4 = 2 or state4 = 5 or state5 = 2 or state5 = 8  or state6 = 2 or state6 = 11)
			 else "0011" when (setup_state = 2 or state1 = 7 or state2 = 3 or state3 = 3 or state4 = 3 or state4 = 6 or state5 = 3 or state5 = 9  or state6 = 3 or state6 = 12)
			 else "0100" when (setup_state = 3 or 					 state2 = 4 or state3 = 4 or 										state5 = 4 or state5 = 10 or state6 = 4 or state6 = 13)
			 else "0101" when (setup_state = 4 or 					 state2 = 5 or state3 = 5 or 										state5 = 5 or state5 = 11 or state6 = 5 or state6 = 14)
			 else "0110" when (setup_state = 5 or 					 state2 = 6 or state3 = 6 or 										state5 = 6 or state5 = 12 or state6 = 6 or state6 = 15)
			 else "0111" when (setup_state = 6 or 					 					state3 = 7 or																		 	  state6 = 7 or state6 = 16)
			 else "1000" when (setup_state = 7 or 					 					state3 = 8 or 																			  state6 = 8 or state6 = 17)
			 else "1001" when (setup_state = 8 or 					 					state3 = 9 or 																			  state6 = 9 or state6 = 18)
			 else "0000";

addressU1  <=  "0001" when (setup_state = 0 or state1 = 6 or state2 = 2 or state3 = 2 or state4 = 2 or state4 = 5 or state5 = 2 or state5 = 8  or state6 = 2 or state6 = 11)
          else "0010" when (setup_state = 1 or state1 = 7 or state2 = 3 or state3 = 3 or state4 = 3 or state4 = 6 or state5 = 3 or state5 = 9  or state6 = 3 or state6 = 12)
			 else "0011" when (setup_state = 2 or state1 = 8 or state2 = 4 or state3 = 4 or state4 = 4 or state4 = 7 or state5 = 4 or state5 = 10 or state6 = 4 or state6 = 13)
			 else "0100" when (setup_state = 3 or 					 state2 = 5 or state3 = 5 or 										state5 = 5 or state5 = 11 or state6 = 5 or state6 = 14)
			 else "0101" when (setup_state = 4 or 					 state2 = 6 or state3 = 6 or 										state5 = 6 or state5 = 12 or state6 = 6 or state6 = 15)
			 else "0110" when (setup_state = 5 or 					 state2 = 7 or state3 = 7 or 										state5 = 7 or state5 = 13 or state6 = 7 or state6 = 16)
			 else "0111" when (setup_state = 6 or 					 					state3 = 8 or 																			  state6 = 8 or state6 = 17)
			 else "1000" when (setup_state = 7 or 					 					state3 = 9 or 																		  	  state6 = 9 or state6 = 18)
			 else "1001" when (setup_state = 8 or 					 					state3 = 10 or 																		  state6 = 10 or state6 = 19)
			 else "0000";

addressU2  <=  "0001" when (setup_state = 0 or state1 = 7 or state2 = 3 or state3 = 3 or state4 = 3 or state4 = 6 or state5 = 3 or state5 = 9  or state6 = 3 or state6 = 12)
          else "0010" when (setup_state = 1 or state1 = 8 or state2 = 4 or state3 = 4 or state4 = 4 or state4 = 7 or state5 = 4 or state5 = 10 or state6 = 4 or state6 = 13)
			 else "0011" when (setup_state = 2 or state1 = 9 or state2 = 5 or state3 = 5 or state4 = 5 or state4 = 8 or state5 = 5 or state5 = 11 or state6 = 5 or state6 = 14)
			 else "0100" when (setup_state = 3 or 					 state2 = 6 or state3 = 6 or 										state5 = 6 or state5 = 12 or state6 = 6 or state6 = 15)
			 else "0101" when (setup_state = 4 or 					 state2 = 7 or state3 = 7 or 										state5 = 7 or state5 = 13 or state6 = 7 or state6 = 16)
			 else "0110" when (setup_state = 5 or 					 state2 = 8 or state3 = 8 or 										state5 = 8 or state5 = 14 or state6 = 8 or state6 = 17)
			 else "0111" when (setup_state = 6 or 					 					state3 = 9  or 																		  state6 = 9 or state6 = 18)
			 else "1000" when (setup_state = 7 or 					 					state3 = 10 or 																		  state6 = 10 or state6 = 19)
			 else "1001" when (setup_state = 8 or 					 					state3 = 11 or 																		  state6 = 11 or state6 = 20)
			 else "0000";

U0WEN  <=  '1' when (stall = '0' and (setup_state >= 0 and setup_state <= 8)) -- Setup
		else '0';
		
U0REN  <=  '1' when (stall = '0' and (state1 >= 5 and state1 <= 8))  -- Mode 1
		else '1' when (stall = '0' and (state2 >= 1 and state2 <= 6))  -- Mode 2
		else '1' when (stall = '0' and (state3 >= 1 and state3 <= 9))  -- Mode 3
		else '1' when (stall = '0' and (state4 >= 1 and state4 <= 6))  -- Mode 4
		else '1' when (stall = '0' and (state5 >= 1 and state5 <= 12)) -- Mode 5
		else '1' when (stall = '0' and (state6 >= 1 and state6 <= 18)) -- Mode 6
	   else '0';
		
U1WEN  <=  '1' when (stall = '0' and (setup_state >= 0 and setup_state <= 8)) -- Setup
		else '0';

U1REN  <=  '1' when (stall = '0' and (state1 >= 5 and state1 <= 9))  -- Mode 1
		else '1' when (stall = '0' and (state2 >= 1 and state2 <= 7))  -- Mode 2
		else '1' when (stall = '0' and (state3 >= 1 and state3 <= 10)) -- Mode 3
		else '1' when (stall = '0' and (state4 >= 1 and state4 <= 7))  -- Mode 4
		else '1' when (stall = '0' and (state5 >= 1 and state5 <= 13)) -- Mode 5
		else '1' when (stall = '0' and (state6 >= 1 and state6 <= 19)) -- Mode 6
      else '0';
		
U2WEN  <=  '1' when (setup_state >= 0 and setup_state <= 8) -- Setup
		else '0';

U2REN  <= '1' when (stall = '0' and (state1 >= 5 and state1 <= 10)) -- Mode 1
	  else '1' when (stall = '0' and (state2 >= 1 and state2 <= 8))  -- Mode 2
	  else '1' when (stall = '0' and (state3 >= 1 and state3 <= 11)) -- Mode 3
	  else '1' when (stall = '0' and (state4 >= 1 and state4 <= 8))  -- Mode 4
	  else '1' when (stall  ='0' and (state5 >= 1 and state5 <= 14)) -- Mode 5
	  else '1' when (stall = '0' and (state6 >= 1 and state6 <= 20)) -- Mode 6
	  else '0';

	 
ld_wS1 <=  '1' when (state1 >= 3 and state1 <= 5) -- Mode 1
	   else '0';
		
ld_wS2 <=  '1' when (state3 >= 3 and state3 <= 5) -- Mode 3
		else '0';
	
ldS <=  '1' when (state1 >= 7) -- Mode 1
	else '1' when (state2 >= 3) -- Mode 2
	else '1' when (state3 >= 3) -- Mode 3
	else '1' when (state4 >= 3) -- Mode 4
	else '1' when (state5 >= 3) -- Mode 5
	else '1' when (state6 >= 3) -- Mode 6
   else '0';
	
startAU <= '1' when (state1 = 11) -- Mode 1
		else '1' when (state2 = 7)  -- Mode 2
		else '1' when (state3 = 7)  -- Mode 3
		else '1' when (state4 = 7)  -- Mode 4
		else '1' when (state5 = 7)  -- Mode 5
		else '1' when (state6 = 7)  -- Mode 6
      else '0';


-- ========== Select which MMU the AU reads

y0S <=  y0S2 when (state4 >= 10 and state4 <= 12) -- Mode 4
	else y0S2 when (state5 >= 13 and state5 <= 18) -- Mode 5
	else y0S2 when (state6 >= 16 and state5 <= 24) -- Mode 6
	else y0S1;
	
y1S <=  y1S2 when (state4 >= 11 and state4 <= 13) -- Mode 4
	else y1S2 when (state5 >= 14 and state5 <= 19) -- Mode 5
	else y1S2 when (state6 >= 17 and state6 <= 25) -- Mode 6
	else y1S1;
	
y2S <=  y2S2 when (state4 >= 12 and state4 <= 14) -- Mode 4
	else y2S2 when (state5 >= 15 and state5 <= 20) -- Mode 5
	else y2S2 when (state6 >= 18 and state6 <= 26) -- Mode 6
	else y2S1;


resetAU <= '1' when (state1 = 1 or state2 = 1 or state3 = 1 or state4 = 1 or state5 = 1 or state6 = 1 or mode6_done = '1') else '0';
resetAUOut <= resetAU or reset;


END rtl;