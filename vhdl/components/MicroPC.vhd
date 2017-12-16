library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MicroPC is
    port(clk, enable, reset, load : in std_logic;
        input_load : in natural;      

        curr_output : out natural); 
end entity MicroPC;

architecture arch of MicroPC is 

signal sig_cur : natural; 

begin
    process(clk, reset, load)
    begin
        if (reset = '1') then
            sig_cur <= 0; 
        elsif (load = '1') then 
            sig_cur <= input_load;
        elsif (rising_edge(clk) and enable = '1') then
            sig_cur <= (sig_cur + 1);
        end if;
    end process;
    
    curr_output <= sig_cur;

end arch;