LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY SEGS_4_TRANSLATOR IS 
		port(
			NUMBER : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			TRANSLATED : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
END SEGS_4_TRANSLATOR;

ARCHITECTURE Behavior OF SEGS_4_TRANSLATOR IS
-- Decodificador de numeros de 4 bits para 7 segmentos

BEGIN
	WITH NUMBER SELECT
    TRANSLATED <=
        "0000001" when "0000000000000000", --0
        "1001111" when "0000000000000001", --1
        "0010010" when "0000000000000010", --2
        "0000110" when "0000000000000011", --3
        "1001100" when "0000000000000100", --4
        "0100100" when "0000000000000101", --5
        "0100000" when "0000000000000110", --6
        "0001111" when "0000000000000111", --7
        "0000000" when "0000000000001000", --8
        "0000100" when "0000000000001001", --9
        "0001000" when "0000000000001010", --A
        "1100000" when "0000000000001011", --B
        "0110001" when "0000000000001100", --C
        "1000010" when "0000000000001101", --D
        "0110000" when "0000000000001110", --E
        "0111000" when "0000000000001111", --F

        -- Caracteres inventados a partir daqui
        "1010000" when "0000000000010000", --16
        "0001011" when "0000000000010001", --17
        "0011100" when "0000000000010010", --18
        "0110110" when "0000000000010011", --19
        "1110001" when "0000000000010100", --20
        "1011100" when "0000000000010101", --21
        "0001001" when "0000000000010110", --22
        "0100011" when "0000000000010111", --23
        "1100110" when "0000000000011000", --24
        "0011110" when "0000000000011001", --25
        "1110100" when "0000000000011010", --26
        "1000110" when "0000000000011011", --27
        "1100100" when "0000000000011100", --28
        "1010111" when "0000000000011101", --29
        "0110101" when "0000000000011110", --30

        "1111111" when others; -- apagado

END Behavior;