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
		hex7 : OUT STD_LOGIC_VECTOR(0 TO 6);
		
		LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);		-- Sinais de saída para os LEDS da placa
		LEDG: OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		
		LCD_DATA : out STD_LOGIC_VECTOR(7 DOWNTO 0); -- Sinais para manipulação do display LCD da placa
		LCD_RW : OUT STD_LOGIC;
		LCD_EN : OUT STD_LOGIC;
		LCD_RS: OUT STD_LOGIC
	);
END CPU;

ARCHITECTURE Behavior OF CPU IS

-- Definição dos sinais auxiliares
SIGNAL INSTRUCTION : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATA, DATA_READ1,DATA_READ2,ULA_RESULT,A,B,READ_DATA1,READ_DATA2,WRITE_DATA : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Done, RESET,stop,SWAP: STD_LOGIC;
SIGNAL OP_ULA : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL ZERO, OVERFLOW, COUT,EQU,GRT,LST,En  : STD_LOGIC;
SIGNAL ZERO_AUX, OVERFLOW_AUX, COUT_AUX,EQU_AUX,GRT_AUX,LST_AUX,REG_READ,REG_WRITE : STD_LOGIC;

SIGNAL LCD_DATA_AUX: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL LCD_EN_AUX, LCD_RS_AUX, LCD_RW_AUX :STD_LOGIC;
SIGNAL OPCODE : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL WRITE_REG, EXTERN : STD_LOGIC_VECTOR(1 DOWNTO 0);

CONSTANT max: INTEGER := 500000;				-- Ciclo do clock (é ajustável)
CONSTANT half: INTEGER := max/2;				-- Meio Ciclo
SIGNAL clockticks: INTEGER RANGE 0 TO max;-- Conta cada ciclo do clock de entrada
SIGNAL clock: STD_LOGIC;						-- Clock instanciado


BEGIN

-- Atribuição da pinagem aos sinais 
INSTRUCTION <= SW(17 DOWNTO 10);
DATA <= SW(3 DOWNTO 0);
OPCODE<= INSTRUCTION(7 DOWNTO 4);

RESET <= NOT KEY(0);
En <= NOT KEY(3);
LEDR(17 DOWNTO 10) <= NOT INSTRUCTION;
LEDR(3 DOWNTO 0) <= NOT DATA;

LEDG(0) <= ZERO;
LEDG(1) <= OVERFLOW;
LEDG(2) <= COUT;

LEDG(7) <= EQU;
LEDG(6) <= GRT;
LEDG(5) <= LST;
LEDG(8) <= DONE;

WITH EN SELECT
EQU <= 	EQU_AUX WHEN '1',
			'0' WHEN OTHERS;

WITH EN SELECT
GRT <= 	GRT_AUX WHEN '1',
			'0' WHEN OTHERS;
			
WITH EN SELECT
LST <= 	LST_AUX WHEN '1',
			'0' WHEN OTHERS;
			
WITH EN SELECT
ZERO <= 	ZERO_AUX WHEN '1',
			'0' WHEN OTHERS;
			
WITH EN SELECT
OVERFLOW <= OVERFLOW_AUX WHEN '1',
			'0' WHEN OTHERS;
			
WITH EN SELECT
COUT <= 	COUT_AUX WHEN '1',
			'0' WHEN OTHERS;

WITH SWAP SELECT
WRITE_REG <= 	INSTRUCTION(1 DOWNTO 0) WHEN '1',
					INSTRUCTION(3 DOWNTO 2) WHEN '0';

WITH Extern SELECT
WRITE_DATA <= 	DATA WHEN "01",
					ULA_RESULT WHEN "00",
					B WHEN "10",
					"0000" WHEN OTHERS;

LCD_DATA <= LCD_DATA_AUX;
LCD_EN <= 	LCD_EN_AUX;
LCD_RW <= 	LCD_RW_AUX;
LCD_RS <= 	LCD_RS_AUX;

-- Instancia da Unidade de Controle com a máquina de estados responsável pela gerência dos Registradores
UC_INSTANCE: UC_CPU PORT MAP(
	INSTRUCTION(7 DOWNTO 5),
	CLOCK,
	RESET,
	En,
	REG_READ,
	REG_WRITE,
	SWAP,
	Done,
	Extern
	);

-- Intancia da Unidade Lógica Aritmética
ULA_INSTANCE: ULA PORT MAP(
	A,
	B,
	INSTRUCTION(7 DOWNTO 5),
	ZERO_AUX,
	OVERFLOW_AUX,
	COUT_AUX,
	ULA_RESULT,
	EQU_AUX,
	GRT_AUX,
	LST_AUX
	);

-- Intancia da máquina de estados responsável por gerir o display LCD
UC_LCD_INSTANCE: UC_LCD PORT MAP(
	INSTRUCTION,
	CLOCK,
	EQU,GRT,LST,EN,
	LCD_DATA_AUX,
	LCD_RW_AUX,
	LCD_EN_AUX,
	LCD_RS_AUX
	);
	
REG_BANK_INSTANCE: REG_BANK PORT MAP(
	INSTRUCTION(3 DOWNTO 2),
	INSTRUCTION(1 DOWNTO 0),
	WRITE_REG,
	WRITE_DATA,
	DATA_READ1,
	DATA_READ2
	);



-- Definição dos Registradores de propósito específico A,B e G
REG_A_INSTANCE: REG PORT MAP(DATA_READ1,REG_READ,RESET,CLOCK,A);
REG_B_INSTANCE: REG PORT MAP(DATA_READ2,REG_READ,RESET,CLOCK,B);


-- Definição dos displays de 7 segmentos para mostrar os dados dos registradores 
DISPLAY_R1: SEGS_4_TRANSLATOR PORT MAP(BUFF0_DATA_IN,HEX2);
DISPLAY_R2: SEGS_4_TRANSLATOR PORT MAP(BUFF1_DATA_IN,HEX1);
DISPLAY_R3: SEGS_4_TRANSLATOR PORT MAP(BUFF2_DATA_IN,HEX0);
--DISPLAY_A: SEGS_4_TRANSLATOR PORT MAP(A_DATA_OUT,HEX5);
--DISPLAY_B: SEGS_4_TRANSLATOR PORT MAP(B_DATA_OUT,HEX4);
--DISPLAY_G: SEGS_4_TRANSLATOR PORT MAP(BUFFG_DATA_IN,HEX7);
DISPLAY_DATA: SEGS_4_TRANSLATOR PORT MAP(DATA,HEX4);
DISPLAY_INSTRUCTION: SEGS_4_TRANSLATOR PORT MAP(OPCODE,HEX7);




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
