LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY ALU_CONTROL IS 
	port(
        ALU_OP  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        ADD_SUB : IN STD_LOGIC;
        ALU_CONTROL_OUT : OUT STD_LOGIC;
		);
END ALU_CONTROL;

ARCHITECTURE Behavior OF ALU_CONTROL IS

SIGNAL CONTROL_AUX : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

    CONTROL_AUX <= ADD_SUB & ALU_OP;

    WITH CONTROL_AUX SELECT
        ALU_CONTROL_OUT <= '0' WHEN "000", -- ADD (lw/sw)
                            '1' WHEN "001", -- SUB (beq)
                            '0' WHEN "010", -- FUNCT ADD (type r)
                            '1' WHEN "110", -- FUNCT SUB (type r)
                            '0' WHEN OTHERS; -- ADD quando erro


END Behavior;
