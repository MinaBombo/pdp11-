library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LAO.all;

entity ALSU is  
		generic(op_w : natural := 16);
		port (A, B :  in std_logic_vector (op_w-1 downto 0);
			sel : in std_logic_vector(4 downto 0);
			Cin : in std_logic;
			
			F    	   : out  std_logic_vector (op_w-1 downto 0);
			Cout, Zout : out std_logic);    
end entity ALSU;

architecture dataflow of ALSU is

constant OP_ADD : std_logic_vector(4 downto 0) := "00000";
constant OP_ADC : std_logic_vector(4 downto 0) := "00001";
constant OP_SUB : std_logic_vector(4 downto 0) := "00010";
constant OP_SBC : std_logic_vector(4 downto 0) := "00011";
constant OP_AND : std_logic_vector(4 downto 0) := "00100";
constant OP_OR  : std_logic_vector(4 downto 0) := "00101";
constant OP_XOR : std_logic_vector(4 downto 0) := "00110";
constant OP_BIC : std_logic_vector(4 downto 0) := "00111";

constant OP_INC : std_logic_vector(4 downto 0) := "01000";
constant OP_DEC : std_logic_vector(4 downto 0) := "01001";
constant OP_INV : std_logic_vector(4 downto 0) := "01010";
constant OP_LSR : std_logic_vector(4 downto 0) := "01011";
constant OP_ROR : std_logic_vector(4 downto 0) := "01100";
constant OP_RRC : std_logic_vector(4 downto 0) := "01101";
constant OP_ASR : std_logic_vector(4 downto 0) := "01110";
constant OP_LSL : std_logic_vector(4 downto 0) := "01111";
constant OP_ROL : std_logic_vector(4 downto 0) := "10000";
constant OP_RLC : std_logic_vector(4 downto 0) := "10001";
-------------------------------------------------------------------------------------------------------
function get_carry_out(op, v_a, v_b : std_logic_vector ) return std_logic is
begin
	return '0';
end get_carry_out;
	-- Result subtype : std_logic
	-- Result		  : choose which carry to bind to final carry out
-------------------------------------------------------------------------------------------------------

constant UNDEF_OP : std_logic_vector(op_w-1 downto 0) := (others => '1');

begin
	F <= std_logic_vector(unsigned(A) + unsigned(B)) when sel = OP_ADD
	else std_logic_vector(unsigned(A) + unsigned(B) + 1 ) when sel = OP_ADC

	else std_logic_vector(unsigned(A) - unsigned(B)) when sel = OP_SUB
	else std_logic_vector(unsigned(A) - unsigned(B) - 1 ) when sel = OP_SBC

	else A and B when sel = OP_AND
	else A or  B when sel = OP_OR
	else A xor B when sel = OP_XOR
	else A and not(B) when sel = OP_BIC

	else std_logic_vector(unsigned(A) + 1) when sel = OP_INC 
	else std_logic_vector(unsigned(A) - 1) when sel = OP_DEC 

	else not(A) when sel = OP_INV 

	else shift_logic_right(A) when sel = OP_LSR 
	else rotate_right_carry(A, A(0)) when sel = OP_ROR 
	else rotate_right_carry(A, Cin) when sel = OP_RRC 
	else shift_arith_right(A) when sel = OP_ASR
	else shift_logic_left(A)  when sel = OP_LSL
	else rotate_left_carry(A, A(op_w-1)) when sel = OP_ROL
	else rotate_left_carry(A, Cin) when sel = OP_RLC

	else UNDEF_OP;

	Cout <= get_carry_out(sel, A, B);
end dataflow;
