--BaudRate: used to downscale the clock to match communication rate

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 


entity baud_rate is
  generic(
    clk_freq: integer := 100000000;
    baudrate: integer := 9600
  );
  port (
    clk: in std_logic;
    BaudRateGen: out std_logic
   );
end baud_rate;


architecture RTL of baud_rate is


--constant baud_tick: unsigned(13 downto 0) := to_unsigned(10416, 14); --threshold (counter upper limit) 100MHz / 9600 = 10416 (10100010110000)

constant baud_tick: integer := clk_freq / baudrate;
signal baud_counter: integer range 0 to baud_tick - 1 := 0; --unsigned(13 downto 0) := (others => '0');

begin

process(clk)
begin
    if rising_edge(clk) then
        BaudRateGen <= '0'; --set tick back to 0
        if baud_counter = baud_tick - 1 then --when counter reaches our set limit (10416) for 9600 baud, generate a tick
            baud_counter <= 0; --(others => '0'); --reset counter
            BaudRateGen <= '1'; --tick generation
        else 
            baud_counter <= baud_counter + 1; --count up
        end if;
    end if;
end process;

end RTL;