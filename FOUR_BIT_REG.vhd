LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY FOUR_BIT_REG IS 
	port(
		D : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		R_in,Reset,Clock : IN STD_LOGIC;
		D_out: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END FOUR_BIT_REG;

ARCHITECTURE Behavior OF FOUR_BIT_REG IS
BEGIN
	PROCESS (Reset,Clock,R_in)
		BEGIN
		IF Reset = '1' THEN
			D_out <=(OTHERS =>'0'); -- Em caso de RESET zera o valor 

		-- Registrador guarda o valor caso não haja sinal de reset
		ELSIF (Clock'EVENT AND Clock = '0') THEN
				
			IF (R_in = '1') THEN
				D_out <= D;				-- Caso acione o sinal de entrada armazena o novo valor
			END IF;
		END IF;
	END PROCESS;
END Behavior;
