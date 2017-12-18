library ieee;
use ieee.std_logic_1164.all;

entity fullAdder is  
		port (A, B, Cin :  in std_logic;
			
  		    F, Cout : out  std_logic );    
end entity fullAdder;


architecture dataflow of fullAdder is
begin
	F <= A xor B xor Cin ;
    Cout <= (A and B)or(Cin and A)or(Cin and B) ;    
end dataflow;