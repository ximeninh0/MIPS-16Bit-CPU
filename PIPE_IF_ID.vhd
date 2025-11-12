LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PIPE_IF_ID IS 
    port(
        -- Inputs
        NEXT_PC_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        INSTRUCTION_DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IF_ID_WRITE : IN STD_LOGIC;

        -- Outputs
        NEXT_PC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        INSTRUCTION_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        -- Sinais de controle de hazard
        IF_FLUSH : IN STD_LOGIC;

        -- Controle de clock e reset
        CLOCK : IN STD_LOGIC;
        RESET : IN STD_LOGIC
    );
END PIPE_IF_ID;

SIGNAL RESET_SIG : STD_LOGIC;

ARCHITECTURE Behavior OF PIPE_IF_ID IS

    -- Caso tenha um reset forçado ou um flush, o registrador deve ser resetado
    RESET_SIG <= RESET OR IF_FLUSH;

    -- Instanciação dos registradores do estágio IF/ID
    PC_INSTANCE: REG PORT MAP(NEXT_PC_IN,IF_ID_WRITE,RESET_SIG,CLOCK,NEXT_PC_OUT);
	INSTRUCTION_DATA: REG PORT MAP(INSTRUCTION_DATA_IN,IF_ID_WRITE,RESET_SIG,CLOCK,INSTRUCTION_DATA_OUT);

BEGIN
END Behavior;
