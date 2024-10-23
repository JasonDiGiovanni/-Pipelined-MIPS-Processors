-------------------------------------------------------------------------
-- Luca Cano
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- control.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a control implementation.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity control is
  port(op_Code	    	: in std_logic_vector(5 downto 0);
	Funct		    	: in std_logic_vector(5 downto 0);
	RegDst		    	: out std_logic;
	MemtoReg 	   		: out std_logic;
	MemWrite 	    	: out std_logic;
	ALUSrc 		   		: out std_logic;
	RegWrite 	   		: out std_logic;
	ALUControl	    	: out std_logic_vector(3 downto 0);
	beq 		    	: out std_logic;
 	bne 		    	: out std_logic;
	j  		        	: out std_logic;
	jr 		        	: out std_logic;
	sltu            	: out std_logic;
	shiftVariable   	: out std_logic;
	upper_immediate 	: out std_logic;
	signSel				: out std_logic;
	halt				: out std_logic);



end control;

architecture behavioral of control is
signal opCode                   : std_logic_vector(5 downto 0);
signal	functCode	: std_logic_vector(5 downto 0);
signal	code		: std_logic_vector(5 downto 0);
signal	R_type		: std_logic := '0';
signal s_halt                   : std_logic := '0';

begin
	opCode <= op_Code;
	functCode <= funct;
	code <= functCode	when(opCode = "000000")else
	        opCode;
	R_type <= '1'		when(opCode = "000000")else
	        '0';

	p_whichInstr : process(code, R_type) is
	begin
			--recognizing op code then basing what instruction it goes off of the function code
			
				--Instruction -> "NOOP"
				if(code = "111111") then
					RegDst          <= 'X';
					ALUSrc          <= 'X';
					MemtoReg        <= 'X';
					RegWrite        <= 'X';
					MemWrite        <= 'X';
					ALUControl      <= "XXXX";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
					shiftVariable   <= '0';
					signSel			<= '1';
					upper_immediate <= '0';
                		
				--Instruction -> "add"
				elsif (code = "100000") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "0010";
					--These apply to all
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
					signSel			<= '1';
                    upper_immediate <= '0';


				--Instruction -> "addu"
				elsif (code = "100001") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "0010";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
					signSel			<= '1';
                    upper_immediate <= '0';
				
				--Instruction -> "and"
				elsif (code = "100100") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "1110";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
					signSel			<= '1';
                    upper_immediate <= '0';

				--Instruction -> "nor"
				elsif (code = "100111") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "0000";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
					signSel			<= '1';
                    upper_immediate <= '0';

				--Instruction -> "xor"
				elsif (code = "100110") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "0100";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
					signSel			<= '1';
                    upper_immediate <= '0';

				--Instruction -> "or"
				elsif (code = "100101") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "0001";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
                    signSel			<= '1';
					upper_immediate <= '0';
	
				--Instruction -> "slt"
				elsif (code = "101010") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "0111";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
                    signSel			<= '1';
					upper_immediate <= '0';

				--Instruction -> "sltu"
				elsif (code = "101011" and R_type= '1') then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "0111";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '1';
                    shiftVariable   <= '0';
					signSel			<= '1';
                    upper_immediate <= '0';

				--Instruction -> "sll"
				elsif (code = "000000" and R_type = '1') then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "1101";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
					signSel			<= '1';
                    upper_immediate <= '0';

				--Instruction -> "srl"
				elsif (code = "000010" and R_type = '1') then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "1001";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
					signSel			<= '1';
                    upper_immediate <= '0';

				--Instruction -> "sra"
				elsif (code = "000011" and R_type = '1') then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "1000";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
                    signSel			<= '1';
					upper_immediate <= '0';

				--Instruction -> "sllv"
				elsif (code = "000100" and R_type = '1') then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "XXXX";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '1';
                    signSel			<= '1';
					upper_immediate <= '0';

				--Instruction -> "srlv"
				elsif (code = "000110") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "XXXX";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '1';
                    signSel			<= '1';
					upper_immediate <= '0';
				
				--Instruction -> "srav"
				elsif (code = "000111") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "XXXX";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '1';
                    signSel			<= '1';
					upper_immediate <= '0';
		
				--Instruction -> "sub"	
				elsif (code = "100010") then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "0011";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
                    signSel			<= '1';
					upper_immediate <= '0';
				
				--Instruction -> "subu"
				elsif (code = "100011" and R_type = '1') then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '1';
					MemWrite        <= '0';
					ALUControl      <= "0011";
					beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '0';
					sltu            <= '0';
                    shiftVariable   <= '0';
                    signSel			<= '1';
					upper_immediate <= '0';

				--Instruction -> "jr" 
				elsif(code = "001000"and R_type='1') then
					RegDst          <= '1';
					ALUSrc          <= '0';
					MemtoReg        <= '0';
					RegWrite        <= '0';
					MemWrite        <= '0';
					ALUControl      <= "XXXX";
                    beq             <= '0';
					bne             <= '0';
					j               <= '0';
					jr              <= '1';
					sltu            <= '0';
                    shiftVariable   <= '0';
                    signSel			<= '1';
					upper_immediate <= '0';

			--Immediate instructions
			--Instruction -> "addi"
			elsif (code = "001000" and R_type='0') then
				RegDst          <= '0';
				ALUSrc          <= '0';
				MemtoReg        <= '0';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "0010";
				beq             <= '0';
            	bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';

			--Instruction -> "addiu"
			elsif (code = "001001") then
				RegDst          <= '0';
				ALUSrc          <= '0';
				MemtoReg        <= '0';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "0010";
				beq             <= '0';
                bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';


			--Instruction -> "andi"
			elsif (code = "001100") then
				RegDst          <= '0';
				ALUSrc          <= '1';
				MemtoReg        <= '0';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "1110";
				beq             <= '0';
                bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '0';
				upper_immediate <= '0';


			--Instruction -> "lui"
			elsif (code = "001111") then
				RegDst          <= '0';
				ALUSrc          <= '1';
				MemtoReg        <= '0';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "XXXX";
				beq             <= '0';
                bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '1';


			--Instruction -> "xori"
			elsif (code = "001110") then
				RegDst          <= '0';
				ALUSrc          <= '1';
				MemtoReg        <= '0';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "0100";
				beq             <= '0';
                bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';


			--Instruction -> "ori"
			elsif (code = "001101") then
				RegDst          <= '0';
				ALUSrc          <= '1';
				MemtoReg        <= '0';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "0001";
				beq             <= '0';
                bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '0';
				upper_immediate <= '0';

			
			--Instruction -> "slti"
		 	elsif (code = "001010") then
				RegDst          <= '0';
				ALUSrc          <= '1';
				MemtoReg        <= '0';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "0111";
				beq             <= '0';
                bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';


			--Instruction -> "sltiu"
			elsif (code = "001011") then
				RegDst          <= '0';
				ALUSrc          <= '1';
				MemtoReg        <= '0';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "0111";
				beq             <= '0';
                bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '1';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';


			--Load and Store Instructions
			--Instruction -> "lw"
			elsif (code = "100011" and R_type = '0') then
				RegDst          <= '0';
				ALUSrc          <= '1';
				MemtoReg        <= '1';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "0010";
				beq             <= '0';
                bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';


			--Instruction -> "sw"
			elsif (code = "101011" and R_type = '0') then
				RegDst          <= '0';
				ALUSrc          <= '1';
				MemtoReg        <= '0';
				RegWrite        <= '0';
				MemWrite        <= '1';
				ALUControl      <= "0010";
				beq             <= '0';
                bne             <= '0';
                j               <= '0';
                jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';


			--Branch Instructions
			--Instruction -> "beq"
			elsif (code = "000100"  and R_type = '0') then
				RegDst          <= '0';
				ALUSrc          <= '0';
				MemtoReg        <= '0';
				RegWrite        <= '0';
				MemWrite        <= '0';
				ALUControl      <= "1010";
				beq             <= '1';
				bne             <= '0';
				j               <= '0';
				jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';


			--Instruction -> "bne"
			elsif (code = "000101") then
				RegDst          <= '0';
				ALUSrc          <= '0';
				MemtoReg        <= '0';
				RegWrite        <= '0';
				MemWrite        <= '0';
				ALUControl      <= "1011";
				beq             <= '0';
                bne             <= '1';
				j               <= '0';
				jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';

			--Instruction -> "j"
			elsif (code = "000010" and R_type = '0') then
				RegDst          <= '0';
				ALUSrc          <= '0';
				MemtoReg        <= '0';
				RegWrite        <= '0';
				MemWrite        <= '0';
				ALUControl      <= "XXXX";
				beq             <= '0';
				bne             <= '0';
				j               <= '1';
				jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';
			
			--Instruction -> "jal"
			elsif (code = "000011" and R_type = '0') then
				RegDst          <= '0';
				ALUSrc          <= '0';
				MemtoReg        <= '0';
				RegWrite        <= '1';
				MemWrite        <= '0';
				ALUControl      <= "XXXX";
				beq             <= '0';
				bne             <= '0';
				j               <= '1';
				jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';
                		
			--Instruction -> "halt"
			elsif (code = "010001") then
				RegDst          <= '0';
				ALUSrc          <= '0';
				MemtoReg        <= '0';
				RegWrite        <= '0';
				MemWrite        <= '0';
				ALUControl      <= "XXXX";
				beq             <= '0';
                bne             <= '0';
				j               <= '0';
				jr              <= '0';
                sltu            <= '0';
                shiftVariable   <= '0';
                signSel			<= '1';
				upper_immediate <= '0';
                s_halt          <= '1';

		end if;
		
end process p_whichInstr;
	
	halt <= s_halt;
	
end behavioral;

