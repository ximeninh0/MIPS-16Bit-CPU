library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CONSTANTS_PACKAGE.all;
use work.CPU_PACKAGE.all;

entity MEMORY is
    port (
        ADDRESS  : in  std_logic_vector(15 downto 0);
        DATA_IN  : in  std_logic_vector(WORD_SIZE-1 downto 0);
        DATA_OUT : out std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
        READ_MEM : in  std_logic;
        WRITE_MEM: in  std_logic;
        CLOCK    : in  std_logic
    );
end MEMORY;

architecture Behavioral of MEMORY is

    type mem_array is array(0 to ((2**ADDR_SIZE)-1)) of std_logic_vector(BYTE_SIZE-1 downto 0);
    signal mem : mem_array :=  (OTHERS=>(OTHERS => '0'));
	 signal data_out_aux : std_logic_vector(15 downto 0);

begin

    process(CLOCK)
    begin
        if rising_edge(CLOCK) then
            if WRITE_MEM = '1' then
                mem(to_integer(unsigned(ADDRESS)))     <= DATA_IN(7 downto 0);
                mem(to_integer(unsigned(ADDRESS)) + 1) <= DATA_IN(15 downto 8);
            end if;
        end if;
		 
		 data_out_aux(7 downto 0)  <= mem(to_integer(unsigned(ADDRESS)));
		 data_out_aux(15 downto 8) <= mem(to_integer(unsigned(ADDRESS)) + 1);
    end process;
	 
	 BUFFER1_INSTANCE: BUFFER_TRI PORT MAP(data_out_aux,READ_MEM,DATA_OUT);

end Behavioral;
