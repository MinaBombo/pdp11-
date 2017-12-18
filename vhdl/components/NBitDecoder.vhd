LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY NBitDecoder IS
GENERIC (n : NATURAL := 2);
PORT
  (
    Selection : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
    EnableSignal : IN STD_LOGIC;
    ControlSignal : OUT STD_LOGIC_VECTOR((2**n) - 1 DOWNTO 0)
  );
END NBitDecoder ;

ARCHITECTURE NBitDecoderArch OF NBitDecoder IS
BEGIN
  PROCESS (Selection , EnableSignal)
  BEGIN
    IF EnableSignal = '0' THEN
      ControlSignal <= (OTHERS => '0');
    ELSE ControlSignal <= (TO_INTEGER (UNSIGNED(Selection) ) => '1' , OTHERS => '0');
    END IF;
  END PROCESS;

END NBitDecoderArch ;
