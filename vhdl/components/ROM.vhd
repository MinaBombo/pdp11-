library ieee;
use ieee.std_logic_1164.all;

entity Rom is
    port( clk : in std_logic;
        addr : in natural;

        o_inc_cycle, o_dirty_bit, o_read, o_write,
        o_end, o_branch                   : out std_logic;
        o_alu_ctrl, o_reg_in_ctrl_second_group    : out std_logic_vector(1 downto 0);
        o_reg_out_ctrl, o_reg_in_ctrl_first_group : out std_logic_vector(2 downto 0));
end entity Rom;

architecture arch of Rom is 

constant h  : natural := 32;

-- Output Constants
constant PC_OUT   : std_logic_vector(2 downto 0) := "000";
constant MDR_OUT  : std_logic_vector(2 downto 0) := "001";
constant Rc_OUT   : std_logic_vector(2 downto 0) := "010";
constant SRC_OUT  : std_logic_vector(2 downto 0) := "011";
constant Z_OUT    : std_logic_vector(2 downto 0) := "100";
constant IR_OUT   : std_logic_vector(2 downto 0) := "101";
constant SP_OUT   : std_logic_vector(2 downto 0) := "110";
constant OUT_NONE : std_logic_vector(2 downto 0) := "111";

-- First Input Group Constants
constant MAR_IN   : std_logic_vector(2 downto 0) := "000";
constant MDR_IN   : std_logic_vector(2 downto 0) := "001";
constant SP_IN    : std_logic_vector(2 downto 0) := "010";
constant IR_IN    : std_logic_vector(2 downto 0) := "011";
constant CYCLE_IN : std_logic_vector(2 downto 0) := "100";
constant Y_IN     : std_logic_vector(2 downto 0) := "101";
constant FLAG_IN  : std_logic_vector(2 downto 0) := "110";
constant G1_NONE  : std_logic_vector(2 downto 0) := "111";

-- Second Input Group Constant
constant PC_IN   : std_logic_vector(1 downto 0) := "00";
constant Rc_IN   : std_logic_vector(1 downto 0) := "01";
constant Z_IN    : std_logic_vector(1 downto 0) := "10";
constant G2_NONE : std_logic_vector(1 downto 0) := "11";

-- ALU Constants
constant ALU_INC   : std_logic_vector(1 downto 0) := "00";
constant ALU_DEC   : std_logic_vector(1 downto 0) := "01";
constant ALU_ADD   : std_logic_vector(1 downto 0) := "10";
constant ALU_IR_OP : std_logic_vector(1 downto 0) := "11";
constant ALU_NONE  : std_logic_vector(1 downto 0) := "11";

type arr1 is array (h-1 downto 0) of std_logic;
type arr2 is array (h-1 downto 0) of std_logic_vector(1 downto 0);
type arr3 is array (h-1 downto 0) of std_logic_vector(2 downto 0);

signal sig_inc_cycle    : arr1;
signal sig_dirty_bit    : arr1;
signal sig_read         : arr1;
signal sig_write        : arr1;
signal sig_end          : arr1;
signal sig_branch       : arr1;
signal sig_alu_ctrl     : arr2;
signal sig_reg_out_ctrl : arr3;

-- First Group is : MAR, MDR, SP, Cycle, IR, Flag
signal sig_reg_in_ctrl_first_group : arr3;

-- Second Group is : PC, Rc, Z, Y
signal sig_reg_in_ctrl_second_group : arr2;

begin

    -- Fetch_INSTR 
    sig_inc_cycle(0)                <= '0';   
    sig_dirty_bit(0)                <= '0';    
    sig_read(0)                     <= '1';          
    sig_write(0)                    <= '0';         
    sig_end(0)                      <= '0';           
    sig_branch(0)                   <= '0';        
    sig_alu_ctrl(0)                 <= ALU_INC;     
    sig_reg_in_ctrl_second_group(0) <= Z_IN;  
    sig_reg_out_ctrl(0)             <= PC_OUT;      
    sig_reg_in_ctrl_first_group(0)  <= MAR_IN; 
    --
    sig_inc_cycle(1)                <= '0';   
    sig_dirty_bit(1)                <= '0';    
    sig_read(1)                     <= '0';          
    sig_write(1)                    <= '0';         
    sig_end(1)                      <= '0';           
    sig_branch(1)                   <= '0';        
    sig_alu_ctrl(1)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(1) <= PC_IN;  
    sig_reg_out_ctrl(1)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(1)  <= G1_NONE; 
    --
    sig_inc_cycle(2)                <= '0';   
    sig_dirty_bit(2)                <= '0';    
    sig_read(2)                     <= '0';          
    sig_write(2)                    <= '0';         
    sig_end(2)                      <= '0';           
    sig_branch(2)                   <= '1';        
    sig_alu_ctrl(2)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(2) <= G2_NONE;  
    sig_reg_out_ctrl(2)             <= MDR_OUT;      
    sig_reg_in_ctrl_first_group(2)  <= IR_IN; 
    --

    -- ADDR_FETCH_REG 
    sig_inc_cycle(3)                <= '1';   
    sig_dirty_bit(3)                <= '0';    
    sig_read(3)                     <= '0';          
    sig_write(3)                    <= '0';         
    sig_end(3)                      <= '0';           
    sig_branch(3)                   <= '1';        
    sig_alu_ctrl(3)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(3) <= G2_NONE;  
    sig_reg_out_ctrl(3)             <= Rc_OUT;      
    sig_reg_in_ctrl_first_group(3)  <= CYCLE_IN; 
    --

    -- ADDR_FETCH_AUTO_INC
    sig_inc_cycle(4)                <= '0';   
    sig_dirty_bit(4)                <= '0';    
    sig_read(4)                     <= '0';          
    sig_write(4)                    <= '0';         
    sig_end(4)                      <= '0';           
    sig_branch(4)                   <= '0';        
    sig_alu_ctrl(4)                 <= ALU_INC;     
    sig_reg_in_ctrl_second_group(4) <= Z_IN;  
    sig_reg_out_ctrl(4)             <= Rc_OUT;      
    sig_reg_in_ctrl_first_group(4)  <= MAR_IN; 
    --
    sig_inc_cycle(5)                <= '0';   
    sig_dirty_bit(5)                <= '1';    
    sig_read(5)                     <= '0';          
    sig_write(5)                    <= '0';         
    sig_end(5)                      <= '0';           
    sig_branch(5)                   <= '1';        
    sig_alu_ctrl(5)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(5) <= Rc_IN;  
    sig_reg_out_ctrl(5)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(5)  <= G1_NONE;
    --
    
    -- ADDR_FETCH_AUTO_DEC
    sig_inc_cycle(6)                <= '0';   
    sig_dirty_bit(6)                <= '0';    
    sig_read(6)                     <= '0';          
    sig_write(6)                    <= '0';         
    sig_end(6)                      <= '0';           
    sig_branch(6)                   <= '0';        
    sig_alu_ctrl(6)                 <= ALU_DEC;     
    sig_reg_in_ctrl_second_group(6) <= Z_IN;  
    sig_reg_out_ctrl(6)             <= Rc_OUT;      
    sig_reg_in_ctrl_first_group(6)  <= G1_NONE; 
    --
    sig_inc_cycle(7)                <= '0';   
    sig_dirty_bit(7)                <= '1';    
    sig_read(7)                     <= '0';          
    sig_write(7)                    <= '0';         
    sig_end(7)                      <= '0';           
    sig_branch(7)                   <= '1';        
    sig_alu_ctrl(7)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(7) <= Rc_IN;  
    sig_reg_out_ctrl(7)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(7)  <= MAR_IN; 
    --

    -- ADDR_FETCH_INDEXED
    sig_inc_cycle(8)                <= '0';   
    sig_dirty_bit(8)                <= '0';    
    sig_read(8)                     <= '1';          
    sig_write(8)                    <= '0';         
    sig_end(8)                      <= '0';           
    sig_branch(8)                   <= '0';        
    sig_alu_ctrl(8)                 <= ALU_INC;     
    sig_reg_in_ctrl_second_group(8) <= Z_IN;  
    sig_reg_out_ctrl(8)             <= PC_OUT;      
    sig_reg_in_ctrl_first_group(8)  <= MAR_IN; 
    --
    sig_inc_cycle(9)                <= '0';   
    sig_dirty_bit(9)                <= '0';    
    sig_read(9)                     <= '0';          
    sig_write(9)                    <= '0';         
    sig_end(9)                      <= '0';           
    sig_branch(9)                   <= '0';        
    sig_alu_ctrl(9)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(9) <= PC_IN;  
    sig_reg_out_ctrl(9)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(9)  <= G1_NONE; 
    --
    sig_inc_cycle(10)                <= '0';   
    sig_dirty_bit(10)                <= '0';    
    sig_read(10)                     <= '0';          
    sig_write(10)                    <= '0';         
    sig_end(10)                      <= '0';           
    sig_branch(10)                   <= '0';        
    sig_alu_ctrl(10)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(10) <= G2_NONE;  
    sig_reg_out_ctrl(10)             <= MDR_OUT;      
    sig_reg_in_ctrl_first_group(10)  <= Y_IN; 
    --
    sig_inc_cycle(11)                <= '0';   
    sig_dirty_bit(11)                <= '0';    
    sig_read(11)                     <= '0';          
    sig_write(11)                    <= '0';         
    sig_end(11)                      <= '0';           
    sig_branch(11)                   <= '0';        
    sig_alu_ctrl(11)                 <= ALU_ADD;     
    sig_reg_in_ctrl_second_group(11) <= Z_IN;  
    sig_reg_out_ctrl(11)             <= Rc_OUT;      
    sig_reg_in_ctrl_first_group(11)  <= G1_NONE; 
    --
    sig_inc_cycle(12)                <= '0';   
    sig_dirty_bit(12)                <= '1';    
    sig_read(12)                     <= '0';          
    sig_write(12)                    <= '0';         
    sig_end(12)                      <= '0';           
    sig_branch(12)                   <= '1';        
    sig_alu_ctrl(12)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(12) <= G2_NONE;  
    sig_reg_out_ctrl(12)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(12)  <= MAR_IN; 
    --

    -- ADDR_NO_OP
    -- Same address as ADDR_PANIC
    --

    -- ADDR_JSR
    sig_inc_cycle(13)                <= '0';   
    sig_dirty_bit(13)                <= '0';    
    sig_read(13)                     <= '0';          
    sig_write(13)                    <= '0';         
    sig_end(13)                      <= '0';           
    sig_branch(13)                   <= '0';        
    sig_alu_ctrl(13)                 <= ALU_DEC;     
    sig_reg_in_ctrl_second_group(13) <= Z_IN;  
    sig_reg_out_ctrl(13)             <= SP_OUT;      
    sig_reg_in_ctrl_first_group(13)  <= G1_NONE; 
    --
    sig_inc_cycle(14)                <= '0';   
    sig_dirty_bit(14)                <= '0';    
    sig_read(14)                     <= '0';          
    sig_write(14)                    <= '0';         
    sig_end(14)                      <= '0';           
    sig_branch(14)                   <= '0';        
    sig_alu_ctrl(14)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(14) <= G2_NONE;  
    sig_reg_out_ctrl(14)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(14)  <= SP_IN; 
    --
    sig_inc_cycle(15)                <= '0';   
    sig_dirty_bit(15)                <= '0';    
    sig_read(15)                     <= '0';          
    sig_write(15)                    <= '0';         
    sig_end(15)                      <= '0';           
    sig_branch(15)                   <= '0';        
    sig_alu_ctrl(15)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(15) <= G2_NONE;  
    sig_reg_out_ctrl(15)             <= OUT_NONE;      
    sig_reg_in_ctrl_first_group(15)  <= MAR_IN; 
    --
    sig_inc_cycle(16)                <= '0';   
    sig_dirty_bit(16)                <= '0';    
    sig_read(16)                     <= '0';          
    sig_write(16)                    <= '1';         
    sig_end(16)                      <= '0';           
    sig_branch(16)                   <= '0';        
    sig_alu_ctrl(16)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(16) <= G2_NONE;  
    sig_reg_out_ctrl(16)             <= PC_OUT;      
    sig_reg_in_ctrl_first_group(16)  <= MDR_IN; 
    --
    sig_inc_cycle(17)                <= '0';   
    sig_dirty_bit(17)                <= '0';    
    sig_read(17)                     <= '0';          
    sig_write(17)                    <= '0';         
    sig_end(17)                      <= '1';           
    sig_branch(17)                   <= '0';        
    sig_alu_ctrl(17)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(17) <= PC_IN;  
    sig_reg_out_ctrl(17)             <= IR_OUT;      
    sig_reg_in_ctrl_first_group(17)  <= G1_NONE; 
    --

    -- ADDR_RTS
    sig_inc_cycle(18)                <= '0';   
    sig_dirty_bit(18)                <= '0';    
    sig_read(18)                     <= '1';          
    sig_write(18)                    <= '0';         
    sig_end(18)                      <= '0';           
    sig_branch(18)                   <= '0';        
    sig_alu_ctrl(18)                 <= ALU_INC;     
    sig_reg_in_ctrl_second_group(18) <= Z_IN;  
    sig_reg_out_ctrl(18)             <= SP_OUT;      
    sig_reg_in_ctrl_first_group(18)  <= MAR_IN; 
    --
    sig_inc_cycle(19)                <= '0';   
    sig_dirty_bit(19)                <= '0';    
    sig_read(19)                     <= '0';          
    sig_write(19)                    <= '0';         
    sig_end(19)                      <= '0';           
    sig_branch(19)                   <= '0';        
    sig_alu_ctrl(19)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(19) <= G2_NONE;  
    sig_reg_out_ctrl(19)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(19)  <= SP_IN; 
    --
    sig_inc_cycle(20)                <= '0';   
    sig_dirty_bit(20)                <= '0';    
    sig_read(20)                     <= '0';          
    sig_write(20)                    <= '0';         
    sig_end(20)                      <= '1';           
    sig_branch(20)                   <= '0';        
    sig_alu_ctrl(20)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(20) <= PC_IN;  
    sig_reg_out_ctrl(20)             <= MDR_OUT;      
    sig_reg_in_ctrl_first_group(20)  <= G1_NONE; 
    --

    -- ADDR_BRANCH
    sig_inc_cycle(21)                <= '0';   
    sig_dirty_bit(21)                <= '0';    
    sig_read(21)                     <= '0';          
    sig_write(21)                    <= '0';         
    sig_end(21)                      <= '0';           
    sig_branch(21)                   <= '0';        
    sig_alu_ctrl(21)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(21) <= G2_NONE;  
    sig_reg_out_ctrl(21)             <= IR_OUT;      
    sig_reg_in_ctrl_first_group(21)  <= Y_IN; 
    --
    sig_inc_cycle(22)                <= '0';   
    sig_dirty_bit(22)                <= '0';    
    sig_read(22)                     <= '0';          
    sig_write(22)                    <= '0';         
    sig_end(22)                      <= '0';           
    sig_branch(22)                   <= '0';        
    sig_alu_ctrl(22)                 <= ALU_ADD;     
    sig_reg_in_ctrl_second_group(22) <= Z_IN;  
    sig_reg_out_ctrl(22)             <= PC_OUT;      
    sig_reg_in_ctrl_first_group(22)  <= G1_NONE; 
    --
    sig_inc_cycle(23)                <= '0';   
    sig_dirty_bit(23)                <= '0';    
    sig_read(23)                     <= '0';          
    sig_write(23)                    <= '0';         
    sig_end(23)                      <= '1';           
    sig_branch(23)                   <= '0';        
    sig_alu_ctrl(23)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(23) <= PC_IN;  
    sig_reg_out_ctrl(23)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(23)  <= G1_NONE; 
    --

    -- ADDR_READ
    sig_inc_cycle(24)                <= '0';   
    sig_dirty_bit(24)                <= '0';    
    sig_read(24)                     <= '1';          
    sig_write(24)                    <= '0';         
    sig_end(24)                      <= '0';           
    sig_branch(24)                   <= '0';        
    sig_alu_ctrl(24)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(24) <= G2_NONE;  
    sig_reg_out_ctrl(24)             <= OUT_NONE;      
    sig_reg_in_ctrl_first_group(24)  <= G1_NONE; 
    --
    sig_inc_cycle(25)                <= '1';   
    sig_dirty_bit(25)                <= '1';    
    sig_read(25)                     <= '0';          
    sig_write(25)                    <= '0';         
    sig_end(25)                      <= '0';           
    sig_branch(25)                   <= '1';        
    sig_alu_ctrl(25)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(25) <= G2_NONE;  
    sig_reg_out_ctrl(25)             <= MDR_OUT;      
    sig_reg_in_ctrl_first_group(25)  <= CYCLE_IN; 
    --

    -- ADDR_MOV_REG
    sig_inc_cycle(26)                <= '0';   
    sig_dirty_bit(26)                <= '0';    
    sig_read(26)                     <= '0';          
    sig_write(26)                    <= '0';         
    sig_end(26)                      <= '1';           
    sig_branch(26)                   <= '0';        
    sig_alu_ctrl(26)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(26) <= Rc_IN;  
    sig_reg_out_ctrl(26)             <= SRC_OUT;      
    sig_reg_in_ctrl_first_group(26)  <= G1_NONE; 
    --

    -- ADDR_MOV_MEM
    sig_inc_cycle(27)                <= '0';   
    sig_dirty_bit(27)                <= '0';    
    sig_read(27)                     <= '0';          
    sig_write(27)                    <= '1';         
    sig_end(27)                      <= '1';           
    sig_branch(27)                   <= '0';        
    sig_alu_ctrl(27)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(27) <= G2_NONE;  
    sig_reg_out_ctrl(27)             <= SRC_OUT;      
    sig_reg_in_ctrl_first_group(27)  <= MDR_IN; 
    --

    -- ADDR_SAVE_MEM
    sig_inc_cycle(28)                <= '0';   
    sig_dirty_bit(28)                <= '0';    
    sig_read(28)                     <= '0';          
    sig_write(28)                    <= '1';         
    sig_end(28)                      <= '1';           
    sig_branch(28)                   <= '0';        
    sig_alu_ctrl(28)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(28) <= G2_NONE;  
    sig_reg_out_ctrl(28)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(28)  <= MDR_IN; 
    --

    -- ADDR_SAVE_REG
    sig_inc_cycle(29)                <= '0';   
    sig_dirty_bit(29)                <= '0';    
    sig_read(29)                     <= '0';          
    sig_write(29)                    <= '0';         
    sig_end(29)                      <= '1';           
    sig_branch(29)                   <= '0';        
    sig_alu_ctrl(29)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(29) <= Rc_IN;  
    sig_reg_out_ctrl(29)             <= Z_OUT;      
    sig_reg_in_ctrl_first_group(29)  <= G1_NONE; 
    --

    -- ADDR_EXEC
    sig_inc_cycle(30)                <= '0';   
    sig_dirty_bit(30)                <= '0';    
    sig_read(30)                     <= '0';          
    sig_write(30)                    <= '0';         
    sig_end(30)                      <= '0';           
    sig_branch(30)                   <= '1';        
    sig_alu_ctrl(30)                 <= ALU_IR_OP;     
    sig_reg_in_ctrl_second_group(30) <= Z_IN;  
    sig_reg_out_ctrl(30)             <= SRC_OUT;      
    sig_reg_in_ctrl_first_group(30)  <= G1_NONE; 
    --
    
    -- ADDR_PANIC
    sig_inc_cycle(31)                <= '0';   
    sig_dirty_bit(31)                <= '0';    
    sig_read(31)                     <= '0';          
    sig_write(31)                    <= '0';         
    sig_end(31)                      <= '1';           
    sig_branch(31)                   <= '0';        
    sig_alu_ctrl(31)                 <= ALU_NONE;     
    sig_reg_in_ctrl_second_group(31) <= G2_NONE;  
    sig_reg_out_ctrl(31)             <= OUT_NONE;      
    sig_reg_in_ctrl_first_group(31)  <= G1_NONE; 
    --
    --
    process(clk)
    begin
        if( rising_edge(clk) ) then
            o_inc_cycle                <= sig_inc_cycle(addr);   
            o_dirty_bit                <= sig_dirty_bit(addr);   
            o_read                     <= sig_read(addr);         
            o_write                    <= sig_write(addr);        
            o_end                      <= sig_end(addr);          
            o_branch                   <= sig_branch(addr);       
            o_alu_ctrl                 <= sig_alu_ctrl(addr);  
            o_reg_in_ctrl_second_group <= sig_reg_in_ctrl_second_group(addr);   
            o_reg_out_ctrl             <= sig_reg_out_ctrl(addr);     
            o_reg_in_ctrl_first_group  <= sig_reg_in_ctrl_first_group(addr);
        end if;
    end process;

end arch;
