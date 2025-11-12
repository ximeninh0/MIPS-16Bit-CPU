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
SIGNAL CLOCK: STD_LOGIC;						-- Clock instanciado

SIGNAL RESET: STD_LOGIC := '0';				-- Sinal de reset geral

-- Sinais do Estagio IF
SIGNAL IF_PC, IF_PC_MUX: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL IF_PC_ADD_OVERFLOW, IF_PC_ADD_COUT 	: STD_LOGIC;
SIGNAL IF_INSTRUCTION_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL IF_PC_SOURCE : STD_LOGIC_VECTOR(1 DOWNTO 0);


-- Sinais do Estagio IF/ID
SIGNAL ID_PC : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL ID_INSTRUCTION_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL ID_RS_DATA, ID_RT_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL ID_SIGNAL_EXTENDED : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL ID_SHIFTED_SIGNAL : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL ID_NEXT_PC : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL ID_RS_EQUAL_RT : STD_LOGIC;
SIGNAL ID_ADD_OVERFLOW, ID_ADD_COUT : STD_LOGIC; -- Soma do branch
SIGNAL ID_BRANCH_PC : STD_LOGIC_VECTOR(15 DOWNTO 0);
-- Sinais da Hazard Detection Unit
SIGNAL IF_ID_WRITE : STD_LOGIC;
SIGNAL PC_WRITE : STD_LOGIC;

-- Sinais do Estagio ID/EX
SIGNAL EX_A, EX_B, EX_SIGNAL_EXT : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL EX_REG_RS, EX_REG_RT, EX_REG_RD : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL EX_NEXT_PC : STD_LOGIC_VECTOR(15 DOWNTO 0);

-- Sinais do Estagio EX/MEM

-- Sinais do Estagio MEM/WB



-- Sinais da unidade de controle
SIGNAL IF_FLUSH : STD_LOGIC;

-- Lógica dos sinais de controle:
-- Prefixo: de onde foi propagado (IN)/para onde vai ser propagado (OUT)
-- UC - ID/EX
SIGNAL ID_EX_ALU_SRC, ID_EX_REG_DST : IN STD_LOGIC; -- Sinais propagados para EX
-- Exemplo: ID_EX_ALU_SRC gerado em ID, EX_ALU_SRC propagado para EX (não necessariamente onde vai ser usado)
SIGNAL ID_EX_ALU_OP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL ID_EX_ALU_SRC, ID_EX_REG_DST : OUT STD_LOGIC;
SIGNAL ID_EX_ALU_OP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

SIGNAL ID_EX_MEM_WRITE, ID_EX_MEM_READ, ID_EX_ALU_RESULT, ID_EX_ALU_SRC2 : IN STD_LOGIC; -- Sinais propagados para MEM
SIGNAL ID_EX_MEM_WRITE, ID_EX_MEM_READ, ID_EX_MEM_ALU_RESULT, ID_EX_MEM_ALU_SRC2 : OUT STD_LOGIC;

SIGNAL ID_EX_MEM_TO_REG, ID_EX_REG_WRITE : IN STD_LOGIC; -- Sinais propagados para WB
SIGNAL ID_EX_MEM_TO_REG, ID_EX_REG_WRITE : OUT STD_LOGIC;

-- -- UC - EX/MEM
-- SIGNAL EX_MEM_WRITE, EX_MEM_READ, EX_ALU_RESULT, EX_ALU_SRC2 : IN STD_LOGIC; -- Sinais propagados para MEM
-- SIGNAL MEM_MEM_WRITE, MEM_MEM_READ, MEM_MEM_ALU_RESULT,MEM_MEM_ALU_SRC2 : OUT STD_LOGIC;

-- SIGNAL EX_MEM_TO_REG, EX_REG_WRITE : IN STD_LOGIC; -- Sinais propagados para WB
-- SIGNAL MEM_MEM_TO_REG, MEM_REG_WRITE : OUT STD_LOGIC;

-- -- UC - MEM/WB
-- SIGNAL MEM_MEM_TO_REG, MEM_REG_WRITE : IN STD_LOGIC; -- Sinais propagados para WB
-- SIGNAL WB_MEM_TO_REG, WB_REG_WRITE : OUT STD_LOGIC;


BEGIN

	-- Estagio IF
	WITH IF_PC_SOURCE SELECT
		IF_PC_MUX <= 	ID_BRANCH_PC WHEN "00", 		-- PC + offset
						IF_PC WHEN "01",				-- PC + 2
						"0000000000000000" WHEN "10", 	-- Rotina de tratamento --- Mudar para rotina de tratamento
						"0000000000000000" WHEN OTHERS; -- PC Source Inválido --- Mudar para rotina de tratamento
	
	IF_PC_INSTANCE: REG PORT MAP(IF_PC_MUX,PC_WRITE,RESET,CLOCK,IF_PC);
	IF_PC_ADD_INSTANCE: RIPPLE_CARRY PORT MAP(IF_PC,"0000000000000010",'0','0', IF_PC_ADD_OVERFLOW, IF_PC_ADD_COUT, NEXT_PC_IN);

	INSTRUCTION_MEMORY_INSTANCE: MEMORY PORT MAP(
		ADDRESS=>IF_PC
		DATA_IN=> , -- Saida de EX/MEM ---
		DATA_OUT=>IF_INSTRUCTION_DATA
		READ_MEM=>'1', -- Sempre lê
		WRITE_MEM=>'0', -- Nunca escreve
		CLOCK=>CLOCK
	);

	PIPE_IF_ID_INSTANCE: PIPE_IF_ID PORT MAP(
		-- Inputs
		NEXT_PC_IN => NEXT_PC_IN,
		INSTRUCTION_DATA_IN => IF_INSTRUCTION_DATA,
		IF_ID_WRITE => IF_ID_WRITE,

		-- Outputs
		NEXT_PC_OUT => ID_PC,
		INSTRUCTION_DATA_OUT => ID_INSTRUCTION_DATA,
		IF_FLUSH => IF_FLUSH,

		-- Controle de clock e reset
		CLOCK => CLOCK,
		RESET => RESET
	);
	
	-- Estagio IF/ID
	--- Adicionar a concatenação do JUMP aqui depois
	--- Adicionar a UC
	--- Adicionar o Hazard Unit

	IF_ID_REG_BANK_INSTANCE: REG_BANK PORT MAP(
		REG_READ1 => ID_INSTRUCTION_DATA(12 DOWNTO 9), -- RS
		REG_READ2 => ID_INSTRUCTION_DATA(8 DOWNTO 5), -- RT
		WRITE_REG => , -- MEM/WB ---
		WRITE_DATA => , -- MEM/WB ---
		REG_WRITE => , -- MEM/WB ---
		DATA_READ1 => ID_RS_DATA,
		DATA_READ2 => ID_RT_DATA,
		CLOCK => CLOCK,
		RESET => RESET
	);

	IF_ID_SIGN_EXTEND_INSTANCE: SIGN_EXTEND PORT MAP(
		IN_SIGNAL => ID_INSTRUCTION_DATA(4 DOWNTO 0),
		OUT_SIGNAL => ID_SIGNAL_EXTENDED,
	);

	IF_ID_SHIFT_LEFT_INSTANCE: SHIFT_LEFT PORT MAP(
		IN_SIGNAL => ID_SIGNAL_EXTENDED,
		OUT_SIGNAL => ID_SHIFTED_SIGNAL,
	);

	IF_ID_COMPARATOR_INSTANCE: COMPARATOR PORT MAP(
		A => ID_RS_DATA,
		B => ID_RT_DATA,
		EQU => ID_RS_EQUAL_RT,
	);

	IF_ID_RIPPLE_BRANCH_INSTANCE: RIPPLE_CARRY PORT MAP(
		A => ID_NEXT_PC,
		B => ID_SHIFTED_SIGNAL,
		CIN => '0',
		OVERFLOW => ID_ADD_OVERFLOW,
		COUT => ID_ADD_COUT,
		SUM => ID_BRANCH_PC
	);

	PIPE_ID_EX_INSTANCE: PIPE_ID_EX PORT MAP(
		-- Inputs
		A_IN=>ID_RS_DATA,
		B_IN=>ID_RT_DATA,
		SIGNAL_EXT_IN=>ID_SIGNAL_EXTENDED,
		IF_ID_REG_RS_IN=>ID_INSTRUCTION_DATA(12 DOWNTO 9),
		IF_ID_REG_RT_IN=>ID_INSTRUCTION_DATA(8 DOWNTO 5),
		IF_ID_REG_RD_IN=>ID_INSTRUCTION_DATA(4 DOWNTO 1),
		NEXT_PC_IN=>ID_PC,

		-- Outputs
		A_OUT=>EX_A,
		B_OUT=>EX_B,
		SIGNAL_EXT_OUT=>EX_SIGNAL_EXT,
		IF_ID_REG_RS_OUT=>EX_REG_RS,
		IF_ID_REG_RT_OUT=>EX_REG_RT,
		IF_ID_REG_RS_OUT=>EX_REG_RD,
		NEXT_PC_OUT=>EX_NEXT_PC,

		-- Sinais de controle EX
		EX_ALU_SRC_IN=>ID_ALU_SRC,
		EX_REG_DST_IN=>ID_REG_DST,
		EX_ALU_OP_IN=>ID_ALU_OP,
		EX_ALU_SRC_OUT=>EX_ALU_SRC,
		EX_REG_DST_OUT=>EX_REG_DST,
		EX_ALU_OP_OUT=>EX_ALU_OP,

		-- Sinais de controle MEM
		MEM_WRITE_IN=>ID_MEM_WRITE,
		MEM_READ_IN=>ID_MEM_READ,
		MEM_ALU_RESULT_IN=>ID_ALU_RESULT,
		MEM_ALU_SRC2_IN=>ID_ALU_SRC2,
		MEM_WRITE_OUT=>EX_MEM_WRITE,
		MEM_READ_OUT=>EX_MEM_READ,
		MEM_ALU_RESULT_OUT=>EX_MEM_ALU_RESULT,
		MEM_ALU_SRC2_OUT=>EX_MEM_ALU_SRC2,

		-- Sinais de controle WB
		WB_MEM_TO_REG_IN=>ID_MEM_TO_REG,
		WB_REG_WRITE_IN=>ID_REG_WRITE,
		WB_MEM_TO_REG_OUT=>EX_MEM_TO_REG,
		WB_REG_WRITE_OUT=>EX_REG_WRITE,

		CLOCK=> CLOCK
		RESET=> RESET
	);
	

	-- Estagio ID/EX

	-- Estagio EX/MEM

	-- Estagio MEM/WB

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
                CLOCK <= '0';
            ELSE
                CLOCK <= '1';
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
