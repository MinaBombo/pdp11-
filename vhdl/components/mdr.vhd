library ieee;
use ieee.std_logic_1164.all;

entity mdr is
    generic(w : natural := 32);
    port(clk, bus_enable,ram_enable, reset : in std_logic;
        bus_input,ram_input : in std_logic_vector(w-1 downto 0);
          
        q : out std_logic_vector(w-1 downto 0)); 
end entity mdr;

architecture behaviour of mdr is 
begin

    process(clk, reset,ram_input)
    begin
        if(reset = '1') then
            q <= (others => '0');
        elsif(ram_enable = '1') then
            q <= ram_input;
        elsif(rising_edge(clk) and bus_enable = '1') then
            q <= bus_input;
        end if;
    end process;

end behaviour;
