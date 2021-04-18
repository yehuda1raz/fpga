

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
entity lineBuffer is
  Port (i_clk: in std_logic;
        i_rst: in std_logic;
        i_data: in std_logic_vector(7 downto 0);
        i_data_valid: in std_logic;
        o_data: out std_logic_vector(23 downto 0);
        i_rd_data: in std_logic );
end lineBuffer;

architecture Behavioral of lineBuffer is
constant width: integer := 511;

type reg is array (width downto 0) of std_logic_vector(7 downto 0); 
signal line_b: reg;
signal wrPntr: unsigned(8 downto 0):= (others =>'0');
signal rdPntr: unsigned(8 downto 0):= (others =>'0');
begin

process(i_clk)
begin
if rising_edge (i_clk) then
if i_data_valid = '1' then 
    line_b(to_integer(wrPntr))(7 downto 0) <= i_data;
    end if;
end if;
end process;

process(i_clk)
begin
if rising_edge (i_clk) then
if i_rst = '1' then 
    wrPntr <= (others =>'0');
    
elsif (i_data_valid = '1') then
    wrPntr <= wrPntr + 1;               --??

    end if;
    end if;
end process;

o_data <= (line_b(to_integer(rdPntr))(7 downto 0)&line_b(to_integer(rdPntr+1))(7 downto 0)&line_b(to_integer(rdPntr+2))(7 downto 0));

process(i_clk)
begin
if rising_edge (i_clk) then

if i_rst = '1' then 
    rdPntr <= (others =>'0');
    
elsif (i_rd_data = '1') then
    rdPntr <= rdPntr + 1;               --??

    end if;
    end if;
end process;
end Behavioral;
