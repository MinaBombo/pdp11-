library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ram is
    port(clk, w_en : in std_logic;
        addr    : in std_logic_vector(10 downto 0);
        data_in : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)); 
end entity Ram;

architecture behaviour of Ram is 

type memory is array (2047 downto 0) of std_logic_vector(15 downto 0);
signal ram_memory : memory;

begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(w_en = '1') then
                ram_memory(to_integer(unsigned(addr)+1)) <= data_in (31 downto 16);
                ram_memory(to_integer(unsigned(addr))) <= data_in (15 downto 0); 
            end if;
        end if;
    end process;

    data_out <= ram_memory(to_integer(unsigned(addr)+1)) & ram_memory(to_integer(unsigned(addr)));

end behaviour;