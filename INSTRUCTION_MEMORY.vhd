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
	SIGNAL DATA : STD_LOGIC_VECTOR(15 DOWNTO 0);
    type mem_array is array(0 to (INSTRUCT_QTD*2) - 1) of std_logic_vector(BYTE_SIZE-1 downto 0);
	 -- DE ACORDO COM OS TESTES, O BRANCH VAI PRECISAR DE >>TRÊS<< (3) NOPS!!!!!
    signal mem : mem_array := ("00000000",
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
										"00100101",
										"11000000",
										"01000110",
										"11000000",
										"01100111",
										"11000000",
										"10011111",
										"11000000",
										"10110001",
										"11000000",
										"10001100",
										"01101010",
										"11000010",
										"01100010",
										"11000100",
										"01100100",
										"11000110",
										"01100110",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"00000000",
										"11100010",
										"00000000",
										"11100100",
										"00000000",
										"11100110");

begin

--	DATA_OUT(7 downto 0)  <= mem(to_integer(unsigned(ADDRESS)));
--	DATA_OUT(15 downto 8) <= mem(to_integer(unsigned(ADDRESS)) + 1);

	BUFFER_INSTANCE: BUFFER_TRI PORT MAP (DATA, READ_MEM ,DATA_OUT);

    process(ADDRESS,READ_MEM,mem)
	 BEGIN
--        if rising_edge(CLOCK) then

            if READ_MEM = '1' then
					DATA(7 downto 0)  <= mem(to_integer(unsigned(ADDRESS)));
					DATA(15 downto 8) <= mem(to_integer(unsigned(ADDRESS)) + 1);
            end if;
--        end if;
    end process;
--    process(ADDRESS, DATA_IN, WRITE_MEM)
--	 BEGIN
----        if rising_edge(CLOCK) then
--
--            if WRITE_MEM = '1' then
--                mem(to_integer(unsigned(ADDRESS)))     <= DATA_IN(7 downto 0);
--                mem(to_integer(unsigned(ADDRESS)) + 1) <= DATA_IN(15 downto 8);
--            end if;
----        end if;
--    end process;

end Behavioral;




-- GABARITO:
--("00000000", 
--"00000000",
--"00100001", 
--"11000000",
--"01000010", 
--"11000000",
--"01100000", 
--"11000000",
--"10000001", 
--"11000000",
--"10100100", 
--"11000000",
--"11000000", 
--"11000000",
--"10100100", 
--"10001000",
--"10000000", 
--"01001100",
--"01001100", 
--"01101100",
--"00101000", 
--"01101000",
--"00000111", 
--"10100000",
--"10100011", 
--"11000000",
--"11000000", 
--"11000000",
--"10000000", 
--"11000000",
--"10100100", 
--"10001000",
--"01001100", 
--"01101100",
--"00101000", 
--"01101000",
--"01100000",
--"00101100",
--"00001111", 
--"10100000",
--"00101111",
--"11000000",
--"01001111", 
--"11000000",
--"01101111", 
--"11000000",
--"10001111", 
--"11000000",
--"10101111", 
--"11000000",
--"11001111",
--"11000000");


-- LCD TEST
--("00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00100101",
--"11000000",
--"01000110",
--"11000000",
--"01100111",
--"11000000",
--"10011111",
--"11000000",
--"10010001",
--"11000000",
--"10001100",
--"01101010",
--"11000010",
--"01100010",
--"11000100",
--"01100100",
--"11000110",
--"01100110",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"00000000",
--"11100010",
--"00000000",
--"11100100",
--"00000000",
--"11100110");
