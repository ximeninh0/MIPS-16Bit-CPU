LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY MULTI_COMPONENT IS 
	port(
			X,Y :IN STD_LOGIC_VECTOR(1 DOWNTO 0);	-- Entradas de 2 bits
			Z : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)	-- Resultado da multiplcação
	);
END MULTI_COMPONENT;

ARCHITECTURE Behavior OF MULTI_COMPONENT IS
SIGNAL M : STD_LOGIC_VECTOr(3 DOWNTO 0);			-- Sinais que indicam ANDS das entradas
SIGNAL Cout : STD_LOGIC;
BEGIN
	--AND bit-a-bit com X e Y
	M(0) <= X(0) AND Y(0);
	M(1) <= X(0) AND Y(1);
	M(2) <= X(1) AND Y(0);
	M(3) <= X(1) AND Y(1);
	
Z(0) <= M(0);	-- Primeiro Bit do resultado recebe o AND dos primeiros
FADD1: FULLADDER PORT MAP(M(1),M(2),'0',Z(1),Cout);	-- O restante é resultado da soma encadeada da multipliação dos outros bits
FADD2: FULLADDER PORT MAP(M(3),Cout,'0',Z(2),Z(3));	-- (poderia ser feito com Half-adder)

END Behavior;
