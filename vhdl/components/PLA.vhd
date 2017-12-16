library ieee;
use ieee.std_logic_1164.all;

entity PLA is
    port(mov, dirty_bit : in std_logic;
        n_ops, spec_op, addr_mode, cycle : in std_logic_vector(1 downto 0);
        
        addr : out natural);
end entity PLA;

architecture dataflow of PLA is

-- n_ops enumuration 
constant ZERO_OP   : std_logic_vector(1 downto 0) := "00";
constant SINGLE_OP : std_logic_vector(1 downto 0) := "01";
constant DOUBLE_OP : std_logic_vector(1 downto 0) := "10";

-- dirty_bit enumuration
constant ABOUT_TO_FETCH : std_logic := '0';
constant ABOUT_TO_READ  : std_logic := '1';

-- spec_op enumuration
constant NO_OP   : std_logic_vector(1 downto 0) := "00";
constant JSR     : std_logic_vector(1 downto 0) := "01";
constant RTS     : std_logic_vector(1 downto 0) := "10";
constant BRANCH  : std_logic_vector(1 downto 0) := "11";

-- addr_mode enumuration
constant REG_DIR  : std_logic_vector(1 downto 0) := "00";
constant AUTO_INC    : std_logic_vector(1 downto 0) := "01";
constant AUTO_DEC    : std_logic_vector(1 downto 0) := "10";
constant INDEXED     : std_logic_vector(1 downto 0) := "11";

-- cycle enumuration
constant CYC_ZERO  : std_logic_vector(1 downto 0) := "00";
constant CYC_ONE   : std_logic_vector(1 downto 0) := "01";
constant CYC_TWO   : std_logic_vector(1 downto 0) := "10";
constant CYC_THREE : std_logic_vector(1 downto 0) := "11";

-- Addresses
constant ADDR_FETCH_REG      : natural := 3;
constant ADDR_FETCH_AUTO_INC : natural := 4;
constant ADDR_FETCH_AUTO_DEC : natural := 6;
constant ADDR_FETCH_INDEXED  : natural := 8;
constant ADDR_NO_OP          : natural := 31;
constant ADDR_JSR            : natural := 13;
constant ADDR_RTS            : natural := 18;
constant ADDR_BRANCH         : natural := 21;
constant ADDR_READ           : natural := 24;
constant ADDR_MOV_REG        : natural := 26;
constant ADDR_MOV_MEM        : natural := 27;
constant ADDR_SAVE_MEM       : natural := 28;
constant ADDR_SAVE_REG       : natural := 29;
constant ADDR_EXEC           : natural := 30;
constant ADDR_PANIC          : natural := 31;

begin

    addr <= ADDR_NO_OP     when (n_ops = ZERO_OP   and spec_op = NO_OP)
    else    ADDR_JSR       when (n_ops = ZERO_OP   and spec_op = JSR)
    else    ADDR_RTS       when (n_ops = ZERO_OP   and spec_op = RTS)
    else    ADDR_BRANCH    when (n_ops = ZERO_OP   and spec_op = BRANCH)

    else ADDR_READ
    when ( dirty_bit = ABOUT_TO_READ and (cycle = CYC_ZERO or (cycle = CYC_ONE and mov = '0')) )

    else ADDR_MOV_REG 
    when ( cycle = CYC_ONE and mov = '1' and addr_mode = REG_DIR )
    else ADDR_MOV_MEM
    when ( dirty_bit = ABOUT_TO_READ and cycle = CYC_ONE and mov = '1' and addr_mode /= REG_DIR )

    else ADDR_EXEC
    when ( (cycle = CYC_ONE and n_ops = SINGLE_OP) or (cycle = CYC_TWO and n_ops = DOUBLE_OP) )

    else ADDR_SAVE_REG
    when ( addr_mode = REG_DIR and 
    ((cycle = CYC_TWO and n_ops = SINGLE_OP) or (cycle = CYC_THREE and n_ops = DOUBLE_OP)) )
    else ADDR_SAVE_MEM
    when ( addr_mode /= REG_DIR and 
    ((cycle = CYC_TWO and n_ops = SINGLE_OP) or (cycle = CYC_THREE and n_ops = DOUBLE_OP)) )
    
    else ADDR_FETCH_REG      
    when ( addr_mode = REG_DIR and (cycle = CYC_ZERO or (cycle = CYC_ONE and n_ops = DOUBLE_OP)) )
    else ADDR_FETCH_AUTO_INC 
    when ( addr_mode = AUTO_INC and (cycle = CYC_ZERO or (cycle = CYC_ONE and n_ops = DOUBLE_OP)) )
    else ADDR_FETCH_AUTO_DEC 
    when ( addr_mode = AUTO_DEC and (cycle = CYC_ZERO or (cycle = CYC_ONE and n_ops = DOUBLE_OP)) )
    else ADDR_FETCH_INDEXED  
    when ( addr_mode = INDEXED and (cycle = CYC_ZERO or (cycle = CYC_ONE and n_ops = DOUBLE_OP)) )

    else ADDR_PANIC;


end dataflow;
