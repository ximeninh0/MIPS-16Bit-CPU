LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY ALU_CONTROL IS 
	port(
        ALU_OP  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        ADD_SUB : IN STD_LOGIC;
        ALU_CONTROL_OUT : OUT STD_LOGIC
		);
END ALU_CONTROL;

ARCHITECTURE Behavior OF ALU_CONTROL IS

SIGNAL CONTROL_AUX : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

    CONTROL_AUX <= ALU_OP & ADD_SUB;

    WITH CONTROL_AUX SELECT
        ALU_CONTROL_OUT <= '0' WHEN "00X", -- ADD (lw/sw)
                            '1' WHEN "01X", -- SUB (beq)
                            '0' WHEN "100", -- FUNCT ADD (type r)
                            '1' WHEN "101", -- FUNCT SUB (type r)
                            '0' WHEN OTHERS; -- ADD quando erro


END Behavior;
