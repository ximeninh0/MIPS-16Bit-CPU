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
SIGNAL IF_PC_SOURCE : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL IF_PC_NEXT,IF_PC_CURRENT, IF_PC_MUX,IF_INSTRUCTION : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

	-- Estágio IF
		WITH IF_PC_SOURCE SELECT
			-- Lógica para seleção do próximo PC
			IF_PC_MUX <= IF_PC_CURRENT WHEN "00", -- PC + 2
							"0000000000000000" WHEN "01", -- Tratamento de erro
							"0000000000000000" WHEN "10", -- Branch (a implementar)
							"0000000000000000" WHEN OTHERS; -- Default

		IF_PC_INSTANCE: REG PORT MAP(
			D => IF_PC_MUX,
			R_in => PC_WRITE,
			Reset => RESET,
			Clock => CLOCK,
			D_out => IF_PC
		); --OK
		IF_PC_ADD_INSTANCE: RIPPLE_CARRY PORT MAP(
			A => IF_PC,
			B => "0000000000000010",
			Cin => '0',
			Add_Sub => '0', -- Operação de soma
			Overflow => IF_PC_ADD_OVERFLOW, -- Salva o resultado do overflow (não utilizado)
			Cout => IF_PC_ADD_COUT, -- Salva o carry out (não utilizado)
			Z => IF_NEXT_PC
		); --OK

		INSTRUCTION_MEMORY_INSTANCE: MEMORY PORT MAP( --NOK
			ADDRESS=>IF_PC
			DATA_IN=> , -- Saida de EX/MEM ---
			DATA_OUT=>IF_INSTRUCTION_DATA
			READ_MEM=>'1', -- Sempre lê
			WRITE_MEM=>'0', -- Nunca escreve
			CLOCK=>CLOCK
		);

		PIPE_IF_ID_INSTANCE: PIPE_IF_ID PORT MAP( --NOK
			-- Inputs
			NEXT_PC_IN => ,
			INSTRUCTION_DATA_IN => ,
			IF_ID_WRITE => ,

			-- Outputs
			NEXT_PC_OUT => ,
			INSTRUCTION_DATA_OUT => ,
			IF_FLUSH => ,

			-- Controle de clock e reset
			CLOCK => CLOCK,
			RESET => RESET
		);

	-- Estagio IF/ID
		IF_ID_REG_BANK_INSTANCE: REG_BANK PORT MAP( --NOK
			REG_READ1 => , -- RS
			REG_READ2 => , -- RT
			WRITE_REG => , -- MEM/WB ---
			WRITE_DATA => , -- MEM/WB ---
			REG_WRITE => , -- MEM/WB ---
			DATA_READ1 => ,
			DATA_READ2 => ,
			CLOCK => CLOCK,
			RESET => RESET
		);

		IF_ID_SIGN_EXTEND_INSTANCE: SIGN_EXTEND PORT MAP( --OK
			IN_SIGNAL => ,
			OUT_SIGNAL => ,
		);

		IF_ID_SHIFT_LEFT_INSTANCE: SHIFT_LEFT PORT MAP( --OK
			IN_SIGNAL => ,
			OUT_SIGNAL => ,
		);

		IF_ID_COMPARATOR_INSTANCE: COMPARATOR PORT MAP(
			A => ,
			B => ,
			EQU => ,
		);

		IF_ID_RIPPLE_BRANCH_INSTANCE: RIPPLE_CARRY PORT MAP( --OK
			A => ,
			B => ,
			CIN => '0',
			OVERFLOW => ,
			COUT => ,
			SUM => 
		);

		PIPE_ID_EX_INSTANCE: PIPE_ID_EX PORT MAP(
			-- Inputs
			A_IN=>,
			B_IN=>,
			SIGNAL_EXT_IN=>,
			IF_ID_REG_RS_IN=>,
			IF_ID_REG_RT_IN=>,
			IF_ID_REG_RD_IN=>,
			IF_NEXT_PC=>,

			-- Outputs
			A_OUT=>,
			B_OUT=>,
			SIGNAL_EXT_OUT=>,
			IF_ID_REG_RS_OUT=>,
			IF_ID_REG_RT_OUT=>,
			IF_ID_REG_RS_OUT=>,
			NEXT_PC_OUT=>,

			-- Sinais de controle EX
			EX_ALU_SRC_IN=>,
			EX_REG_DST_IN=>,
			EX_ALU_OP_IN=>,
			EX_ALU_SRC_OUT=>,
			EX_REG_DST_OUT=>,
			EX_ALU_OP_OUT=>,

			-- Sinais de controle MEM
			MEM_WRITE_IN=>,
			MEM_READ_IN=>,
			MEM_ALU_RESULT_IN=>,
			MEM_ALU_SRC2_IN=>,
			MEM_WRITE_OUT=>,
			MEM_READ_OUT=>,
			MEM_ALU_RESULT_OUT=>,
			MEM_ALU_SRC2_OUT=>,

			-- Sinais de controle WB
			WB_MEM_TO_REG_IN=>,
			WB_REG_WRITE_IN=>,
			WB_MEM_TO_REG_OUT=>,
			WB_REG_WRITE_OUT=>,

			CLOCK=> CLOCK
			RESET=> RESET
		);

	-- Estágio ID/EX

		ALU_CONTROL_INSTANCE : ALU_CONTROL PORT MAP(
			ALU_OP => ,
			ADD_SUB => , -- ultimo bit do funct
		);

		FORWARDING_UNIT_INSTANCE : FORWARDING_UNIT PORT MAP(
			RT => ,
			REG_DST_EX_MEM => , ---
			REG_DST_MEM_WB => , ---
			WRITE_REG_EX_MEM => , ---
			WRITE_REG_MEM_WB => , ---
			FOWARD_A => ,
			FOWARD_B => 
		);

		-- WHEN FOWARD_A SELECT
		-- 	EX_ALU_INPUT_A <= EX_A WHEN "00",
		-- 						MEM_ALU_OUT_IN WHEN "10",
		-- 						WB_MEM_TO_REG WHEN "01",
		-- 						EX_A WHEN OTHERS; -- Default

		-- WHEN FOWARD_B SELECT
		-- 	EX_ALU_INPUT_B_PREMUX <= EX_B WHEN "00",
		-- 								MEM_ALU_OUT_IN WHEN "10",
		-- 								WB_MEM_TO_REG WHEN "01",
		-- 								EX_B WHEN OTHERS; -- Default

		-- WITH ALU_SRC_OUT SELECT
		-- 	EX_ALU_INPUT_B <= EX_SIGNAL_EXTENDED WHEN "1",
		-- 						EX_ALU_INPUT_B_PREMUX WHEN "0",
		-- 						EX_ALU_INPUT_B_PREMUX WHEN OTHERS; -- Default

		-- WITH REG_DST_OUT SELECT
		-- 	EX_REG_DST_MUX <= EX_RT WHEN "0",
		-- 						EX_RD WHEN "1",
		-- 						EX_RT WHEN OTHERS; -- Default

		ALU_INSTANCE : ULA PORT MAP(
			A=> ,
			B=> ,
			RESULT => ,
			OPERATION=> ,
			ZERO => ,
			OVERFLOW=> ,
			Cout => 
		);

		PIPE_EX_MEM_INSTANCE: PIPE_EX_MEM PORT MAP(
			-- Inputs
			ALU_OUT_IN=>,
			SECOND_OPERAND_IN=>,
			REG_DST_IN=>,

			-- Outputs
			ALU_OUT_OUT=> ,
			SECOND_OPERAND_OUT=> ,
			REG_DST_OUT=> ,

			-- Sinais de controle
			-- MEM
			MEM_WRITE_IN=> ,
			MEM_READ_IN=> ,
			MEM_ALU_RESULT_IN=> ,
			MEM_ALU_SRC2_IN=> ,

			MEM_WRITE_OUT=> ,
			MEM_READ_OUT=> ,
			MEM_ALU_RESULT_OUT=> ,
			MEM_ALU_SRC2_OUT=> ,

			-- WB
			WB_MEM_TO_REG_IN=> ,
			WB_REG_WRITE_IN=> ,

			WB_MEM_TO_REG_OUT=> ,
			WB_REG_WRITE_OUT=> ,

			-- Controle de clock e reset
			CLOCK=> CLOCK,;
			RESET=> RESET,
		)

	-- Estagio EX/MEM

		DATA_MEMORY_INSTANCE: MEMORY PORT MAP( --NOK
			ADDRESS=>
			DATA_IN=> ,
			DATA_OUT=>
			READ_MEM=>, 
			WRITE_MEM=>, 
			CLOCK=>CLOCK
		);

		PIPE_MEM_WB_INSTANCE : PIPE_MEM_WB PORT MAP(
			-- Inputs
			MEM_OUT_IN => ,
			ALU_RESULT_IN => ,
			REG_DST_IN => ,
			
			-- Outputs
			MEM_OUT_OUT => ,
			ALU_RESULT_OUT => ,
			REG_DST_OUT => ,

			-- Sinais de controle
			-- WB
			WB_MEM_TO_REG_IN => ,
			WB_REG_WRITE_IN => ,

			WB_MEM_TO_REG_OUT => ,
			WB_REG_WRITE_OUT => ,

			CLOCK => ,
			RESET => ,
		);

	-- Estagio MEM/WB

		-- WITH WB_MEM_TO_REG_OUT SELECT
		-- 	WB_MEM_TO_REG <= MEM_OUT_OUT WHEN '1',
		-- 						ALU_RESULT_OUT WHEN '0',
		-- 						ALU_RESULT_OUT WHEN OTHERS; -- Default

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
