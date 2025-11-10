LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY BUFFER_TRI IS 
	port(
			ENTRADA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			GATE : IN STD_LOGIC;
			SAIDA: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END BUFFER_TRI;
-- O buffer apenas permite a passagem de dados mediante a liberação do GATE
ARCHITECTURE Behavior OF BUFFER_TRI IS
BEGIN
	SAIDA <= ENTRADA WHEN GATE = '1' ELSE (OTHERS =>'Z');

END Behavior;
