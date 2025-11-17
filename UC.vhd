LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY UC IS 
port(
	SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
	Clock_50 : in std_logic;
	HEX0,HEX1,HEX2 : OUT STD_LOGIC_VECTOR(0 TO 6);
	HEX4,HEX5 : OUT STD_LOGIC_VECTOR(0 TO 6);
	HEX6 : OUT STD_LOGIC_VECTOR(0 TO 6);
	LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
	LEDG : OUT STD_LOGIC_VECTOR(0 TO 5);
   LCD_DATA : out STD_LOGIC_VECTOR(7 DOWNTO 0);
   LCD_RW : OUT STD_LOGIC;
   LCD_EN : OUT STD_LOGIC;
   LCD_RS: OUT STD_LOGIC

	);
END UC;

ARCHITECTURE Behavior OF UC IS

SIGNAL OP : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL RES_RESULT,RES_RESULT_INV1,RES_RESULT_INV2,RESULT,A,B,y,TRANSLATE_SIGNAL : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL EQU,GRT,LST,OV,COUT,OVERFLOW : STD_LOGIC;



TYPE state_type IS (IDLE_CLEAR1,IDLE_CLEAR2,IDLE,SOMA_MSG,SOMA_MSG_EN,SOMA_MSG_TR,SUB_MSG,SUB_MSG_EN,SUB_MSG_TR,
							AND_MSG,AND_MSG_EN,AND_MSG_TR,OR_MSG,OR_MSG_EN,OR_MSG_TR, MUL_MSG, MUL_MSG_EN, MUL_MSG_TR,
							NOT_MSG,NOT_MSG_EN,NOT_MSG_TR,MENU_MSG,MENU_MSG_EN, MENU_MSG_TR,COMP_MSG,COMP_MSG_EN,COMP_MSG_TR); 
							
							--Todos estados utilizados
SIGNAL ESTADO : State_type := IDLE_CLEAR1; -- Sinal estado (começa em IDLE_CLEAR1)

CONSTANT max: INTEGER := 500000;			-- Ciclo do clock (é ajustável)
CONSTANT half: INTEGER := max/2;				-- Meio Ciclo
SIGNAL clockticks: INTEGER RANGE 0 TO max;-- Conta cada ciclo do clock de entrada
SIGNAL clock: STD_LOGIC;						-- Clock instanciado


SUBTYPE ascii IS STD_LOGIC_VECTOR(7 DOWNTO 0);	-- Este subtipo representa cada código inserido num array que será varrido pelo contador
TYPE CadeiaCaract IS array (1 TO 16) OF ascii;	-- Sequencia para impressao de uma linha do Display
TYPE init IS ARRAY (1 TO 4) OF ascii;				-- Códigos de iniciação no display
CONSTANT CDG_iniciacao : init:= (x"06",x"0F",x"38",x"01");		-- Códigos de instruções iniciais da placa (CONSULTAR TABELA 6)
CONSTANT Linha_SOMA : CadeiaCaract := (x"20",x"20",x"20",x"20",x"20",x"53",x"4F",x"4D",x"41",x"20",x"20",x"20",x"20",x"20",x"20",x"20"); --Inserção de caracteres na primeira linha (array que contém o caractere de cada espaço da primeira linha)
CONSTANT Linha_SUB : CadeiaCaract := (x"20",x"20",x"20",x"20",x"53",x"55",x"42",x"54",x"52",x"41",x"43",x"41",x"4F",x"20",x"20",x"20"); --Inserção de caracteres na primeira linha (array que contém o caractere de cada espaço da primeira linha)
CONSTANT Linha_COMP : CadeiaCaract := (x"20",x"20",x"20",x"20",x"43",x"4F",x"4D",x"50",x"41",x"52",x"41",x"43",x"41",x"4F",x"20",x"20"); --Inserção de caracteres na primeira linha (array que contém o caractere de cada espaço da primeira linha)
CONSTANT Linha_OR : CadeiaCaract := (x"20",x"20",x"20",x"20",x"20",x"41",x"20",x"4F",x"52",x"20",x"42",x"20",x"20",x"20",x"20",x"20"); --Inserção de caracteres na primeira linha (array que contém o caractere de cada espaço da primeira linha)
CONSTANT Linha_AND : CadeiaCaract := (x"20",x"20",x"20",x"20",x"20",x"41",x"20",x"41",x"4E",x"44",x"20",x"42",x"20",x"20",x"20",x"20"); --Inserção de caracteres na primeira linha (array que contém o caractere de cada espaço da primeira linha)
CONSTANT Linha_NOP : CadeiaCaract := (x"20",x"20",x"20",x"20",x"20",x"20",x"4E",x"4F",x"50",x"21",x"20",x"20",x"20",x"20",x"20",x"20"); --Inserção de caracteres na primeira linha (array que contém o caractere de cada espaço da primeira linha)
CONSTANT Linha_MENU : CadeiaCaract := (x"42", x"45", x"4D", x"2D", x"56", x"49", x"4E", x"44",x"4F", x"20", x"41", x"20", x"55", x"4C", x"41", x"20");
CONSTANT Linha_NOT : CadeiaCaract := (x"20",x"20",x"20",x"20",x"20",x"41",x"20",x"4E",x"4F",x"54",x"20",x"42",x"20",x"20",x"20",x"20"); --Inserção de caracteres na primeira linha (array que contém o caractere de cada espaço da primeira linha)
CONSTANT Linha_MULT : CadeiaCaract := (x"20", x"4D", x"55", x"4C", x"54", x"49", x"50", x"4C", x"49", x"43", x"41", x"43", x"41", x"4F", x"20", x"20");

SIGNAL conteiro: INTEGER:=1;							-- Contador que varre as instruções que vâo para o LCD_DATA


BEGIN

	A <= SW(13 DOWNTO 10);
	OP <= SW(17 DOWNTO 15);
	B <= SW(8 DOWNTO 5);
	
	TRANSLATE_SIGNAL <= LST & OP;

	LEDR(13 DOWNTO 10) <= NOT A;
	LEDR(8 DOWNTO 5)<= NOT B;
	LEDR(17 DOWNTO 15) <= NOT OP;
	LEDG(2) <= OVERFLOW;
	
	ULA_INSTANCE: ULA PORT MAP(
	A, 
	B,
	OP,
	LEDG(1),
	OVERFLOW,
	LEDG(0),
	RESULT,
	LEDG(3),
	LEDG(4),
	LEDG(5)
	);

	DISPLAY_ALUOP: SEGS_3_TRANSLATOR PORT MAP(OP,HEX6);
	DISPLAY_A: SEGS_4_TRANSLATOR PORT MAP(A,HEX5);
	DISPLAY_B: SEGS_4_TRANSLATOR PORT MAP(B,HEX4);

	SUM_INSTANCE: RIPPLE_CARRY PORT MAP("1111", RESULT,'1','1',OV,COUT,RES_RESULT_INV1);
	SUM_INSTANCE2: RIPPLE_CARRY PORT MAP(RES_RESULT_INV1, "0001",'0','0',OV,COUT,RES_RESULT_INV2);
	COMPARATOR_TRANSLATE_INSTANCE: COMPARATOR PORT MAP(A,B,EQU,GRT,LST);


	WITH TRANSLATE_SIGNAL SELECT 
	RES_RESULT <=  RES_RESULT_INV2 WHEN "1101",
						RESULT WHEN OTHERS;

						
	WITH TRANSLATE_SIGNAL SELECT
	 HEX2 <=   "1111110" when "1101", --0
				  "1111111" when others; --apagado
				  
	WITH RES_RESULT SELECT
	 HEX1 <=   "1001111" when "1010", --0
				  "1001111" when "1011", --1
				  "1001111" when "1100", --2
				  "1001111" when "1101", --3
				  "1001111" when "1110", --4
				  
				  "1001111" when "1111", --5
				  "0000001" when others; --apagado

	WITH RES_RESULT SELECT
	 HEX0 <= "0000001" when "0000", --0
				  "1001111" when "0001", --1
				  "0010010" when "0010", --2
				  "0000110" when "0011", --3
				  "1001100" when "0100", --4
				  "0100100" when "0101", --5
				  "0100000" when "0110", --6
				  "0001111" when "0111", --7
				  "0000000" when "1000", --8
				  "0000100" when "1001", --9
				  "0000001" when "1010", --0
				  "1001111" when "1011", --1
				  "0010010" when "1100", --2
				  "0000110" when "1101", --3
				  "1001100" when "1110", --4
				  "0100100" when "1111", --5
				  "1111111" when others; --apagado
				  
				  
				  
				  
				  
				  
PROCESS (clock)
BEGIN

	IF (clock'EVENT AND clock = '1') THEN
	CASE ESTADO IS
	
		-- ESTADOS IDLE CLEAR RODAM OS COMANDOS DE INICIALIZAÇÃO DO DISPLAY
		WHEN IDLE_CLEAR1 =>
		ESTADO <= IDLE_CLEAR2;
		
		WHEN IDLE_CLEAR2 =>
		conteiro <= conteiro + 1;
		IF conteiro < 4 THEN ESTADO <= IDLE_CLEAR1;
		ELSE ESTADO <= IDLE;
		END IF;
		
		-- ESTADO IDLE É UMA REFERÊNCIA DE "MENU"
		WHEN IDLE =>
		conteiro <= 1;
		IF OP = "000" THEN    ESTADO <= MENU_MSG;--
		ELSIF OP = "001" THEN ESTADO <= AND_MSG;--
		ELSIF OP = "010" THEN ESTADO <= OR_MSG;--
		ELSIF OP = "011" THEN ESTADO <= NOT_MSG;--
		ELSIF OP = "100" THEN ESTADO <= SOMA_MSG;--
		ELSIF OP = "101" THEN ESTADO <= SUB_MSG;--
		ELSIF OP = "110" THEN ESTADO <= MUL_MSG;--
		ELSIF OP = "111" THEN ESTADO <= COMP_MSG;--
		ELSE ESTADO <= IDLE;
		END IF;
		
		
		
		WHEN MENU_MSG =>
		ESTADO <= MENU_MSG_EN;
		
		WHEN MENU_MSG_EN =>
		conteiro <= conteiro + 1;
		IF conteiro < 16 THEN ESTADO <= MENU_MSG;
		ELSE ESTADO <= MENU_MSG_TR;
		END IF;
		
		
		WHEN MENU_MSG_TR =>
		conteiro <= 0;
		IF OP = "000" THEN ESTADO <= MENU_MSG_TR;
		ELSE ESTADO <= IDLE_CLEAR1;
		END IF;
		
		
		
		WHEN SOMA_MSG =>
		ESTADO <= SOMA_MSG_EN;
		
		WHEN SOMA_MSG_EN =>
		conteiro <= conteiro + 1;
		IF conteiro < 16 THEN ESTADO <= SOMA_MSG;
		ELSE ESTADO <= SOMA_MSG_TR;
		END IF;
		
		
		WHEN SOMA_MSG_TR =>
		conteiro <= 0;
		IF OP = "100" THEN ESTADO <= SOMA_MSG_TR;
		ELSE ESTADO <= IDLE_CLEAR1;
		END IF;
		
		
		
		WHEN SUB_MSG =>
		ESTADO <= SUB_MSG_EN;
		
		WHEN SUB_MSG_EN =>
		conteiro <= conteiro + 1;
		IF conteiro < 16 THEN ESTADO <= SUB_MSG;
		ELSE ESTADO <= SUB_MSG_TR;
		END IF;
		
		
		WHEN SUB_MSG_TR =>
		conteiro <= 0;
		IF OP = "101" THEN ESTADO <= SUB_MSG_TR;
		ELSE ESTADO <= IDLE_CLEAR1;
		END IF;
		
		
		
		WHEN MUL_MSG =>
		ESTADO <= MUL_MSG_EN;
		
		WHEN MUL_MSG_EN =>
		conteiro <= conteiro + 1;
		IF conteiro < 16 THEN ESTADO <= MUL_MSG;
		ELSE ESTADO <= MUL_MSG_TR;
		END IF;
		
		
		WHEN MUL_MSG_TR =>
		conteiro <= 0;
		IF OP = "110" THEN ESTADO <= MUL_MSG_TR;
		ELSE ESTADO <= IDLE_CLEAR1;
		END IF;
		
		
		
		WHEN AND_MSG =>
		ESTADO <= AND_MSG_EN;
		
		WHEN AND_MSG_EN =>
		conteiro <= conteiro + 1;
		IF conteiro < 16 THEN ESTADO <= AND_MSG;
		ELSE ESTADO <= AND_MSG_TR;
		END IF;
		
		
		WHEN AND_MSG_TR =>
		conteiro <= 0;
		IF OP = "001" THEN ESTADO <= AND_MSG_TR;
		ELSE ESTADO <= IDLE_CLEAR1;
		END IF;
		
		
		
		
		WHEN OR_MSG =>
		ESTADO <= OR_MSG_EN;
		
		WHEN OR_MSG_EN =>
		conteiro <= conteiro + 1;
		IF conteiro < 16 THEN ESTADO <= OR_MSG;
		ELSE ESTADO <= OR_MSG_TR;
		END IF;
		
		
		WHEN OR_MSG_TR =>
		conteiro <= 0;
		IF OP = "010" THEN ESTADO <= OR_MSG_TR;
		ELSE ESTADO <= IDLE_CLEAR1;
		END IF;
		
		
		
		
		WHEN NOT_MSG =>
		ESTADO <= NOT_MSG_EN;
		
		WHEN NOT_MSG_EN =>
		conteiro <= conteiro + 1;
		IF conteiro < 16 THEN ESTADO <= NOT_MSG;
		ELSE ESTADO <= NOT_MSG_TR;
		END IF;
		
		
		WHEN NOT_MSG_TR =>
		conteiro <= 0;
		IF OP = "011" THEN ESTADO <= NOT_MSG_TR;
		ELSE ESTADO <= IDLE_CLEAR1;
		END IF;
		
		
		
		WHEN COMP_MSG =>
		ESTADO <= COMP_MSG_EN;
		
		WHEN COMP_MSG_EN =>
		conteiro <= conteiro + 1;
		IF conteiro < 16 THEN ESTADO <= COMP_MSG;
		ELSE ESTADO <= COMP_MSG_TR;
		END IF;
		
		
		WHEN COMP_MSG_TR =>
		conteiro <= 0;
		IF OP = "111" THEN ESTADO <= COMP_MSG_TR;
		ELSE ESTADO <= IDLE_CLEAR1;
		END IF;
		
		END CASE;
	END IF;
END PROCESS;

PROCESS (ESTADO)
BEGIN
	CASE ESTADO IS
		WHEN IDLE_CLEAR1 =>
				LCD_DATA <= CDG_iniciacao(conteiro);
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '0';
				
		WHEN IDLE_CLEAR2 =>
				LCD_EN <= '0';
				LCD_RW <= '0';
				LCD_RS <= '0';
			
		WHEN IDLE =>
				LCD_EN <= '0';
				LCD_RW <= '0';
				LCD_RS <= '0';
			
			
		WHEN SOMA_MSG =>
				LCD_DATA <= Linha_SOMA(conteiro);
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN SOMA_MSG_EN =>
				LCD_EN <= '0'; 
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN SUB_MSG =>
				LCD_DATA <= Linha_SUB(conteiro);
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN SUB_MSG_EN =>
				LCD_EN <= '0'; 
				LCD_RW <= '0';
				LCD_RS <= '1';

		WHEN AND_MSG =>
				LCD_DATA <= Linha_AND(conteiro);
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN AND_MSG_EN =>
				LCD_EN <= '0'; 
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN NOT_MSG =>
				LCD_DATA <= Linha_NOT(conteiro);
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN NOT_MSG_EN =>
				LCD_EN <= '0'; 
				LCD_RW <= '0';
				LCD_RS <= '1';

				
		WHEN OR_MSG =>
				LCD_DATA <= Linha_OR(conteiro);
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN OR_MSG_EN =>
				LCD_EN <= '0'; 
				LCD_RW <= '0';
				LCD_RS <= '1';
				
				
		WHEN COMP_MSG =>
				LCD_DATA <= Linha_COMP(conteiro);
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN COMP_MSG_EN =>
				LCD_EN <= '0'; 
				LCD_RW <= '0';
				LCD_RS <= '1';

				
		WHEN MUL_MSG =>
				LCD_DATA <= Linha_MULT(conteiro);
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN MUL_MSG_EN =>
				LCD_EN <= '0'; 
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN MENU_MSG =>
				LCD_DATA <= Linha_MENU(conteiro);
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN MENU_MSG_EN =>
				LCD_EN <= '0'; 
				LCD_RW <= '0';
				LCD_RS <= '1';
		WHEN OTHERS =>
			NULL;

			END CASE;
END PROCESS;


			-- PROCESSOS PARA O DIVISOR DE CLOCK
    ClockDivide: PROCESS
            BEGIN
            WAIT UNTIL CLOCK_50'EVENT and CLOCK_50 = '1';
            IF clockticks < max THEN
                clockticks <= clockticks + 1;
            ELSE
                clockticks <= 0;
            END IF;
            IF clockticks < half THEN
                clock <= '0';
            ELSE
                clock <= '1';
            END IF;
        END PROCESS;
END Behavior;