library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CONSTANTS_PACKAGE.all;
use work.CPU_PACKAGE.all;

entity INSTRUCTION_MEMORY is
    port (
        ADDRESS  : in  std_logic_vector(15 downto 0);
        DATA_IN  : in  std_logic_vector(WORD_SIZE-1 downto 0);
        DATA_OUT : out std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
        READ_MEM : in  std_logic;
        WRITE_MEM: in  std_logic;
        CLOCK    : in  std_logic
    );
end INSTRUCTION_MEMORY;

architecture Behavioral of INSTRUCTION_MEMORY is

    type mem_array is array(0 to (INSTRUCT_QTD*2) - 1) of std_logic_vector(BYTE_SIZE-1 downto 0);
    signal mem : mem_array :=  ("00100100",
										"11000000", 

										"01000101",
										"11000000", 

										"01000110",
										"01100010", 
										
										"00000000",
										"00000000",
										"00000000",
										"00000000",

										"01100000",
										"01000010", 
										
										"00000000",
										"00000000",
										"00000000",
										"00000000",


										"00100111",
										"01100100", 

										"10100000",
										"00100010", 
					
										"00000000",
										"00000000",

										"10101100",
										"01100110");

begin

    process(CLOCK)
    begin
        if rising_edge(CLOCK) then
            if READ_MEM = '1' then
                DATA_OUT(7 downto 0)  <= mem(to_integer(unsigned(ADDRESS)));
                DATA_OUT(15 downto 8) <= mem(to_integer(unsigned(ADDRESS)) + 1);
            end if;

            if WRITE_MEM = '1' then
                mem(to_integer(unsigned(ADDRESS)))     <= DATA_IN(7 downto 0);
                mem(to_integer(unsigned(ADDRESS)) + 1) <= DATA_IN(15 downto 8);
            end if;
        end if;
    end process;

end Behavioral;
