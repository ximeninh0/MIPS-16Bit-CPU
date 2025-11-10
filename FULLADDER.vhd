LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FULLADDER IS 
	port(
		A,B,Cin : IN STD_LOGIC;
		S,Cout : OUT STD_LOGIC
	);
END FULLADDER;


ARCHITECTURE Behavior OF FULLADDER IS
-- Componente FUll_adder que realiza a soma de 2 bits e gera Cout
BEGIN
S <= A XOR B XOR Cin;
Cout <= (A AND B) OR (Cin AND A) OR (Cin AND B); 

END Behavior;
