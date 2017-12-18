library IEEE;
use IEEE.std_logic_1164.all;

entity nBitsFullAdder is
    generic(numBits : integer := 16);
    port(A, B : in std_logic_vector (numBits-1  downto 0);
             Cin : in std_logic;

        F : out std_logic_vector(numBits-1 downto 0);    
            Cout : out std_logic);
end nBitsFullAdder;

architecture behave of nBitsFullAdder is
    component fullAdder is  
    port (A, B, Cin :  in std_logic;
        
               F, Cout : out  std_logic );    
    end component;

signal Carry : std_logic_vector (numBits-1 downto 0); 

begin 

    fBit: fullAdder port map (A(0), B(0), Cin, F(0), Carry(0));
    looper: for i in 1 to numBits-1 generate
        iBit: fullAdder port map (A(i), B(i), Carry(i-1), F(i), Carry(i));
    end generate;

    Cout <= Carry(numBits-1);

end behave;

