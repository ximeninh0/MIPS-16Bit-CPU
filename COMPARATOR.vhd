LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY COMPARATOR IS 
	port(
			A,B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			EQU,GRT,LST : OUT STD_LOGIC
	);
END COMPARATOR;

ARCHITECTURE Behavior OF COMPARATOR IS
SIGNAL i,j : STD_LOGIC_VECTOr(3 DOWNTO 0);
SIGNAL Cout : STD_LOGIC;
BEGIN
	-- XNOR bit-a-bit para verificar se é Igual
	i(0) <= A(0) XNOR B(0);
	i(1) <= A(1) XNOR B(1);
	i(2) <= A(2) XNOR B(2);
	i(3) <= A(3) XNOR B(3);
	
	-- verifica bit-a-bit se os bits de A são maiores que os de B 
	j(3) <= A(3) AND NOT B(3);
	j(2) <= i(3) AND A(2) AND NOT B(2);
	j(1) <= i(3) AND i(2) AND A(1) AND NOT B(1);
	j(0) <= i(3) AND i(2) AND i(1) AND A(0) AND NOT B(0);
	
	EQU <= i(0) AND i(1) AND i(2) AND i(3);	-- todos os XNORS retornarem verdade, os numeros são iguais
	GRT <= j(0) OR j(1) OR j(2) OR j(3);		-- se pelo menos um dos sinais da comparação de maior for verdade já torna A > B
	
	LST <= (i(0) AND i(1) AND i(2) AND i(3)) NOR (j(0) OR j(1) OR j(2) OR j(3)); -- se não for igual e nem maior, é menor

END Behavior;
