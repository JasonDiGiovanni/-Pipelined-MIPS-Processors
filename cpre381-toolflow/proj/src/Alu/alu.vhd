-------------------------------------------------------------------------
-- Owen Jewell
-- CprE 381
-- Iowa State University
-------------------------------------------------------------------------


-- alu.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation of the ALU
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity alu is
  port(i_A          : in std_logic_vector(31 downto 0);             -- First 32 bit data input
       i_B          : in std_logic_vector(31 downto 0);             -- Second 32 bit data input
       i_BrrlShamt  : in std_logic_vector(4 downto 0);              -- Barrel shifter shift amount (0 to 31)
       i_AluCntrl   : in std_logic_vector(3 downto 0);  
       o_Zero       : out std_logic;                                -- Output used for to take either program counter + 4 or branch immediate
       o_C          : out std_logic;                                -- Carry output
       o_O          : out std_logic;                                -- Overflow output
       o_AluOut     : out std_logic_vector(31 downto 0));           -- ALU out
end alu;


----------------------------------------------------------------------
-- ALU control Truth table:
-- nAddSub    : in std_logic;                                 -- Add or subtract select (0 = add, 1 = subtract)
-- i_brrlDir    : in std_logic;                               -- Barrel shifter shift direction  (0 = left, 1 = right)
-- i_brrlTyp    : in std_logic;                               -- Barrel shifter shift type (0 = logical, 1 = arithmetic)
-- i_EqNeSel    : in std_logic;                               -- Equal or Not Equal Select ( If input 0 = bne | If input 1 = beq  )
                                                              -- If bne output 1 if not equal and 0 if equal
                                                              -- If beq output 1 if equal and 0 if not equal
--   |    ALU control
--   |  ______________________________
--   |     0  |   0  |   0   |   0   |  nor
--   |     0  |   0  |   0   |   1   |  or, ori
--   |     0  |   0  |   1   |   0   |  add, addi, addu, addiu, lw, sw, 
--   |     0  |   0  |   1   |   1   |  sub, subu 
--   |     0  |   1  |   0   |   0   |  xor, xori
--   |     0  |   1  |   0   |   1   |  
--   |     0  |   1  |   1   |   0   |  
--   |     0  |   1  |   1   |   1   |  slt, slti, sltiu, sltu
--   |     1  |   0  |   0   |   0   |  sra
--   |     1  |   0  |   0   |   1   |  srl
--   |     1  |   0  |   1   |   0   |  beq
--   |     1  |   0  |   1   |   1   |  bne
--   |     1  |   1  |   0   |   0   | 
--   |     1  |   1  |   0   |   1   |  sll
--   |     1  |   1  |   1   |   0   |  and, andi
--   |     1  |   1  |   1   |   1   |  


architecture structural of alu is

component carryLookaheadAdder is
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       i_nAddSub    : in std_logic;
       o_C          : out std_logic;
       o_O          : out std_logic;
       o_S          : out std_logic_vector(31 downto 0));
end component;

component barrelShifter is
   port(i_Shft_Type_Sel    : in std_logic;                              
        i_Shft_Dir         : in std_logic;                              
        i_Shft_Amt         : in std_logic_vector(4 downto 0);           
        i_D                : in std_logic_vector(31 downto 0);          
        o_O                : out std_logic_vector(31 downto 0));       
end component;


component mux2t1 is
    port(i_S                  : in std_logic;
         i_D0                 : in std_logic;
         i_D1                 : in std_logic;
         o_O                  : out std_logic);
end component;

component mux2t1_N is
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(31 downto 0);
       i_D1         : in std_logic_vector(31 downto 0);
       o_O          : out std_logic_vector(31 downto 0));
end component;


component mux8t1_32 is
  port(i_S          : in std_logic_vector(2 downto 0);
       i_D0         : in std_logic_vector(31 downto 0);
       i_D1         : in std_logic_vector(31 downto 0);
       i_D2         : in std_logic_vector(31 downto 0);
       i_D3         : in std_logic_vector(31 downto 0);
       i_D4         : in std_logic_vector(31 downto 0);
       i_D5         : in std_logic_vector(31 downto 0);
       i_D6         : in std_logic_vector(31 downto 0);
       i_D7         : in std_logic_vector(31 downto 0);
       o_O          : out std_logic_vector(31 downto 0));

end component;

component onesComp_N is
   port(i_I          : in std_logic_vector(31 downto 0);
        o_O          : out std_logic_vector(31 downto 0));
end component;

component invg
    port(i_A          : in std_logic;
         o_F          : out std_logic);
  end component;

  component andg2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  component org2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  component xorg2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;


component equalityModule is
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic);
end component;

component equalityMuxModule is
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end component;

component lessThanModule is
  port(i_A          : in std_logic_vector(31 downto 0);
       i_B          : in std_logic_vector(31 downto 0);
       o_F          : out std_logic_vector(31 downto 0));
end component;

--Signals
signal s_BrrlOut : std_logic_vector(31 downto 0);
signal s_AddrOut : std_logic_vector(31 downto 0);
signal s_AndOut  : std_logic_vector(31 downto 0);
signal s_XorOut  : std_logic_vector(31 downto 0);
signal s_OrOut   : std_logic_vector(31 downto 0);
signal s_NorOut  : std_logic_vector(31 downto 0);
signal s_SltOut  : std_logic_vector(31 downto 0);
signal s_OrNorOut  : std_logic_vector(31 downto 0);
signal s_EqlMuxOut : std_logic_vector(31 downto 0);
signal s_NotAluZero : std_logic;
signal s_NotAluTwo : std_logic;
signal s_EqlOut    : std_logic;
signal s_NotEqlOut : std_logic;


begin


e_equalityModule: equalityModule
  port map(
            i_A  => i_A,
      	    i_B  => i_B,
      	    o_F  => s_EqlOut);

e_equalityMuxModule: equalityMuxModule
  port map(
            i_A  => i_A,
      	    i_B  => i_B,
      	    o_F  => s_EqlMuxOut);

l_lessThanModule: lessThanModule
  port map(
            i_A  => i_A,
      	    i_B  => i_B,
      	    o_F  => s_SltOut);

g_NotOne: invg
  port map(
           i_A      => s_EqlOut,
           o_F      => s_NotEqlOut);

MUXI: mux2t1 
  port map(
           i_S      => i_AluCntrl(0),      -- if bit is 0 then beq, if bit is a 1 then bne
           i_D0     => s_EqlOut, 
           i_D1     => s_NotEqlOut,  
           o_O      => o_Zero);  

c_carryAdder: carryLookaheadAdder
  port map(
            i_A       => i_A,
            i_B       => i_B,
            i_nAddSub => i_AluCntrl(0),
            o_C       => o_C,
            o_O       => o_O,
      	    o_S       => s_AddrOut);

G_NBit_AND: for i in 0 to 31 generate
    ANDI: andg2 port map(
              i_A     => i_A(i),     
              i_B     => i_B(i),  
              o_F     => s_AndOut(i)); 
  end generate G_NBit_AND;

G_NBit_XOR: for i in 0 to 31 generate
    XORI: xorg2 port map(
              i_A     => i_A(i),     
              i_B     => i_B(i),  
              o_F     => s_XorOut(i)); 
  end generate G_NBit_XOR;

G_NBit_OR: for i in 0 to 31 generate
    ORI: org2 port map(
              i_A     => i_A(i),     
              i_B     => i_B(i),  
              o_F     => s_OrOut(i)); 
  end generate G_NBit_OR;

o_Nor : onesComp_N
   port map (
             i_I  => s_OrOut,
             o_O  => s_NorOut);

MUXORNOR: mux2t1_N 
  port map(
           i_S      => i_AluCntrl(0),      -- if bit is 0 then beq, if bit is a 1 then bne
           i_D0     => s_NorOut, 
           i_D1     => s_OrOut,  
           o_O      => s_OrNorOut);  

g_NotAluZero: invg
  port map(
           i_A      => i_AluCntrl(0),
           o_F      => s_NotAluZero);

g_NotAluTwo: invg
  port map(
           i_A      => i_AluCntrl(2),
           o_F      => s_NotAluTwo);


b_barrelShifter : barrelShifter
  port map(
           i_Shft_Type_Sel    =>   s_NotAluZero,
           i_Shft_Dir         =>   s_NotAluTwo,
 	   i_Shft_Amt         =>   i_BrrlShamt,      
           i_D                =>   i_B,                  
           o_O                =>   s_BrrlOut); 

a_aluOutMux: mux8t1_32
  port map(
            i_D0  => s_OrNorOut, -- Or or Nor
      	    i_D1  => s_AddrOut,  -- Adder
            i_D2  => s_XorOut,   -- Xor
      	    i_D3  => s_SltOut,   -- Slt
            i_D4  => s_BrrlOut,  -- Shift (right)
      	    i_D5  => s_EqlMuxOut,-- Beq or Bne out (not necessary)
            i_D6  => s_BrrlOut,  -- Shift (left)
      	    i_D7  => s_AndOut,   -- And
      	    i_S	  => i_AluCntrl(3 downto 1), --Take left most 3 bits of alu cntrl
      	    o_O   => o_AluOut);

end structural;
