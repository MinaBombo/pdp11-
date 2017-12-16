library ieee;
use ieee.std_logic_1164.all;

entity CU is
    port( i_clk, i_reset : in std_logic;
        i_flag  : in std_logic_vector(1 downto 0);
        i_ir    : in std_logic_vector(15 downto 0);
    
        o_r0_in, o_r1_in, o_r2_in, o_r3_in     : out std_logic;
        o_r0_out, o_r1_out, o_r2_out, o_r3_out : out std_logic;

        o_sp_in, o_pc_in, o_mar_in, o_mdr_in, o_flag_in, o_ir_in : out std_logic;
        o_sp_out, o_pc_out, o_mdr_out, o_ir_out                  : out std_logic;

        o_src_in, o_y_in, o_z_in : out std_logic;
        o_src_out, o_z_out       : out std_logic;

        o_mem_read, o_mem_write : out std_logic;

        o_alu_op : out std_logic_vector(4 downto 0));
end entity CU;

architecture arch of CU is

component MicroPC is
    port(clk, enable, reset, load : in std_logic;
        input_load : in natural;      

        curr_output : out natural); 
end component;

component Rom is
    port( clk : in std_logic;
        addr : in natural;

        o_inc_cycle, o_dirty_bit, o_read, o_write,
        o_end, o_branch                   : out std_logic;
        o_alu_ctrl, o_reg_in_ctrl_second_group    : out std_logic_vector(1 downto 0);
        o_reg_out_ctrl, o_reg_in_ctrl_first_group : out std_logic_vector(2 downto 0));
end component;

component D_flipflop is
    generic(w : natural := 32);
    port(clk, enable, reset : in std_logic;
        d : in std_logic_vector(w-1 downto 0);
          
        q : out std_logic_vector(w-1 downto 0)); 
end component;

component T_flipflop is
    port(clk, reset, t : in std_logic;
    
        q : out std_logic);
end component;

component PLA is
    port(mov, dirty_bit : in std_logic;
        n_ops, spec_op, addr_mode, cycle : in std_logic_vector(1 downto 0);
        
        addr : out natural);
end component;

constant HLT_OPCODE : std_logic_vector(4 downto 0) := "11111";
constant MOV_OPCODE : std_logic_vector(4 downto 0) := "00000";

constant NO_OP_OPCODE      : std_logic_vector(4 downto 0) := "00000";
constant JSR_OP_OPCODE     : std_logic_vector(4 downto 0) := "00000";
constant RTS_OP_OPCODE     : std_logic_vector(4 downto 0) := "00000";
constant BRANCH_OP_OPCODE  : std_logic_vector(4 downto 0) := "00000";

constant LOW_BOUND_ZERO_OP  : std_logic_vector(4 downto 0) := "00000";
constant HIGH_BOUND_ZERO_OP : std_logic_vector(4 downto 0) := "00000";
constant LOW_BOUND_ONE_OP   : std_logic_vector(4 downto 0) := "00000";
constant HIGH_BOUND_ONE_OP  : std_logic_vector(4 downto 0) := "00000";

signal sig_not_clk, sig_mov, sig_not_hlt : std_logic;
signal sig_n_ops, sig_spec_op            : std_logic_vector(1 downto 0);

signal sig_reset_mircopc : std_logic;
signal sig_pla_out, sig_micropc_out   : natural;

signal sig_inc_cycle, sig_dirty_bit, sig_read, sig_write, sig_branch : std_logic;
signal sig_alu_ctrl, sig_reg_in_ctrl_second_group                             : std_logic_vector(1 downto 0);
signal sig_reg_out_ctrl, sig_reg_in_ctrl_first_group                          : std_logic_vector(2 downto 0);

signal sig_dirty_bit_latched    : std_logic;
signal sig_end_latched, sig_end : std_logic_vector(0 downto 0); -- Sorry not sorry

begin

    sig_not_clk <= not i_clk;

    sig_not_hlt <= '0' when ( i_ir(15 downto 11) = HLT_OPCODE)
    else           '1';

    sig_mov <= '1' when ( i_ir(15 downto 11) = MOV_OPCODE)
    else       '0';

    sig_n_ops <= "00" when ( i_ir(15 downto 11) > LOW_BOUND_ZERO_OP and i_ir(15 downto 11) < HIGH_BOUND_ZERO_OP )
    else         "01" when ( i_ir(15 downto 11) > LOW_BOUND_ONE_OP and i_ir(15 downto 11) < HIGH_BOUND_ONE_OP)
    else         "10";

    sig_spec_op <= "00" when ( i_ir(15 downto 11) = NO_OP_OPCODE)
    else           "01" when ( i_ir(15 downto 11) = JSR_OP_OPCODE)
    else           "10" when ( i_ir(15 downto 11) = RTS_OP_OPCODE)
    else           "11";

    -- Check hard or soft reset (!!! sig_reset_mircopc not initialized)
    micro_pc : MicroPC port map(i_clk, sig_not_hlt, sig_reset_mircopc, sig_branch, sig_pla_out,
                                sig_micropc_out);

    instr_rom : Rom port map( i_clk, sig_micropc_out, 
                        sig_inc_cycle, sig_dirty_bit, sig_read, sig_write, sig_end(0), sig_branch,
                        sig_alu_ctrl, sig_reg_in_ctrl_second_group,
                        sig_reg_out_ctrl, sig_reg_in_ctrl_first_group);
    
    end_latch : D_flipflop generic map(1) port map(sig_not_clk, '1', i_reset, sig_end , sig_end_latched); 



    dirty_latch :  T_flipflop port map(sig_not_clk, sig_end_latched(0), sig_dirty_bit, sig_dirty_bit_latched);
    
    --dispatcher : PLA port map(sig_mov, sig_dirty_bit_latched, sig_n_ops, sig_spec_op, addr_mode, cycle, addr);

end arch;
