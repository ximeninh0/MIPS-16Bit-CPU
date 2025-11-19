LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY ONE_BIT_REG IS 
    PORT(
        D      : IN  STD_LOGIC;       -- Entrada de 1 bit
        R_in   : IN  STD_LOGIC;       -- Sinal de controle para escrita
        Reset  : IN  STD_LOGIC;       -- Sinal de reset
        Clock  : IN  STD_LOGIC;       -- Sinal de clock
        D_out  : OUT STD_LOGIC        -- Saída de 1 bit
    );
END ONE_BIT_REG;

ARCHITECTURE Behavior OF ONE_BIT_REG IS
BEGIN
    PROCESS (Reset, Clock, R_in)
    BEGIN
        IF Reset = '1' THEN
            D_out <= '0';  -- Em caso de RESET, a saída será 0

        ELSIF (Clock'EVENT AND Clock = '0') THEN
            IF (R_in = '1') THEN
                D_out <= D;   -- Caso o sinal de controle R_in seja 1, armazena o valor de D na saída
            END IF;
        END IF;
    END PROCESS;
END Behavior;