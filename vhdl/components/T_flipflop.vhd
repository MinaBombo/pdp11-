library ieee;
use ieee.std_logic_1164.all;

entity T_flipflop is
    port(clk, reset, t : in std_logic;
    
        q : out std_logic);
end entity T_flipflop;

architecture arch of T_flipflop is

    signal sig_q : std_logic;

begin

    process(clk, reset)
    begin
        if (reset = '1') then 
            sig_q <= '0';
        elsif (rising_edge(clk) and t ='1') then
            sig_q <= not sig_q;
        end if;
    end process;

    q <= sig_q;
end arch;
