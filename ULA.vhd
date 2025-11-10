LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY ULA IS 
	port(
			A,B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);			-- Entradas A e B de 4 bits
			OPERATION: IN STD_LOGIC_VECTOR (3 DOWNTO 0);	-- Entrada que indica a operação que será realizada pela ULA
			ZERO, OVERFLOW,Cout : OUT STD_LOGIC;			-- ZERO: 1 em caso do resultado ser 0, OV: 1 no caso da operação resultar em Overflow, Cout: 1 em caso de carry-out
			RESULT: out STD_LOGIC_VECTOR(3 DOWNTO 0);	-- Resultado de 4 bits
			Equ,Grt,Lst : OUT STD_LOGIC					-- EQU: 1 caso A = B, GRT: 1 caso A > B, LST: 1 caso A < B
		);
END ULA;

ARCHITECTURE Behavior OF ULA IS

SIGNAL RES_RIPPLE,RES_AND,RES_OR,RES_NOT,RES_MULTI,B_AUX : STD_LOGIC_VECTOR(3 DOWNTO 0);	-- Sinais auxiliares para multiplexação
SIGNAL RES_EQU,RES_GRT,RES_LST,RES_OVERFLOW,RES_COUT, Cout_SOMA,ADD_SUB,ZERO_AUX: STD_LOGIC;

BEGIN
-- Instanciação dos componentes que vão realizar cada operação dentro da ULA
RIPPLE_DECLARATION: RIPPLE_CARRY PORT MAP(A,B_AUX,ADD_SUB,ADD_SUB, RES_OVERFLOW, RES_COUT, RES_RIPPLE);
AND_DECLARATION: AND_COMPONENT PORT MAP(A,B,RES_AND);
OR_DECLARATION: OR_COMPONENT PORT MAP(A,B,RES_OR);
NOT_DECLARATION: NOT_COMPONENT PORT MAP(A,B,RES_NOT);
MULTIPLICATOR: MULTI_COMPONENT PORT MAP(A(1 downto 0),B(1 DOWNTO 0),RES_MULTI);
COMPARATOR_DECLARATION : COMPARATOR PORT MAP(A,B,RES_EQU,RES_GRT,RES_LST);


-- MUX responsável por direcionar o resultado principal de acordo com a operação
	WITH OPERATION SELECT
		RESULT <=  	RES_RIPPLE WHEN "1111",
						RES_RIPPLE WHEN "0100",
						RES_RIPPLE WHEN "0101",
						RES_AND WHEN "0001",
						RES_OR WHEN "0010",
						RES_NOT WHEN "0011",
						RES_MULTI WHEN "0110",
						"0000" WHEN OTHERS;
-- Em caso de SWAP, soma com zero
	WITH OPERATION SELECT
		B_AUX <= "0000" WHEN "1111",
					 B WHEN OTHERS;

-- MUXes auxiliares para evitar ruídos indesejados em outras operações
	WITH OPERATION SELECT
		Equ <= RES_EQU WHEN "0111",
				 '0' WHEN OTHERS;
				 
	WITH OPERATION SELECT
		Grt <= RES_GRT WHEN "0111",
				 '0' WHEN OTHERS;
				 
	WITH OPERATION SELECT
		Lst <= RES_LST WHEN "0111",
				 '0' WHEN OTHERS;
				 
	WITH OPERATION SELECT
		ADD_SUB <= '1' WHEN "0101",
					  '0' WHEN OTHERS;		
					  
	WITH OPERATION SELECT
		Cout <= RES_COUT WHEN "0100",
				  RES_COUT WHEN "0101",
				  '0' WHEN OTHERS;
				  
	WITH OPERATION SELECT
		OVERFLOW <= RES_OVERFLOW WHEN "0100",
						RES_OVERFLOW WHEN "0101",
						'0' WHEN OTHERS;
						
	WITH OPERATION SELECT
		ZERO <=	'0' WHEN "0000",
					ZERO_AUX WHEN OTHERS;
	
	-- Verifica se todos os bits são 0 para acender o sinal ZERO
	ZERO_AUX <= NOT(RESULT(0) OR RESULT(1) OR RESULT(2) OR RESULT(3));
				

END Behavior;
