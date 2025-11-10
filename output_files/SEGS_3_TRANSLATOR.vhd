LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY SEGS_3_TRANSLATOR IS 
	port(
		NUMBER : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		TRANSLATED : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END SEGS_3_TRANSLATOR;

ARCHITECTURE Behavior OF SEGS_3_TRANSLATOR IS
-- Decodificador de numeros de 3 bits para 7 segmentos
BEGIN
	WITH NUMBER SELECT
	 TRANSLATED <= "0000001" when "000", --0
				  "1001111" when "001", --1
				  "0010010" when "010", --2
				  "0000110" when "011", --3
				  "1001100" when "100", --4
				  "0100100" when "101", --5
				  "0100000" when "110", --6
				  "0001111" when "111", --7
				  "1111111" when others; --apagado

END Behavior;