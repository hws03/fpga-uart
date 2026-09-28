--BaudRate: used to downscale the clock to match communication rate

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 


entity baud_rate_16x is
  generic(
    clk_freq: integer := 100000000;
    baudrate: integer := 153600
  );
  port (
    clk: in std_logic;
    BaudRateGen_16x: out std_logic
   );
end baud_rate_16x;


architecture RTL of baud_rate_16x is

--signal baud_counter_16x: unsigned(13 downto 0) := (others => '0');
--constant baud_tick_16x: unsigned(13 downto 0) := to_unsigned(651, 14); --

constant baud_tick_16x: integer := clk_freq / baudrate;
signal baud_counter_16x: integer range 0 to baud_tick_16x - 1 := 0; 

begin

process(clk)
begin
    if rising_edge(clk) then
        BaudRateGen_16x <= '0'; --set tick back to 0
        if baud_counter_16x = baud_tick_16x - 1 then --when counter reaches our set limit (10416) for 9600 baud, generate a tick
            baud_counter_16x <= 0; --(others => '0'); --reset counter
            BaudRateGen_16x <= '1'; --tick generation
        else
            baud_counter_16x <= baud_counter_16x + 1; --count up
        end if;
    end if;
end process;

end RTL;