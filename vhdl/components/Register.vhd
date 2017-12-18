library ieee;
use ieee.std_logic_1164.all;

entity NBitRegister is
    generic(w : natural := 32);
    port(clk, in_enable,out_enable, reset : in std_logic;
        d : in std_logic_vector(w-1 downto 0);
          
        q : out std_logic_vector(w-1 downto 0)); 
end entity NBitRegister;

architecture register_arch of NBitRegister is

    component D_flipflop is
        generic(w : natural := 32);
        port(clk, enable, reset : in std_logic;
            d : in std_logic_vector(w-1 downto 0);
              
            q : out std_logic_vector(w-1 downto 0)); 
    end component D_flipflop;

    component TriStateBuffer IS
    generic(w : natural := 32);
    PORT (
        InputSignal : IN STD_LOGIC_VECTOR(w-1 downto 0) ;
        ControlSignal : IN STD_LOGIC ;
        OutputSignal : OUT STD_LOGIC_VECTOR(w-1 downto 0) 
        );
    END component;

   
    signal d_flip_flop_output : STD_LOGIC_VECTOR(w-1 downto 0);

begin
    d_flip_flop : D_flipflop generic map(w) port map(clk,in_enable,reset,d,d_flip_flop_output);
    tri_state_buffer : TriStateBuffer generic map(w) port map(d_flip_flop_output,out_enable,q);
end register_arch ; -- arch