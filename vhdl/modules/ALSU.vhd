library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LAO.all;

entity ALSU is  
		generic(op_w : natural := 16);
		port(A, B :  in std_logic_vector (op_w-1 downto 0);
			sel : in std_logic_vector(4 downto 0);
			Cin : in std_logic;
			
			F			 : out  std_logic_vector (op_w-1 downto 0);
			Cout, z_flag : out std_logic);    
end entity ALSU;

architecture dataflow of ALSU is

component nBitsFullAdder is
    generic(numBits : integer := 16);
    port(A, B : in std_logic_vector (numBits-1  downto 0);
             Cin : in std_logic;

        F : out std_logic_vector(numBits-1 downto 0);    
            Cout : out std_logic);
end component;

constant OP_ADD : std_logic_vector(4 downto 0)  := "00001";
constant OP_ADC : std_logic_vector(4 downto 0)  := "00010";
constant OP_SUB : std_logic_vector(4 downto 0)  := "00011";
constant OP_SBC : std_logic_vector(4 downto 0)  := "00100";
constant OP_AND : std_logic_vector(4 downto 0)  := "00101";
constant OP_OR  : std_logic_vector(4 downto 0)  := "00110";
constant OP_XOR : std_logic_vector(4 downto 0)  := "00111";
constant OP_BIC : std_logic_vector(4 downto 0)  := "01000";
constant OP_CMP : std_logic_vector(4 downto 0)  := "01001";

constant OP_INC : std_logic_vector(4 downto 0)  := "01010";
constant OP_DEC : std_logic_vector(4 downto 0)  := "01011";
constant OP_INV : std_logic_vector(4 downto 0)  := "01100";
constant OP_LSR : std_logic_vector(4 downto 0)  := "01101";
constant OP_ROR : std_logic_vector(4 downto 0)  := "01110";
constant OP_RRC : std_logic_vector(4 downto 0)  := "01111";
constant OP_ASR : std_logic_vector(4 downto 0)  := "10000";
constant OP_LSL : std_logic_vector(4 downto 0)  := "10001";
constant OP_ROL : std_logic_vector(4 downto 0)  := "10010";
constant OP_RLC : std_logic_vector(4 downto 0)  := "10011";

constant OP_INC2 : std_logic_vector(4 downto 0) := "10100";
constant OP_DEC2 : std_logic_vector(4 downto 0) := "10101";

constant UNDEF_OP : std_logic_vector(op_w-1 downto 0) := (others => '1');
constant ZEROS	  : std_logic_vector(op_w-1 downto 0) := (others => '0');
-------------------------------------------------------------------------------------------------------
function get_carry_out(op, v_f, v_a : std_logic_vector; cin, cout : std_logic) return std_logic is
begin
	if(op = OP_AND or op = OP_OR or op = OP_XOR or op = OP_BIC or op = OP_INC or op = OP_DEC) then
		return cin;

	elsif (op = OP_INV) then
		if (v_f = ZEROS) then
			return '0';
		else 
			return '1';
		end if;

	elsif (op = OP_LSR or op = OP_ROR or op = OP_RRC or op = OP_ASR) then
		return v_a(0);

	elsif (op = OP_LSL or op = OP_ROL or op = OP_RLC) then
		return v_a(op_w-1);

	else 
		return cout;
	end if;
end get_carry_out;
	-- Result subtype : std_logic
	-- Result		  : choose which carry to bind to final carry out
-------------------------------------------------------------------------------------------------------

signal sig_b, sig_o_adder, f_temp : std_logic_vector(op_w-1 downto 0);
signal sig_cout, sig_cin  		  : std_logic;

begin

	sig_b <= not (B) when sel =  OP_SUB or sel = OP_SBC or sel =  OP_CMP
	else  	 B;

	sig_cin <= Cin when sel = OP_ADC or sel = OP_SBC or sel =  OP_RRC or sel = OP_RLC
	else 	   '0';

	full_adder : nBitsFullAdder generic map(op_w)
	port map(A, sig_b, sig_cin, sig_o_adder, sig_cout);

	f_temp <= sig_o_adder when sel = OP_ADD or sel = OP_ADC or sel = OP_SUB or sel = OP_CMP or sel = OP_SBC

	else A and B when sel = OP_AND
	else A or  B when sel = OP_OR
	else A xor B when sel = OP_XOR
	else A and not(B) when sel = OP_BIC

	else std_logic_vector(unsigned(A) + 1) when sel = OP_INC 
	else std_logic_vector(unsigned(A) + 2) when sel = OP_INC2
	else std_logic_vector(unsigned(A) - 1) when sel = OP_DEC
	else std_logic_vector(unsigned(A) - 2) when sel = OP_DEC2 

	else not(A) when sel = OP_INV 

	else shift_logic_right(A) when sel = OP_LSR 
	else rotate_right_carry(A, A(0)) when sel = OP_ROR 
	else rotate_right_carry(A, Cin) when sel = OP_RRC 
	else shift_arith_right(A) when sel = OP_ASR
	else shift_logic_left(A)  when sel = OP_LSL
	else rotate_left_carry(A, A(op_w-1)) when sel = OP_ROL
	else rotate_left_carry(A, Cin) when sel = OP_RLC

	else UNDEF_OP;

	F	   <= f_temp;
	Cout   <= get_carry_out(sel, f_temp, A, Cin, sig_cout);
	z_flag <= '1' when f_temp = Zeros 
	else      '0';
end dataflow;
