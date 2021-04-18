

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity imageProcessTop is
  Port (axi_clk: in std_logic;
        axi_reset_n: in std_logic;
        --slave interface         
        i_data_valid: in std_logic;         
        i_data: in std_logic_vector(7 downto 0); 
        o_data_ready: out std_logic;
        --master interface
        o_data_valid: out std_logic;
        o_data: out std_logic_vector(7 downto 0);
        i_dara_ready: in std_logic;
        --interrupt
        o_intr: out std_logic
        );
end imageProcessTop;

architecture Behavioral of imageProcessTop is
component imageControl is
Port (  i_clk: in std_logic;
        i_rst: in std_logic;
        i_pixel_data: in std_logic_vector(7 downto 0);
        i_pixel_data_valid: in std_logic;
        o_pixel_data_valid: out std_logic;
        o_pixel_data: out std_logic_vector(71 downto 0);
        o_intr: out std_logic
        );
end component;

component conv is
  Port (i_clk: in std_logic;
        i_pixel_data: in std_logic_vector(71 downto 0);
        i_pixel_data_valid: in std_logic;
        o_convolved_data: out std_logic_vector(7 downto 0);
        o_convolved_data_valid: out std_logic
         );
end component;

COMPONENT outputBuffer
  PORT (
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC;
    s_aclk : IN STD_LOGIC;
    s_aresetn : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    axis_prog_full : OUT STD_LOGIC
  );
END COMPONENT;


signal pixel_data: std_logic_vector(71 downto 0):= (others =>'0');
signal pixel_data_valid: std_logic:='0';
signal not_axi_reset_n: std_logic:='0';
signal axis_prog_full: std_logic:='0';
signal convolved_data_valid: std_logic:='0';
signal convolved_data: std_logic_vector(7 downto 0):= (others =>'0');

begin
o_data_ready <= not(axis_prog_full);
not_axi_reset_n <= not(axi_reset_n);
IC : imageControl port map(
                            i_clk => axi_clk,
                            i_rst => not_axi_reset_n,
                            i_pixel_data => i_data,
                            i_pixel_data_valid => i_data_valid,
                            o_pixel_data_valid => pixel_data_valid, 
                            o_pixel_data => pixel_data,
                            o_intr => o_intr
                            );
                            
convl: conv port map(
                    i_clk => axi_clk,
                    i_pixel_data => pixel_data,
                    i_pixel_data_valid => pixel_data_valid,
                    o_convolved_data => convolved_data,
                    o_convolved_data_valid => convolved_data_valid
                     );

OB : outputBuffer
  PORT MAP (
    s_aclk => axi_clk,
    s_aresetn => axi_reset_n,
    s_axis_tvalid => convolved_data_valid,
    s_axis_tdata => convolved_data,
    m_axis_tvalid => o_data_valid,
    m_axis_tready => i_dara_ready,
    m_axis_tdata => o_data,
    axis_prog_full => axis_prog_full
  );
  
                      
end Behavioral;
