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
    signal mem : mem_array := ("00100001",
										"11000000",
										"01000000",
										"11000000",
										"01100101",
										"11000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",										
										"00000000",
										"00000000",
										"01100010",
										"10000100",
										"01000100",
										"01100010",
										"00000011",
										"10100000",
										"00101111",
										"11000000",
										"01001111",
										"11000000",
										"01101111",
										"11000000");


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
