LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY CPU IS 
	port(
		SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0); -- Sinais de entrada e CLOCK da placa
		KEY: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		Clock_50 : IN STD_LOGIC;
		
		HEX0,HEX1,HEX2 : OUT STD_LOGIC_VECTOR(0 TO 6); -- Sinais de saída para os displays de 7 segmentos
		HEX4 : OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX7 : OUT STD_LOGIC_VECTOR(0 TO 6);
		
		LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);		-- Sinais de saída para os LEDS da placa
		LEDG: OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		
		LCD_DATA : out STD_LOGIC_VECTOR(7 DOWNTO 0); -- Sinais para manipulação do display LCD da placa
		LCD_RW : OUT STD_LOGIC;
		LCD_EN : OUT STD_LOGIC;
		LCD_RS: OUT STD_LOGIC
	);
END CPU;

ARCHITECTURE Behavior OF CPU IS

CONSTANT max: INTEGER := 500000;				-- Ciclo do clock (é ajustável)
CONSTANT half: INTEGER := max/2;				-- Meio Ciclo
SIGNAL clockticks: INTEGER RANGE 0 TO max;-- Conta cada ciclo do clock de entrada
SIGNAL clock: STD_LOGIC;						-- Clock instanciado


BEGIN

	

	-- PROCESSOS PARA O DIVISOR DE CLOCK
    ClockDivide: PROCESS
            BEGIN
            WAIT UNTIL CLOCK_50'EVENT and CLOCK_50 = '1'; -- Na subida do clock,
            IF clockticks < max THEN
                clockticks <= clockticks + 1; -- Soma o contador clockticks até o máximo estipulado pelo usuário
            ELSE
                clockticks <= 0;					-- Quando chega no máximo zera
            END IF;
            IF clockticks < half THEN			-- Half representa a metade do ciclo, quando chega liga o clock
                clock <= '0';
            ELSE
                clock <= '1';
            END IF;
        END PROCESS;
		  
-- Basicamente, o ClockDivide é um processo que conta até um certo número e altera o valor do clock com base na
-- metade desse número, criando um efeito parecido com isso:
--
-- Para max = 4
-- CLK_50 - -: _|¯|_|¯|_|¯|_|¯|_|¯|_|¯|...
--	CLK- - - -: ___|¯¯¯|___|¯¯¯|___|¯¯¯|...
---          -------------t--------------
-- Com isso, quanto maior for "max", maior será o ciclo de CLK
END Behavior;
