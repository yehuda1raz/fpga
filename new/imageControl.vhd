

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;



entity imageControl is
Port (  i_clk: in std_logic;
        i_rst: in std_logic;
        i_pixel_data: in std_logic_vector(7 downto 0);
        i_pixel_data_valid: in std_logic;
        o_pixel_data_valid: out std_logic;
        o_pixel_data: out std_logic_vector(71 downto 0);
        o_intr: out std_logic
        );
end imageControl;

architecture Behavioral of imageControl is
constant width: integer := 511;
component lineBuffer is
  Port (i_clk: in std_logic;
        i_rst: in std_logic;
        i_data: in std_logic_vector(7 downto 0);
        i_data_valid: in std_logic;
        o_data: out std_logic_vector(23 downto 0);
        i_rd_data: in std_logic );
end component;

signal pixel_counter: unsigned(8 downto 0):= (others =>'0');
signal currentWrLineBuffer: unsigned(1 downto 0):= (others =>'0');
signal lineBuffDataValid : unsigned(3 downto 0):= (others =>'0');
signal currentRdLineBuffer: unsigned(1 downto 0):= (others =>'0');
signal lb0data,lb1data,lb2data,lb3data : std_logic_vector(23 downto 0):= (others =>'0');
signal rdCounter: unsigned(8 downto 0):= (others =>'0');
signal lineBuffRdData: unsigned(3 downto 0):= (others =>'0');
signal rd_line_buffer: std_logic:= '0';
signal totalPixelCounter: unsigned(11 downto 0):= (others =>'0');
signal rdState: std_logic:= '0';
constant IDLE: std_logic := '0';
constant RD_BUFFER: std_logic := '1';
begin
LB0 : lineBuffer port map ( i_clk => i_clk,
                            i_rst => i_rst,
                            i_data => i_pixel_data,
                            i_data_valid => lineBuffDataValid(0),
                            o_data => lb0data,
                            i_rd_data => lineBuffRdData(0)
                  );
LB1 : lineBuffer port map ( i_clk => i_clk,
                            i_rst => i_rst,
                            i_data => i_pixel_data,
                            i_data_valid => lineBuffDataValid(1),
                            o_data => lb1data,
                            i_rd_data => lineBuffRdData(1));
LB2 : lineBuffer port map ( i_clk => i_clk,
                            i_rst => i_rst,
                            i_data => i_pixel_data,
                            i_data_valid => lineBuffDataValid(2),
                            o_data => lb2data,
                            i_rd_data => lineBuffRdData(2));
LB3 : lineBuffer port map ( i_clk => i_clk,
                            i_rst => i_rst,
                            i_data => i_pixel_data,
                            i_data_valid => lineBuffDataValid(3),
                            o_data => lb3data,
                            i_rd_data => lineBuffRdData(3)
                  );
                  
o_pixel_data_valid <= rd_line_buffer;                  
process(i_clk)
begin
if rising_edge (i_clk) then
    if i_rst = '1' then
        totalPixelCounter <= x"000";
    else 
        if  (i_pixel_data_valid = '1') and (rd_line_buffer ='0')  then
            totalPixelCounter <= totalPixelCounter + 1;   
        elsif ((i_pixel_data_valid = '0') and (rd_line_buffer ='1'))  then
            totalPixelCounter <= totalPixelCounter - 1;    
        end if;
    end if;
end if;    
end process;
    
process(i_clk)
begin
if rising_edge (i_clk) then
    if i_rst = '1' then
        rdState <= IDLE;
        rd_line_buffer <= '0';
        o_intr <= '0';
    else  
        case (rdState) is
        when IDLE =>
                    o_intr <= '0'; 
                    if(totalPixelCounter >= (width+1)*3) then
                        rd_line_buffer <= '1';
                        rdstate <= RD_BUFFER;
                    end if;  
        when others => 
                    if(rdcounter = width) then
                        rd_line_buffer <= '0';
                        rdstate <= IDLE;
                        o_intr <= '1';
                    end if;
        end case;            
     end if;
end if;                                  
end process;
                
process(i_clk)
begin
if rising_edge (i_clk) then
    if i_rst = '1' then
        pixel_counter<= "000000000";
    else 
        if  i_pixel_data_valid = '1' then
        pixel_counter <= pixel_counter + 1;          
        end if;
    end if;
end if;    
end process;
 
process(i_clk)
begin
if rising_edge (i_clk) then
     if i_rst = '1' then
        currentWrLineBuffer<= "00";   
     else
        if (pixel_counter = width) and  i_pixel_data_valid = '1' then
            currentWrLineBuffer <= currentWrLineBuffer +1;
        end if;
     end if;
end if;
end process;              

process(i_clk)
variable lineBuffDataValid_t : unsigned(3 downto 0) := x"0";
begin
lineBuffDataValid_t := x"0";
lineBuffDataValid_t(to_integer(currentWrLineBuffer)) := i_pixel_data_valid; 
lineBuffDataValid <= lineBuffDataValid_t;
end process;

process(i_clk)
begin
case (currentRdLineBuffer) is 
     when "00" => lineBuffRdData(0) <= rd_line_buffer;
                  lineBuffRdData(1) <= rd_line_buffer;
                  lineBuffRdData(2) <= rd_line_buffer;
                  lineBuffRdData(3) <= '0';
     when "01" => lineBuffRdData(0) <= '0';
                  lineBuffRdData(1) <= rd_line_buffer;
                  lineBuffRdData(2) <= rd_line_buffer;
                  lineBuffRdData(3) <= rd_line_buffer;
     when "10" => lineBuffRdData(0) <= rd_line_buffer;
                  lineBuffRdData(1) <= '0';
                  lineBuffRdData(2) <= rd_line_buffer;
                  lineBuffRdData(3) <= rd_line_buffer;
     when others => lineBuffRdData(0) <= rd_line_buffer;
                  lineBuffRdData(1) <= rd_line_buffer;
                  lineBuffRdData(2) <= '0';
                  lineBuffRdData(3) <= rd_line_buffer;
end case;
end process;

process(i_clk)
begin
case (currentRdLineBuffer) is 
     when "00" => o_pixel_data <= (lb2data&lb1data&lb0data);
     when "01" => o_pixel_data <= (lb3data&lb2data&lb1data);
     when "10" => o_pixel_data <= (lb0data&lb3data&lb2data);
     when others => o_pixel_data <= (lb1data&lb0data&lb3data);
     
end case;
end process;

process(i_clk)
begin
if rising_edge (i_clk) then
    if i_rst = '1' then
        rdCounter<= "000000000";
    else 
        if  rd_line_buffer = '1' then
        rdCounter <= rdCounter + 1;          
        end if;
    end if;
end if;    
end process;

process(i_clk)
begin
if rising_edge (i_clk) then
    if i_rst = '1' then
        currentRdLineBuffer<= "00";   
    else
        if  (rdCounter = (width)) and (rd_line_buffer = '1') then
             currentRdLineBuffer <= currentRdLineBuffer +1;
        end if;
    end if;
end if;
end process;
end Behavioral;
