LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY TriStateBuffer IS
generic(w : natural := 32);
PORT (
	InputSignal : IN STD_LOGIC_VECTOR(w-1 downto 0) ;
	ControlSignal : IN STD_LOGIC ;
	OutputSignal : OUT STD_LOGIC_VECTOR(w-1 downto 0) 
      );
END TriStateBuffer;


ARCHITECTURE TriStateBufferArch OF TriStateBuffer IS
BEGIN
	OutputSignal <= InputSignal WHEN ControlSignal = '1' ELSE (others => 'Z');
END TriStateBufferArch;