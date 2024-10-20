-------------------------------------------------------------------------
-- Jason Di Giovanni
-- Owen Jewell
-- Iowa State University
-------------------------------------------------------------------------

-- tb_ALU.vhd

-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- updated ALU
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ALU is
  generic(gCLK_HPER   : time := 50 ns);
end tb_ALU;

architecture mixed of tb_ALU is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;
  constant N : integer :=32;


component alu is
  port(i_A          : in std_logic_vector(31 downto 0);             -- First 32 bit data input
       i_B          : in std_logic_vector(31 downto 0);             -- Second 32 bit data input
       i_BrrlShamt  : in std_logic_vector(4 downto 0);              -- Barrel shifter shift amount (0 to 31)
       i_AluCntrl   : in std_logic_vector(3 downto 0);  
       o_Zero       : out std_logic;                                -- Output used for to take either program counter + 4 or branch immediate
       o_C          : out std_logic;                                -- Carry output
       o_O          : out std_logic;                                -- Overflow output
       o_AluOut     : out std_logic_vector(31 downto 0));           -- ALU out
end component;

signal CLK, reset : std_logic := '0';

signal s_C, s_O, s_Zero	: std_logic;
signal s_A, s_B, s_AluOut : std_logic_vector(31 downto 0);
signal s_AluCntrl : std_logic_vector(3 downto 0);
signal s_BrrlShamt : std_logic_vector(4 downto 0);

begin
DUT0: ALU
	port map(i_A		=> s_A,
		 i_B		=> s_B,
		 i_BrrlShamt	=> s_BrrlShamt,
		 i_AluCntrl	=> s_AluCntrl,	
		 o_Zero   	=> s_Zero,
		 o_C     	=> s_c,
                 o_O     	=> s_O,
		 o_AluOut	=> s_AluOut);

P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;

  -- This process resets the sequential components of the design.
  -- It is held to be 1 across both the negative and positive edges of the clock
  -- so it works regardless of whether the design uses synchronous (pos or neg edge)
  -- or asynchronous resets.
  P_RST: process
  begin
  	reset <= '0';   
    wait for gCLK_HPER/2;
	reset <= '1';
    wait for gCLK_HPER*2;
	reset <= '0';
	wait;
  end process;  
  
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

------------------------------------------------------------------------------------------------------------------
                                     --Nor test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 1: 00000000 NOR 00000000 = FFFFFFFF
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "00000000000000000000000000000000";     -- 0
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0000";                                 -- Alu Cntrl = 0000 for nor
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 2: 00000000 NOR FFFFFFFF = 00000000
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0000";                                 -- Alu Cntrl = 0000 for nor
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 3: AAAA5555 NOR 00000000 = 5555AAAA
-------------------------------------------------------------------------------------------------
    s_A           <= "10101010101010100101010101010101";     -- AAAA5555
    s_B           <= "00000000000000000000000000000000";     -- 00000000
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0000";                                 -- Alu Cntrl = 0000 for nor
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

------------------------------------------------------------------------------------------------------------------
                                     --Or test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 4: 00000000 OR 00000000 = 00000000
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "00000000000000000000000000000000";     -- 0
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0001";                                 -- Alu Cntrl = 0001 for or
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 5: FFFFFFFF OR FFFFFFFF = FFFFFFFF
-------------------------------------------------------------------------------------------------
    s_A           <= "11111111111111111111111111111111";     -- MAX
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0001";                                 -- Alu Cntrl = 0001 for or
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 6: AAAA5555 OR 55555555 = FFFF5555
-------------------------------------------------------------------------------------------------
    s_A    <= "10101010101010100101010101010101";           -- AAAAAAAA
    s_B    <= "01010101010101010101010101010101";           -- 55555555
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0001";                                 -- Alu Cntrl = 0001 for or
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;


------------------------------------------------------------------------------------------------------------------
                                     --Add test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 7: 00000000 + 00000000 = 00000000
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "00000000000000000000000000000000";     -- 0
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0010";                                 -- Alu Cntrl = 0010 for add
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 8: FFFFFFFF + FFFFFFFF = FFFFFFFE
-------------------------------------------------------------------------------------------------
    s_A           <= "11111111111111111111111111111111";     -- MAX
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0010";                                 -- Alu Cntrl = 0010 for add
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 9: 00000005 + 00000002 = 00000007
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000101";     -- 5
    s_B           <= "00000000000000000000000000000010";     -- 2
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0010";                                 -- Alu Cntrl = 0010 for add
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

------------------------------------------------------------------------------------------------------------------
                                     --Subtract test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 10: 00000000 - 00000000 = 00000000
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "00000000000000000000000000000000";     -- 0
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0011";                                 -- Alu Cntrl = 0011 for sub
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 11: 00000000 - 00000003 = FFFFFFFD
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- MAX
    s_B           <= "00000000000000000000000000000011";     -- MAX
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0011";                                 -- Alu Cntrl = 0011 for sub
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 12: AAAAAAAA - 55555555 = 55555555
-------------------------------------------------------------------------------------------------
    s_A    <= "10101010101010101010101010101010";           -- AAAAAAAA
    s_B    <= "01010101010101010101010101010101";           -- 55555555
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0011";                                 -- Alu Cntrl = 0011 for sub
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

------------------------------------------------------------------------------------------------------------------
                                     --XOR test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 13: 00000000 XOR 00000000 = 00000000
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "00000000000000000000000000000000";     -- 0
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0100";                                 -- Alu Cntrl = 0100 for xor
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 14: FFFFFFFF XOR FFFFFFFF = 00000000
-------------------------------------------------------------------------------------------------
    s_A           <= "11111111111111111111111111111111";     -- MAX
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0100";                                 -- Alu Cntrl = 0100 for xor
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 15: AAAA5555 XOR 55555555 = FFFF0000
-------------------------------------------------------------------------------------------------
    s_A    <= "10101010101010100101010101010101";           -- AAAAAAAA
    s_B    <= "01010101010101010101010101010101";           -- 55555555
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0101";                                 -- Alu Cntrl = 0101 for xor
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

------------------------------------------------------------------------------------------------------------------
                                     --Slt test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 16: 00000000 < 00000000 = 00000000
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "00000000000000000000000000000000";     -- 0
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0110";                                 -- Alu Cntrl = 0110 for slt
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 17: 00000000 < 00000003 = 1
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- MAX
    s_B           <= "00000000000000000000000000000011";     -- MAX
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0110";                                 -- Alu Cntrl = 0110 for slt
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
------------------------------------------------------------------------------------------------------------------
    -- Test case 18: FFFFFFFD < 00000000 = 1
-------------------------------------------------------------------------------------------------
    s_A    <= "11111111111111111111111111111101";           -- FFFFFFFD
    s_B    <= "00000000000000000000000000000000";           -- 00000000
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "0111";                                 -- Alu Cntrl = 0111 for slt
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

	    
------------------------------------------------------------------------------------------------------------------
                                     --Sra test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 19: FFFFFFFF >> 4 = 0FFFFFFF
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00100";                                -- Shamt = 4
    s_AluCntrl    <= "1000";                                 -- Alu Cntrl = 1000 for sra
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
    -- Test case 20: A5A5A5A5 >> 8 = 00A5A5A5
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- MAX
    s_B           <= "10100101101001011010010110100101";     -- MAX
    s_BrrlShamt   <= "01000";                                -- Shamt = 8
    s_AluCntrl    <= "1000";                                 -- Alu Cntrl = 1000 for sra
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
                                     --Srl test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 21: FFFFFFFF >> 4 = FFFFFFFF
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00100";                                -- Shamt = 4
    s_AluCntrl    <= "1001";                                 -- Alu Cntrl = 1001 for srl
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
    -- Test case 22: 5A5A5A5A >> 8 = 005A5A5A
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "01011010010110100101101001011010";     -- 5A5A5A5A
    s_BrrlShamt   <= "01000";                                -- Shamt = 8
    s_AluCntrl    <= "1001";                                 -- Alu Cntrl = 1001 for srl
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
                                     --Sll test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 23: FFFFFFFF << 4 = FFFFFFF0
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00100";                                -- Shamt = 4
    s_AluCntrl    <= "1101";                                 -- Alu Cntrl = 1101 for srl
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
    -- Test case 24: 5A5A5A5A << 8 = 5A5A5A00
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "01011010010110100101101001011010";     -- 5A5A5A5A
    s_BrrlShamt   <= "01000";                                -- Shamt = 8
    s_AluCntrl    <= "1101";                                 -- Alu Cntrl = 1101 for srl
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
                                     --AND test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 25: 00000000 AND 00000000 = 00000000
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "00000000000000000000000000000000";     -- 0
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "1110";                                 -- Alu Cntrl = 1110 for and
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
    -- Test case 26: FFFFFFFF AND FFFFFFFF = FFFFFFFF
-------------------------------------------------------------------------------------------------
    s_A           <= "11111111111111111111111111111111";     -- MAX
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "1110";                                 -- Alu Cntrl = 1110 for and
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
    -- Test case 27: AAAA5555 AND 55555555 = 00005555
-------------------------------------------------------------------------------------------------
    s_A    <= "10101010101010100101010101010101";            -- AAAAAAAA
    s_B    <= "01010101010101010101010101010101";            -- 55555555
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "1111";                                 -- Alu Cntrl = 1111 for and
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

------------------------------------------------------------------------------------------------------------------
                                     --BEQ test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 28:  beq 00000000 00000000  = 1
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "00000000000000000000000000000000";     -- 0
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "1010";                                 -- Alu Cntrl = 1010 for beq
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
    -- Test case 29: beq FFFFFFFF FFFFFFFF = 1
-------------------------------------------------------------------------------------------------
    s_A           <= "11111111111111111111111111111111";     -- MAX
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "1010";                                 -- Alu Cntrl = 1010 for beq
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
    -- Test case 30: beq AAAA5555 55555555 = 0
-------------------------------------------------------------------------------------------------
    s_A    <= "10101010101010100101010101010101";            -- AAAAAAAA
    s_B    <= "01010101010101010101010101010101";            -- 55555555
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "1010";                                 -- Alu Cntrl = 1010 for beq
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

------------------------------------------------------------------------------------------------------------------
                                     --BNE test cases
------------------------------------------------------------------------------------------------------------------
    -- Test case 28:  bne 00000000 00000000  = 0
-------------------------------------------------------------------------------------------------
    s_A           <= "00000000000000000000000000000000";     -- 0
    s_B           <= "00000000000000000000000000000000";     -- 0
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "1011";                                 -- Alu Cntrl = 1010 for bne
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
    -- Test case 29: bne FFFFFFFF FFFFFFFF = 0
-------------------------------------------------------------------------------------------------
    s_A           <= "11111111111111111111111111111111";     -- MAX
    s_B           <= "11111111111111111111111111111111";     -- MAX
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "1011";                                 -- Alu Cntrl = 1011 for bne
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;
	    
------------------------------------------------------------------------------------------------------------------
    -- Test case 30: bne AAAA5555 55555555 = 1
-------------------------------------------------------------------------------------------------
    s_A    <= "10101010101010100101010101010101";            -- AAAAAAAA
    s_B    <= "01010101010101010101010101010101";            -- 55555555
    s_BrrlShamt   <= "00000";                                -- Shamt = 0
    s_AluCntrl    <= "1011";                                 -- Alu Cntrl = 1011 for bne
--------------------------------------------------------------------------------------------------
   
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;





  end process;

end mixed;
