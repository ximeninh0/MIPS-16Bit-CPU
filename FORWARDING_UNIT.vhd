LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY FORWARDING_UNIT IS 
    port(
        RS, RT : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        REG_DST_EX_MEM : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        REG_DST_MEM_WB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

        WRITE_REG_EX_MEM : IN STD_LOGIC;
        WRITE_REG_MEM_WB : IN STD_LOGIC;
		  
--		  DST_EQ_RS_MEM, DST_EQ_RT_MEM : OUT STD_LOGIC;
--		  
--		  DST_EQ_RS_WB, DST_EQ_RT_WB : OUT STD_LOGIC;

        FOWARD_A : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        FOWARD_B : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END FORWARDING_UNIT;


ARCHITECTURE Behavior OF FORWARDING_UNIT IS
	BEGIN
    PROCESS(RS,RT,REG_DST_EX_MEM,REG_DST_MEM_WB,WRITE_REG_EX_MEM,WRITE_REG_MEM_WB)
    BEGIN
        FOWARD_A <= "00";
        FOWARD_B <= "00";

        -- EX Hazard
        IF (WRITE_REG_EX_MEM = '1') AND (REG_DST_EX_MEM /= "0000") THEN
            IF (REG_DST_EX_MEM = RS) THEN
                FOWARD_A <= "10";
            END IF;

            IF (REG_DST_EX_MEM = RT) THEN
                FOWARD_B <= "10";
            END IF;
        END IF;

        -- MEM Hazard
        IF ((WRITE_REG_MEM_WB = '1') AND (REG_DST_MEM_WB /= "0000")) AND NOT ((WRITE_REG_EX_MEM = '1') AND (REG_DST_EX_MEM /= "0000")) THEN
            IF (REG_DST_MEM_WB = RS) AND NOT (REG_DST_EX_MEM = RS) THEN
                FOWARD_A <= "01";
            END IF;

            IF (REG_DST_MEM_WB = RT) AND NOT (REG_DST_EX_MEM = RT) THEN
                FOWARD_B <= "01";
            END IF;
        END IF;

    END PROCESS;

END Behavior;
