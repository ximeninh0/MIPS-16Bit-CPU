LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.CPU_PACKAGE.all;

ENTITY UC_CPU IS 
port(
	OPCODE : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Function, envia os 4 MSB para a ULA e utiliza o restante para manusear os registradores
	Clock : in std_logic;							-- Clock que dita a velocidade da troca de estados
	RESET : IN STD_LOGIC;							-- RESET para retornar para o estado inicial
	En : IN STD_LOGIC;								-- Sinal para confirmar a operação desejada
	REG_WRITE : OUT STD_LOGIC;
	REG_READ : OUT STD_LOGIC;
	SWAP : OUT STD_LOGIC;
   DONE : OUT STD_LOGIC;							-- Pisca quando termina a operação
   EXTERN : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)			-- Permite a entrada de DATA no barramento
	);
END UC_CPU;

ARCHITECTURE Behavior OF UC_CPU IS

TYPE state_type IS (IDLE,TYPE_R_READ,TYPE_R_WRITE,
						  SWAPI,SWAPII,SWAPIII,LOAD
); 
							
SIGNAL ESTADO : State_type := IDLE; -- Sinal estado (começa em IDLE)

-- Sinais auxiliares
--SIGNAL OP,REG_DATA : STD_LOGIC_VECTOR(3 DOWNTO 0);
--SIGNAL DECODER_EN,DATA_DECOD_KEY: STD_LOGIC;
--SIGNAL DECOD_KEY : STD_LOGIC_VECTOR(4 DOWNTO 0);
--SIGNAL FLAG_COMPARE: STD_LOGIC;
BEGIN

-- Separação do OPCODE do resto do function

-- Sinal que detecta operação de SWAP
--DECODER_EN <= OPERATION(0) AND OPERATION(1) AND OPERATION(2) AND OPERATION(3);

-- Sinal de entrada para o decoder do SWAP
--DECOD_KEY <= DECODER_EN & OPCODE(3 DOWNTO 0);

-- Sinal que detecta operação de compare
--FLAG_COMPARE <= OPERATION(0) AND OPERATION(1) AND OPERATION(2) AND NOT OPERATION(3);


-- Decoder que fará a unificação dos códigos de Rx | Ry no comando a fim de economizar a quantidade de estados para a operação de SWAP
--	WITH DECOD_KEY SELECT
--	 REG_DATA <= "1001" when "10110",
--					 "0111" when "11101",
--					 "1110" when "11011",
--					 OPCODE(3 DOWNTO 0) when others;
					 



PROCESS (clock,En)
BEGIN
	IF RESET = '1' THEN
		ESTADO<= IDLE;
		-- SINAL RESET PARA REINICAR UC
	ELSIF (clock'EVENT AND clock = '1') THEN

	CASE ESTADO IS
	
		-- ESTADO IDLE: É o estado inicial responsável por fazer o tratamento do LOAD e leitura de Rx
		WHEN IDLE=>
			IF OPCODE="1000" THEN
				ESTADO <= LOAD;
				
			ELSIF OPCODE="1111" THEN
				ESTADO <= SWAPI;
				
			ELSIF OPCODE="0001" AND OPCODE="0010" AND OPCODE="0011" AND OPCODE="0100" AND OPCODE="0101" AND OPCODE="0110" AND  OPCODE="0111"THEN
				ESTADO <= TYPE_R_READ;

			ELSE
				ESTADO <= IDLE;
			END IF;
		
		WHEN TYPE_R_READ =>
			IF OPCODE = "0111" THEN
				ESTADO <= IDLE;
			ELSE
				ESTADO <= TYPE_R_WRITE;
			END IF;
			
		WHEN TYPE_R_WRITE=>
			ESTADO <= IDLE;
			
		WHEN SWAPI=>
		ESTADO<= SWAPII;

		WHEN SWAPII=>
		ESTADO<= SWAPIII;
		
		WHEN SWAPIII=>
		ESTADO<= IDLE;
		
		WHEN LOAD=>
		ESTADO<= IDLE;

		WHEN OTHERS =>
		REG_WRITE <= '0';
		REG_READ <= '0';
		SWAP <= '0';
		DONE<= '0';	
		END CASE;
	END IF;
END PROCESS;


-- Case dedicado à manipulação dos sinais de cada estado
PROCESS (ESTADO,RESET)
BEGIN
	CASE ESTADO IS
	
		WHEN IDLE=>
		REG_WRITE <= '0';
		REG_READ <= '0';
		SWAP <= '0';
		DONE<= '0';
		
		WHEN TYPE_R_READ =>
		REG_READ <= '1';
		REG_WRITE <= '0';

		WHEN TYPE_R_WRITE =>
		REG_READ <= '0';
		REG_WRITE <= '1';
		Extern <= "00";
		
		WHEN SWAPI =>
		REG_READ <= '1';
		REG_WRITE <= '0';

		WHEN SWAPII =>
		REG_READ <= '0';
		REG_WRITE <= '1';
		SWAP <= '1';
		Extern <= "00";

		WHEN SWAPIII=>
		REG_READ <= '0';
		REG_WRITE <= '1';
		SWAP <= '0';
		Extern <= "10";

		WHEN LOAD=>
		REG_READ <= '0';
		REG_WRITE <= '1';
		Extern <= "01";

		WHEN OTHERS =>
		REG_WRITE <= '0';
		REG_READ <= '0';
		SWAP <= '0';
		DONE<= '0';
			END CASE;
END PROCESS;

END Behavior;