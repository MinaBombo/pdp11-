library ieee;
use ieee.std_logic_1164.all;

entity CU is
    port( i_clk, i_reset : in std_logic;
        i_flag  : in std_logic_vector(1 downto 0);  --i_flag(0) = carry, i_flag(1) = zero
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
    port(mov, dirty_bit,cmp : in std_logic;
        n_ops, spec_op, addr_mode, cycle : in std_logic_vector(1 downto 0);
        
        addr : out natural);
end component;

component Counter is
    generic(w : natural := 2);
    port(clk, enable, reset : in std_logic;
          
        curr_output : out std_logic_vector(w-1 downto 0)); 
end component;

component NBitDecoder IS
GENERIC (n : NATURAL := 2);
PORT
  (
    Selection : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
    EnableSignal : IN STD_LOGIC;
    ControlSignal : OUT STD_LOGIC_VECTOR((2**n) - 1 DOWNTO 0)
  );
END component ;


constant HLT_OPCODE : std_logic_vector(4 downto 0) := "11011";
constant MOV_OPCODE : std_logic_vector(4 downto 0) := "00000";
constant CMP_OPCODE : std_logic_vector(4 downto 0) := "01001";
constant INC_OPCODE : std_logic_vector(4 downto 0) := "01010";
constant DEC_OPCODE : std_logic_vector(4 downto 0) := "01011";
constant ADD_OPCODE : std_logic_vector(4 downto 0) := "00001";

constant NO_OP_OPCODE      : std_logic_vector(4 downto 0) := "11100";
constant JSR_OP_OPCODE     : std_logic_vector(4 downto 0) := "11110";
constant RTS_OP_OPCODE     : std_logic_vector(4 downto 0) := "11111";
--constant BRANCH_OP_OPCODE  : std_logic_vector(4 downto 0) := "00000";

constant LOW_BOUND_ZERO_OP  : std_logic_vector(4 downto 0) := "10011";
constant HIGH_BOUND_ZERO_OP : std_logic_vector(4 downto 0) := "11111";
constant LOW_BOUND_ONE_OP   : std_logic_vector(4 downto 0) := "01001";
constant HIGH_BOUND_ONE_OP  : std_logic_vector(4 downto 0) := "10100";

--Branch OpCodes
constant UNCONDITIONAL_BRANCH_OPCODE : std_logic_vector(4 downto 0) := "10100";
constant EQUAL_BRANCH_OPCODE : std_logic_vector(4 downto 0) := "10101";
constant NOTEQUAL_BRANCH_OPCODE : std_logic_vector(4 downto 0) := "10110";
constant LOWER_BRANCH_OPCODE : std_logic_vector(4 downto 0) := "10111";
constant LOWERORSAME_BRANCH_OPCODE : std_logic_vector(4 downto 0) := "11000";
constant HIGHER_BRANCH_OPCODE : std_logic_vector(4 downto 0) := "11001";
constant HIGHERORSAME_BRANCH_OPCODE : std_logic_vector(4 downto 0) := "11010";

--ROM Constants

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
constant ALU_NONE  : std_logic_vector(1 downto 0) := "00";

-- cycle enumuration
constant CYC_ZERO  : std_logic_vector(1 downto 0) := "00";
constant CYC_ONE   : std_logic_vector(1 downto 0) := "01";
constant CYC_TWO   : std_logic_vector(1 downto 0) := "10";
constant CYC_THREE : std_logic_vector(1 downto 0) := "11";

signal sig_not_clk, sig_mov, sig_not_hlt,sig_cmp : std_logic;
signal sig_n_ops, sig_spec_op            : std_logic_vector(1 downto 0);

signal sig_reset_mircopc : std_logic;
signal sig_pla_out, sig_micropc_out   : natural;

signal sig_inc_cycle, sig_dirty_bit, sig_read, sig_write, sig_branch : std_logic;
signal sig_alu_ctrl, sig_reg_in_ctrl_second_group                             : std_logic_vector(1 downto 0);
signal sig_reg_out_ctrl, sig_reg_in_ctrl_first_group                          : std_logic_vector(2 downto 0);

signal sig_dirty_bit_latched    : std_logic;
signal sig_end_latched, sig_end_from_rom, sig_end : std_logic_vector(0 downto 0); -- Sorry not sorry
signal sig_branch_end :std_logic;
signal sig_num_cycle_new,sig_num_cycle_old : std_logic_vector(1 downto 0);

signal sig_main_reg_out_ctrl : std_logic_vector (7 downto 0);
signal main_reg_out_decoder_enable : std_logic; --is one when the rom produces Rc out, zero other wise
signal main_reg_out_decoder_selection : std_logic_vector(2 downto 0); --either Rsrc or Rdst depending on cycle

signal sig_curr_addressing_mode : std_logic_vector(1 downto 0);

signal sig_cycle_in_selection : std_logic_vector(0 downto 0);
signal sig_cycle_in_decoder_enable : std_logic;
signal sig_cycle_in_decoder_output : std_logic_vector (1 downto 0);

signal sig_Rcycle_in_decoder_enable :  std_logic;
signal sig_Rcycle_in_decoder_output : std_logic_vector (7 downto 0);

signal reset_from_end_latched : std_logic;
begin

    sig_not_clk <= not i_clk;

    sig_not_hlt <= '0' when ( i_ir(15 downto 11) = HLT_OPCODE)
    else           '1';

    sig_cmp <= '1' when (i_ir(15 downto 11) = CMP_OPCODE)
    else '0';

    sig_mov <= '1' when ( i_ir(15 downto 11) = MOV_OPCODE)
    else       '0';

    sig_n_ops <= "00" when ( i_ir(15 downto 11) > LOW_BOUND_ZERO_OP and i_ir(15 downto 11) <= HIGH_BOUND_ZERO_OP )
    else         "01" when ( i_ir(15 downto 11) > LOW_BOUND_ONE_OP and i_ir(15 downto 11) < HIGH_BOUND_ONE_OP)
    else         "10";

    sig_spec_op <= "00" when ( i_ir(15 downto 11) = NO_OP_OPCODE)
    else           "01" when ( i_ir(15 downto 11) = JSR_OP_OPCODE)
    else           "10" when ( i_ir(15 downto 11) = RTS_OP_OPCODE)
    else           "11" ;

    -- Check hard or soft reset (!!! sig_reset_mircopc not initialized)
    sig_reset_mircopc <= i_reset or sig_end(0);

    micro_pc : MicroPC port map(sig_not_clk, sig_not_hlt, sig_reset_mircopc, sig_branch, sig_pla_out,
                                sig_micropc_out);

    instr_rom : Rom port map( i_clk, sig_micropc_out, 
                        sig_inc_cycle, sig_dirty_bit, sig_read, sig_write, sig_end_from_rom(0), sig_branch,
                        sig_alu_ctrl, sig_reg_in_ctrl_second_group,
                        sig_reg_out_ctrl, sig_reg_in_ctrl_first_group);
    
    sig_end(0) <= sig_end_from_rom(0) or sig_branch_end;

    end_latch : D_flipflop generic map(1) port map(sig_not_clk, '1', i_reset, sig_end , sig_end_latched); 
    reset_from_end_latched <= sig_end_latched(0) or i_reset;


    dirty_latch :  T_flipflop port map(sig_not_clk, reset_from_end_latched, sig_dirty_bit, sig_dirty_bit_latched);
    
    cycle_counter : Counter generic map(2) port map (sig_not_clk,sig_inc_cycle,reset_from_end_latched,sig_num_cycle_new);
    cycle_latch : D_flipflop generic map(2) port map (i_clk,'1',i_reset,sig_num_cycle_new,sig_num_cycle_old);

    sig_curr_addressing_mode <= i_ir(10 downto 9) when sig_num_cycle_new = CYC_ZERO else i_ir(5 downto 4);

    dispatcher : PLA port map(sig_mov, sig_dirty_bit_latched,sig_cmp ,sig_n_ops, sig_spec_op, sig_curr_addressing_mode, sig_num_cycle_new, sig_pla_out);

    --RCycle out decoder
    main_reg_out_decoder_enable <= '1' when  sig_reg_out_ctrl = Rc_OUT else '0'; 
    main_reg_out_decoder_selection <= i_ir(8 downto 6) when sig_num_cycle_old = CYC_ZERO else i_ir(3 downto 1); --Src registers if cycle = 0 else dest registers
    primary_registers_out_decoder : NBitDecoder generic map(3) port map(main_reg_out_decoder_selection,main_reg_out_decoder_enable,sig_main_reg_out_ctrl);


    --Register Output Signals        
    o_r0_out <= sig_main_reg_out_ctrl(0);
    o_r1_out <= sig_main_reg_out_ctrl(1);
    o_r2_out <= sig_main_reg_out_ctrl(2);
    o_r3_out <= sig_main_reg_out_ctrl(3);
    o_sp_out <= '1' when (sig_main_reg_out_ctrl(4) = '1') or (sig_reg_out_ctrl = SP_OUT) else '0';
    o_pc_out <= '1' when (sig_main_reg_out_ctrl(5) = '1') or (sig_reg_out_ctrl = PC_OUT) else '0';
    o_mdr_out <= '1' when sig_reg_out_ctrl = MDR_OUT else '0';
    o_ir_out <= '1' when sig_reg_out_ctrl = IR_OUT else '0';
    o_src_out <= '1' when sig_reg_out_ctrl = SRC_OUT else '0';
    o_z_out <= '1' when sig_reg_out_ctrl = Z_OUT else '0';

    --Memory Read and write signals
    o_mem_read <= sig_read;
    o_mem_write <= sig_write;

    o_alu_op <= i_ir(15 downto 11) when sig_alu_ctrl = ALU_IR_OP 
    else INC_OPCODE when sig_alu_ctrl = ALU_INC
    else DEC_OPCODE when sig_alu_ctrl = ALU_DEC
    else ADD_OPCODE when sig_alu_ctrl = ALU_ADD;

    --Cycle in decoder, produces either src in or y in
    sig_cycle_in_selection <= "0" when  sig_num_cycle_old = CYC_ZERO else "1";
    sig_cycle_in_decoder_enable <= '1' when sig_reg_in_ctrl_first_group = CYCLE_IN else '0';
    cycle_in_decoder : NBitDecoder generic map(1) port map(sig_cycle_in_selection,sig_cycle_in_decoder_enable,sig_cycle_in_decoder_output);

    o_src_in <= sig_cycle_in_decoder_output(0);
    o_y_in <= '1' when sig_cycle_in_decoder_output(1) = '1' or sig_reg_in_ctrl_first_group = Y_IN else '0';
    o_mar_in <= '1' when sig_reg_in_ctrl_first_group = MAR_IN else '0';
    o_mdr_in <= '1' when sig_reg_in_ctrl_first_group = MDR_IN else '0';
    o_ir_in <= '1' when sig_reg_in_ctrl_first_group = IR_IN else '0';
    o_flag_in <= '1' when (sig_alu_ctrl = ALU_IR_OP)  and (i_ir(15 downto 11) /= CMP_OPCODE) else '0';

    --RCycle in decoder
    sig_Rcycle_in_decoder_enable <= '1' when sig_reg_in_ctrl_second_group = Rc_IN else '0';
    Rcycle_in_decoder : NBitDecoder generic map(3) port map(main_reg_out_decoder_selection,sig_Rcycle_in_decoder_enable,sig_Rcycle_in_decoder_output);


    --Remaining In signals
    o_r0_in <= sig_Rcycle_in_decoder_output(0);
    o_r1_in <= sig_Rcycle_in_decoder_output(1);
    o_r2_in <= sig_Rcycle_in_decoder_output(2);
    o_r3_in <= sig_Rcycle_in_decoder_output(3);
    o_sp_in <= '1' when (sig_Rcycle_in_decoder_output(4) = '1') or (sig_reg_in_ctrl_first_group = SP_IN) else '0';
    o_pc_in <= '1' when (sig_Rcycle_in_decoder_output(5) = '1') or (sig_reg_in_ctrl_second_group = PC_IN) else '0';
    o_z_in  <= '1' when sig_reg_in_ctrl_second_group = Z_IN else '0';



    --Branch Circuitry
    sig_branch_end <= '0' when 
    (i_ir(15 downto 11) = UNCONDITIONAL_BRANCH_OPCODE) or (i_ir(15 downto 11) = EQUAL_BRANCH_OPCODE and i_flag(1) = '1' ) or
    (i_ir(15 downto 11) = NOTEQUAL_BRANCH_OPCODE and i_flag(1) = '0' ) or (i_ir(15 downto 11) = LOWER_BRANCH_OPCODE and i_flag(0) = '0' ) or
    (i_ir(15 downto 11) = LOWERORSAME_BRANCH_OPCODE and ((i_flag(0) = '0') or(i_flag(1) = '1')) ) or
    (i_ir(15 downto 11) = HIGHER_BRANCH_OPCODE and i_flag(0) = '1' ) or
    (i_ir(15 downto 11) = HIGHERORSAME_BRANCH_OPCODE and ((i_flag(0) = '1') or(i_flag(1) = '1')) ) or
    (i_ir(15 downto 11) > HIGHERORSAME_BRANCH_OPCODE or i_ir(15 downto 11) < UNCONDITIONAL_BRANCH_OPCODE)
    else '1';


end arch;
