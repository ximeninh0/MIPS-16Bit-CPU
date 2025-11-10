LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY RIPPLE_CARRY IS 
	port(
		A,B : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Entradas de 4-bits
		Cin : IN STD_LOGIC;							-- Entrada para Carry-in
		Add_Sub :IN STD_LOGIC;						-- 0: Z<- A + B | 1: Z<- A - B
		Overflow : OUT STD_LOGIC;					-- se 1, há overflow
		Cout : OUT STD_LOGIC;						-- Saída do carry-out
		Z : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)	-- Resultado
	);
END RIPPLE_CARRY;

ARCHITECTURE Behavior OF RIPPLE_CARRY IS
SIGNAL C : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Y : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

	-- XOR entre os bits do 2º Operando para realizar o complemento de 2 no caso de subtração
	Y(0) <= B(0) XOR Add_Sub;
	Y(1) <= B(1) XOR Add_Sub;
	Y(2) <= B(2) XOR Add_Sub;
	Y(3) <= B(3) XOR Add_Sub;

-- Full_adders encadeados para somar ou subtrar os 4 bits
FADD1: FULLADDER PORT MAP(A(0),Y(0),Add_Sub,Z(0),C(0));
FADD2: FULLADDER PORT MAP(A(1),Y(1),C(0),Z(1),C(1));
FADD3: FULLADDER PORT MAP(A(2),Y(2),C(1),Z(2),C(2));
FADD4: FULLADDER PORT MAP(A(3),Y(3),C(2),Z(3),C(3));

Overflow <= C(2) XOR C(3); -- overflow é um XOR entre os dois ultimos carrys
Cout <= C(3);					-- carry-out recebe o carry-out do ultimo Full_adder
END Behavior;
