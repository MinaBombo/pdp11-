library ieee;
use ieee.std_logic_1164.all;

entity system is
    port 
    (
        i_clk,i_reset : std_logic
    );
end entity system;

architecture system_arch of system is

component CU is
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

        o_alu_op : out std_logic_vector(4 downto 0);
        o_reset : out std_logic);
end component;

component NBitRegister is
    generic(w : natural := 32);
    port(clk, in_enable,out_enable, reset : in std_logic;
        d : in std_logic_vector(w-1 downto 0);
          
        q : out std_logic_vector(w-1 downto 0)); 
end component;

component D_flipflop is
    generic(w : natural := 32);
    port(clk, enable, reset : in std_logic;
        d : in std_logic_vector(w-1 downto 0);
          
        q : out std_logic_vector(w-1 downto 0)); 
end component;

component TriStateBuffer IS
generic(w : natural := 32);
PORT (
	InputSignal : IN STD_LOGIC_VECTOR(w-1 downto 0) ;
	ControlSignal : IN STD_LOGIC ;
	OutputSignal : OUT STD_LOGIC_VECTOR(w-1 downto 0) 
      );
END component;

component Ram is
    port(clk, w_en : in std_logic;
        addr    : in std_logic_vector(10 downto 0);
        data_in : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)); 
end component;

signal sig_cu_r0_in, sig_cu_r1_in, sig_cu_r2_in, sig_cu_r3_in     :  std_logic;
signal sig_cu_r0_out, sig_cu_r1_out, sig_cu_r2_out, sig_cu_r3_out :  std_logic;

signal sig_cu_sp_in, sig_cu_pc_in, sig_cu_mar_in, sig_cu_mdr_in, sig_cu_flag_in, sig_cu_ir_in :  std_logic;
signal sig_cu_sp_out, sig_cu_pc_out, sig_cu_mdr_out, sig_cu_ir_out :  std_logic;

signal sig_cu_src_in, sig_cu_y_in, sig_cu_z_in :  std_logic;
signal sig_cu_src_out, sig_cu_z_out       :  std_logic;

signal sig_cu_mem_read, sig_cu_mem_write :  std_logic;

signal sig_cu_alu_op :  std_logic_vector(4 downto 0);
signal sig_cu_reset :  std_logic;

signal flag_in, flag_out : std_logic_vector(1 downto 0); 
signal ir_out : std_logic_vector(15 downto 0);
signal not_clk : std_logic;
signal y_out: std_logic_vector(31 downto 0);

signal data_bus: std_logic_vector(31 downto 0);

signal ir_out_to_bus : std_logic_vector(31 downto 0);

signal mar_out : std_logic_vector (10 downto 0);
signal mdr_out : std_logic_vector(31 downto 0);
signal mdr_input_data : std_logic_vector(31 downto 0);
signal mdr_in_enable : std_logic;

signal ram_out : std_logic_vector (31 downto 0);
begin
    not_clk <= not i_clk;
    cu_instance : CU port map (not_clk, i_reset, flag_out, ir_out, sig_cu_r0_in, sig_cu_r1_in, sig_cu_r2_in, sig_cu_r3_in,
                               sig_cu_r0_out, sig_cu_r1_out, sig_cu_r2_out, sig_cu_r3_out,
                               sig_cu_sp_in, sig_cu_pc_in, sig_cu_mar_in, sig_cu_mdr_in, sig_cu_flag_in, sig_cu_ir_in,
                               sig_cu_sp_out, sig_cu_pc_out, sig_cu_mdr_out, sig_cu_ir_out,
                               sig_cu_src_in, sig_cu_y_in, sig_cu_z_in,
                               sig_cu_src_out, sig_cu_z_out,
                               sig_cu_mem_read, sig_cu_mem_write,
                               sig_cu_alu_op,
                               sig_cu_reset);
    
    flag: NBitRegister generic map (2)  port map (i_clk, sig_cu_flag_in, '1',            sig_cu_reset, flag_in, flag_out );
    src : NBitRegister generic map (32) port map (i_clk, sig_cu_src_in,  sig_cu_src_out, sig_cu_reset, data_bus, data_bus);
    y   : NBitRegister generic map (32) port map (i_clk, sig_cu_y_in,    '1',            sig_cu_reset, data_bus, y_out   );
    z   : NBitRegister generic map (32) port map (i_clk, sig_cu_z_in,    sig_cu_z_out,   sig_cu_reset, data_bus, data_bus);
    
    r0  : NBitRegister generic map (32) port map (i_clk, sig_cu_r0_in,   sig_cu_r0_out,  sig_cu_reset, data_bus, data_bus);
    r1  : NBitRegister generic map (32) port map (i_clk, sig_cu_r1_in,   sig_cu_r1_out,  sig_cu_reset, data_bus, data_bus);
    r2  : NBitRegister generic map (32) port map (i_clk, sig_cu_r2_in,   sig_cu_r2_out,  sig_cu_reset, data_bus, data_bus);
    r3  : NBitRegister generic map (32) port map (i_clk, sig_cu_r3_in,   sig_cu_r3_out,  sig_cu_reset, data_bus, data_bus);

    pc  : NBitRegister generic map (16) port map (i_clk, sig_cu_pc_in,   sig_cu_pc_out,  sig_cu_reset, data_bus(15 downto 0), data_bus(15 downto 0));
    sp  : NBitRegister generic map (16) port map (i_clk, sig_cu_sp_in,   sig_cu_sp_out,  sig_cu_reset, data_bus(15 downto 0), data_bus(15 downto 0));

    --IR
    ir  : D_flipflop generic map (16) port map (i_clk, sig_cu_ir_in,  sig_cu_reset, data_bus(15 downto 0), ir_out);

    ir_out_to_bus(15 downto 0) <= ir_out;
    ir_out_to_bus(31 downto 16) <= (others => '0');
    ir_tri_state_buffer : TriStateBuffer generic map(32) port map(ir_out_to_bus,sig_cu_ir_out,data_bus);
    --
    --mdr
    mdr_in_enable <= sig_cu_mem_read or sig_cu_mdr_in;
    mdr_input_data <= ram_out when sig_cu_mem_read = '1' else data_bus;
    mdr : D_flipflop generic map (32) port map (i_clk, mdr_in_enable,  sig_cu_reset, mdr_input_data, mdr_out);
    mdr_tri_state_buffer : TriStateBuffer generic map(32) port map(mdr_out,sig_cu_mdr_out,data_bus);
    --RAM

    ram_component : Ram port map (not_clk ,sig_cu_mem_read,mar_out,mdr_out,ram_out);

    --MAR 
    mar : D_flipflop generic map (11) port map (i_clk,sig_cu_mar_in,sig_cu_reset,data_bus(10 downto 0),mar_out);

end system_arch ; -- 