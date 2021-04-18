

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity conv is
  Port (i_clk: in std_logic;
        i_pixel_data: in std_logic_vector(71 downto 0):=(others=>'0');
        i_pixel_data_valid: in std_logic;
        o_convolved_data: out std_logic_vector(7 downto 0);
        o_convolved_data_valid: out std_logic
         );
end conv;

architecture Behavioral of conv is
type reg is array (8 downto 0) of signed(8 downto 0); 
type mul is array (8 downto 0) of signed(17 downto 0); 
signal kernel: reg := ("111111111","000000000","000000001","111111110","000000000","000000010","111111111","000000000","000000001");
signal multdata: mul := (others =>x"0000"&"00");
signal sumdata: signed(17 downto 0):= (others =>'0');
signal mult_data_valid: std_logic := '0';
signal sum_data_valid: std_logic := '0';
begin
process(i_clk)
variable i_pixel_data_var: std_logic_vector(8 downto 0):= x"00"&'0'; 
begin
if rising_edge (i_clk) then
    for i in 0 to 8 loop
       i_pixel_data_var := '0'&(i_pixel_data((i*8+7) downto i*8));
       multdata(i) <= (kernel(i))*signed(i_pixel_data_var);
       end loop;
       mult_data_valid <=  i_pixel_data_valid;
    end if;   
end process;

process(i_clk)
variable sum: signed(17 downto 0):= (others =>'0');
begin
if rising_edge (i_clk) then
sum := (others =>'0');
    for i in 0 to 8 loop
        sum := sum + multdata(i);

    end loop;
sum_data_valid <= mult_data_valid;    
sumdata <= sum;
end if;
end process;   

process(i_clk)
begin
if rising_edge (i_clk) then
--    o_convolved_data <= std_logic_vector(resize((unsigned(sumdata)/9),o_convolved_data'length));
    o_convolved_data <= std_logic_vector(resize((unsigned(sumdata)),o_convolved_data'length));
    o_convolved_data_valid <= sum_data_valid;
end if;
end process;     
end Behavioral;
