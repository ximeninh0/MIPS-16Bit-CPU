library ieee;
use ieee.std_logic_1164.all;
USE ieee.STD_LOGIC_unsigned.ALL;

entity UC_LCD is
  port(
	 --Nas entradas ficam todos os sinais que serão observados pela Unidade de controle do display LCD
	 RS_DATA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);	
	 WRITE_SIGNAL : STD_LOGIC;
	 CLOCK : IN STD_LOGIC;
	 CLOCK_CPU: IN STD_LOGIC;
	 
	 -- Nas saídas ficam os sinais de manipulação que controlam o fluxo de dados para o display
	 LCD_DATA : out STD_LOGIC_VECTOR(7 DOWNTO 0); 	-- Palavra de 8-bits para comunicação com o LCD
	 LCD_RW : OUT STD_LOGIC;								-- Sinal para indicar se é leitura ou escrita
	 LCD_EN : OUT STD_LOGIC;								-- Sinal de enable que envia o pulso de comunicação
	 LCD_RS: OUT STD_LOGIC									-- Sinal que indica se é dado ou comando
  );
end UC_LCD;

architecture bhv of UC_LCD is

-- Definição de todos os 548 estados da unidade de controle do display LCD
TYPE state_type IS (IDLE_CLEAR1,IDLE_CLEAR2,IDLE,WRITE_RS,WRITE_RS_EN,ESTADO_TRAVA

); 
SIGNAL ESTADO : State_type := IDLE_CLEAR1; -- Sinal estado (começa em IDLE_CLEAR1)


SUBTYPE ascii IS STD_LOGIC_VECTOR(7 DOWNTO 0);	-- Este subtipo serve para melhorar a identação dentro dos arrays de mensagens
TYPE CadeiaCaract IS array (1 TO 16) OF ascii;	-- Tipo de array para guardar linha
TYPE init IS ARRAY (1 TO 4) OF ascii;				-- Códigos de iniciação no display

CONSTANT CDG_iniciacao : init:= (x"06",x"0C",x"38",x"01");		-- Códigos de instruções iniciais da placa (CONSULTAR TABELA 6)

-- Vetor para guardar cada linha que será exibida pelo LCD
CONSTANT Linha_SOMA : CadeiaCaract := (x"20",x"20",x"20",x"20",x"20",x"20",x"53",x"4F",x"4D",x"41",x"20",x"20",x"20",x"20",x"20",x"20"); --Inserção de caracteres na primeira linha (array que contém o caractere de cada espaço da primeira linha)

SIGNAL TRAVA : STD_LOGIC:='0';
SIGNAL REG_DATA,OP :STD_LOGIC_VECTOR(3 DOWNTO 0);	-- Sinais auxiliares para melhorar identação
SIGNAL conteiro: INTEGER:=0;								-- Contador que varre as instruções que vâo para o LCD_DATA
signal aux : std_logic;
BEGIN


PROCESS (clock, CLOCK_CPU)
BEGIN
IF (CLOCK_CPU'EVENT AND CLOCK_CPU = '0') THEN aux <= '1';
ELSE aux <= '0';
END IF;

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
		
		-- ESTADO IDLE É UMA REFERÊNCIA DE "MENU", nele decidimos qual opcde leva a qual mensagem
		WHEN IDLE =>
			conteiro <= 1;
			IF WRITE_SIGNAL = '1' AND CLOCK_CPU = '1' THEN ESTADO <= WRITE_RS;--
			ELSIF WRITE_SIGNAL = '0' THEN ESTADO <= IDLE;

			ELSE ESTADO <= IDLE;
		END IF;
		
		WHEN WRITE_RS =>
		ESTADO<= WRITE_RS_EN;
		
		WHEN WRITE_RS_EN =>
		IF CLOCK_CPU = '0' THEN ESTADO<= IDLE;
		ELSE ESTADO <= WRITE_RS_EN;
		END IF;
		
		WHEN ESTADO_TRAVA =>
		ESTADO<= IDLE;
		

		WHEN OTHERS=>
		NULL;
		END CASE;
	END IF;
END PROCESS;

-- O case abaixo é responsável por realizar a manipulação dos sinais referentes em cada estado
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
				
		WHEN WRITE_RS =>
				LCD_DATA <= RS_DATA;
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN WRITE_RS_EN =>
				LCD_EN <= '0';
				LCD_RW <= '0';
				LCD_RS <= '1';
				
		WHEN ESTADO_TRAVA =>
				LCD_DATA <= RS_DATA;
				LCD_EN <= '1';
				LCD_RW <= '0';
				LCD_RS <= '1';

			END CASE;
END PROCESS;



END bhv;