library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
    generic(w : natural := 2);
    port(clk, enable, reset : in std_logic;
          
        curr_output : out std_logic_vector(w-1 downto 0)); 
end entity Counter;

architecture arch of Counter is 

signal sig_curr_output: std_logic_vector(w-1 downto 0);
constant sig_ones: std_logic_vector(w-1 downto 0) := (others => '1');

begin

    process(clk, reset)
    begin
        if(reset = '1') then
            sig_curr_output <= (others => '0');
        elsif(rising_edge(clk) and enable = '1') then
            if(sig_curr_output = sig_ones) then
                sig_curr_output <= (others => '0');
            else 
            sig_curr_output <= std_logic_vector(unsigned(sig_curr_output) + 1);
            end if;
        end if;
    end process;

    curr_output <= sig_curr_output;
end arch;
