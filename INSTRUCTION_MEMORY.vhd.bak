LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY INSTRUCTION_MEMORY IS 
	port(
        ADDRESS: in std_logic_vector(15 downto 0); 
        DATA_IN: in std_logic_vector(15 downto 0);
        WRITE_IN: in std_logic; 
        CLOCK: in std_logic; 
        DATA_OUT: out std_logic_vector(15 downto 0)
	);
END INSTRUCTION_MEMORY;
-- O buffer apenas permite a passagem de dados mediante a liberação do GATE
ARCHITECTURE Behavior OF INSTRUCTION_MEMORY IS
type ram_array is array (0 to 65535) of std_logic_vector (15 downto 0);
-- O tamanho é 2 ^ 16
signal ram_data: ram_array;

begin
    process(clock)
        begin
            if(rising_edge(clock)) then
                if(write_in='1') then 
                    ram_data(to_integer(unsigned(address))) <= data_in;
                end if;
            end if;
            end process;
            data_out <= ram_data(to_integer(unsigned(address)));

END Behavior;