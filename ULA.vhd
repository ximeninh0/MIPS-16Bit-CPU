LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY ULA IS 
	port(
			A,B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);		-- Entradas A e B de 8 bits
			RESULT: out STD_LOGIC_VECTOR(15 DOWNTO 0);	-- Resultado de 4 bits
			OPERATION: IN STD_LOGIC;					-- Entrada que indica a operação que será realizada pela ULA
			ZERO, OVERFLOW,Cout : OUT STD_LOGIC;		-- ZERO: 1 em caso do resultado ser 0, OV: 1 no caso da operação resultar em Overflow, Cout: 1 em caso de carry-out
		);
END ULA;

ARCHITECTURE Behavior OF ULA IS

BEGIN
-- Instanciação dos componentes que vão realizar cada operação dentro da ULA
RIPPLE_DECLARATION: RIPPLE_CARRY PORT MAP(A,B,OPERATION,OPERATION, OVERFLOW, Cout, RESULT);

	-- WITH OPERATION SELECT
	-- 	ZERO <=	'0' WHEN "0000",
	-- 				ZERO_AUX WHEN OTHERS;
	
	ZERO <= NOT(RESULT(0) OR RESULT(1) OR RESULT(2) OR RESULT(3) OR RESULT(4)
			 OR RESULT(5) OR RESULT(6) OR RESULT(7) OR RESULT(8) OR RESULT(9)
			 OR RESULT(10) OR RESULT(11) OR RESULT(12) OR RESULT(13) OR RESULT(14) OR RESULT(15));
				

END Behavior;
