library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CONSTANTS_PACKAGE.all;
use work.CPU_PACKAGE.all;

entity MEMORY is
    port (
        ADDRESS  : in  std_logic_vector(ADDR_SIZE-1 downto 0);
        DATA_IN  : in  std_logic_vector(WORD_SIZE-1 downto 0);
        DATA_OUT : out std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
        READ_MEM : in  std_logic;
        WRITE_MEM: in  std_logic;
        CLOCK    : in  std_logic
    );
end MEMORY;

architecture Behavioral of MEMORY is

    --type mem_array is array((2**ADDR_SIZE)-1 downto 0) of std_logic_vector(BYTE_SIZE-1 downto 0);;
    type mem_array is array(9 downto 0) of std_logic_vector(BYTE_SIZE-1 downto 0);
    signal mem : mem_array := ("00001010",
                                "11000000", 
                                "00101100",
                                "11000000", 
                                "00100100",
                                "01100000",
                                "01100100",
                                "11000000", 
                                "00101001",
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
