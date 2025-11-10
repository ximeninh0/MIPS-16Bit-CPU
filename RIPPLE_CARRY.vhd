LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY RIPPLE_CARRY IS 
	port(
		A,B : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Entradas de 4-bits
		Cin : IN STD_LOGIC;							-- Entrada para Carry-in
		Add_Sub :IN STD_LOGIC;						-- 0: Z<- A + B | 1: Z<- A - B
		Overflow : OUT STD_LOGIC;					-- se 1, há overflow
		Cout : OUT STD_LOGIC;						-- Saída do carry-out
		Z : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)	-- Resultado
	);
END RIPPLE_CARRY;

ARCHITECTURE Behavior OF RIPPLE_CARRY IS
SIGNAL C, Y : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

	-- XOR entre os bits do 2º Operando para realizar o complemento de 2 no caso de subtração
	Y(0) <= B(0) XOR Add_Sub;
	Y(1) <= B(1) XOR Add_Sub;
	Y(2) <= B(2) XOR Add_Sub;
	Y(3) <= B(3) XOR Add_Sub;
	Y(4) <= B(4) XOR Add_Sub;
	Y(5) <= B(5) XOR Add_Sub;
	Y(6) <= B(6) XOR Add_Sub;
	Y(7) <= B(7) XOR Add_Sub;
	Y(8) <= B(8) XOR Add_Sub;
	Y(9) <= B(9) XOR Add_Sub;
	Y(10) <= B(10) XOR Add_Sub;
	Y(11) <= B(11) XOR Add_Sub;
	Y(12) <= B(12) XOR Add_Sub;
	Y(13) <= B(13) XOR Add_Sub;
	Y(14) <= B(14) XOR Add_Sub;
	Y(15) <= B(15) XOR Add_Sub;

-- Full_adders encadeados para somar ou subtrar os 4 bits
FADD1: FULLADDER PORT MAP(A(0),Y(0),Add_Sub,Z(0),C(0));
FADD2: FULLADDER PORT MAP(A(1),Y(1),C(0),Z(1),C(1));
FADD3: FULLADDER PORT MAP(A(2),Y(2),C(1),Z(2),C(2));
FADD4: FULLADDER PORT MAP(A(3),Y(3),C(2),Z(3),C(3));

FADD5: FULLADDER PORT MAP(A(4),Y(4),C(3),Z(4),C(4));
FADD6: FULLADDER PORT MAP(A(5),Y(5),C(4),Z(5),C(5));
FADD7: FULLADDER PORT MAP(A(6),Y(6),C(5),Z(6),C(6));
FADD8: FULLADDER PORT MAP(A(7),Y(7),C(6),Z(7),C(7));

FADD9: FULLADDER PORT MAP(A(8),Y(8),C(7),Z(8),C(8));
FADD10: FULLADDER PORT MAP(A(9),Y(9),C(8),Z(9),C(9));
FADD11: FULLADDER PORT MAP(A(10),Y(10),C(9),Z(10),C(10));
FADD12: FULLADDER PORT MAP(A(11),Y(11),C(10),Z(11),C(11));

FADD13: FULLADDER PORT MAP(A(12),Y(12),C(11),Z(12),C(12));
FADD14: FULLADDER PORT MAP(A(13),Y(13),C(12),Z(13),C(13));
FADD15: FULLADDER PORT MAP(A(14),Y(14),C(13),Z(14),C(14));
FADD16: FULLADDER PORT MAP(A(15),Y(15),C(14),Z(15),C(15));

Overflow <= C(14) XOR C(15); -- overflow é um XOR entre os dois ultimos carrys
Cout <= C(15);					-- carry-out recebe o carry-out do ultimo Full_adder
END Behavior;
