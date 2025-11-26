LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.CPU_PACKAGE.all;
ENTITY CONTROL_UNIT IS 
    PORT(
        INSTRUCTION : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        REG_EQUAL : IN STD_LOGIC; --

        IF_FLUSH : OUT STD_LOGIC; --
        ID_FLUSH : OUT STD_LOGIC; --
        EX_FLUSH : OUT STD_LOGIC; -- 
        WB_FLUSH : OUT STD_LOGIC; --

        PC_SOURCE : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALU_SRC : OUT STD_LOGIC;
        REG_DST : OUT STD_LOGIC;
        ALU_OP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- Sinais de controle MEM
        MEM_WRITE : OUT STD_LOGIC;
        MEM_READ : OUT STD_LOGIC;

        -- Sinais de controle WB
        MEM_TO_REG : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        REG_WRITE : OUT STD_LOGIC;
		  
		CLOCK : IN STD_LOGIC
    );
END CONTROL_UNIT;

ARCHITECTURE Behavior OF CONTROL_UNIT IS
SIGNAL OPCODE : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL BEQ_AUX : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN

	WITH REG_EQUAL SELECT
		BEQ_AUX <= "10" WHEN '1',
						"00" WHEN '0',
						"00" WHEN OTHERS;

	OPCODE <= INSTRUCTION(15 DOWNTO 13);
	WITH OPCODE SELECT
		PC_SOURCE <= 	"00" WHEN "000", -- NOP
						"00" WHEN "001", -- LW
						"00" WHEN "010", -- SW
						"00" WHEN "011", -- ADD/SUB
						BEQ_AUX WHEN "100", -- BEQ
						"11" WHEN "101", -- JMP
						"00" WHEN "110", -- LI - LOAD INTEGER
						"00" WHEN "111", -- EXTRA
						"00" WHEN OTHERS;
	WITH OPCODE SELECT
		ALU_SRC <= 	'0' WHEN "000", -- NOP
					'1' WHEN "001", -- LW
					'1' WHEN "010", -- SW
					'0' WHEN "011", -- ADD/SUB
					'1' WHEN "100", -- BEQ
					'0' WHEN "101", -- JMP
					'1' WHEN "110", -- LI - LOAD INTEGER
					'0' WHEN "111", -- EXTRA
					'0' WHEN OTHERS;
	WITH OPCODE SELECT
		REG_DST <= 	'0' WHEN "000", -- NOP
					'0' WHEN "001", -- LW
					'0' WHEN "010", -- SW
					'1' WHEN "011", -- ADD/SUB
					'0' WHEN "100", -- BEQ
					'0' WHEN "101", -- JMP
					'0' WHEN "110", -- LI - LOAD INTEGER
					'0' WHEN "111", -- EXTRA
					'0' WHEN OTHERS;
	WITH OPCODE SELECT
		ALU_OP <= 	"00" WHEN "000", -- NOP
					"00" WHEN "001", -- LW
					"00" WHEN "010", -- SW
					"10" WHEN "011", -- ADD/SUB
					"01" WHEN "100", -- BEQ
					"00" WHEN "101", -- JMP
					"00" WHEN "110", -- LI - LOAD INTEGER
					"00" WHEN "111", -- EXTRA
					"00" WHEN OTHERS;
	WITH OPCODE SELECT
		MEM_WRITE <= 	'0' WHEN "000", -- NOP
						'0' WHEN "001", -- LW
						'1' WHEN "010", -- SW
						'0' WHEN "011", -- ADD/SUB
						'0' WHEN "100", -- BEQ
						'0' WHEN "101", -- JMP
						'0' WHEN "110", -- LI - LOAD INTEGER
						'0' WHEN "111", -- EXTRA
						'0' WHEN OTHERS;
	WITH OPCODE SELECT
		MEM_READ <= 	'0' WHEN "000", -- NOP
						'1' WHEN "001", -- LW
						'0' WHEN "010", -- SW
						'0' WHEN "011", -- ADD/SUB
						'0' WHEN "100", -- BEQ
						'0' WHEN "101", -- JMP
						'0' WHEN "110", -- LI - LOAD INTEGER
						'0' WHEN "111", -- EXTRA
						'0' WHEN OTHERS;
		
	WITH OPCODE SELECT
		MEM_TO_REG <= 	"00" WHEN "000", -- NOP
						"00" WHEN "001", -- LW
						"00" WHEN "010", -- SW
						"10" WHEN "011", -- ADD/SUB
						"00" WHEN "100", -- BEQ
						"00" WHEN "101", -- JMP
						"10" WHEN "110", -- LI - LOAD INTEGER
						"00" WHEN "111", -- EXTRA
						"00" WHEN OTHERS;

	WITH OPCODE SELECT
		REG_WRITE <= 	'0' WHEN "000", -- NOP
						'1' WHEN "001", -- LW
						'0' WHEN "010", -- SW
						'1' WHEN "011", -- ADD/SUB
						'0' WHEN "100", -- BEQ
						'0' WHEN "101", -- JMP
						'1' WHEN "110", -- LI - LOAD INTEGER
						'0' WHEN "111", -- EXTRA
						'0' WHEN OTHERS;

END Behavior;