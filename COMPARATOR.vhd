LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY COMPARATOR16 IS 
    port(
        A,B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        EQU : OUT STD_LOGIC
    );
END COMPARATOR16;

ARCHITECTURE Behavior OF COMPARATOR16 IS
SIGNAL i,j : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    -- XNOR bit a bit
    i(0)  <= A(0)  XNOR B(0);
    i(1)  <= A(1)  XNOR B(1);
    i(2)  <= A(2)  XNOR B(2);
    i(3)  <= A(3)  XNOR B(3);
    i(4)  <= A(4)  XNOR B(4);
    i(5)  <= A(5)  XNOR B(5);
    i(6)  <= A(6)  XNOR B(6);
    i(7)  <= A(7)  XNOR B(7);
    i(8)  <= A(8)  XNOR B(8);
    i(9)  <= A(9)  XNOR B(9);
    i(10) <= A(10) XNOR B(10);
    i(11) <= A(11) XNOR B(11);
    i(12) <= A(12) XNOR B(12);
    i(13) <= A(13) XNOR B(13);
    i(14) <= A(14) XNOR B(14);
    i(15) <= A(15) XNOR B(15);

    EQU <= i(0) AND i(1) AND i(2) AND i(3) AND i(4) AND i(5) AND i(6) AND i(7) AND i(8) AND i(9) AND i(10) AND i(11) AND i(12) AND i(13) AND i(14) AND i(15);

END Behavior;
