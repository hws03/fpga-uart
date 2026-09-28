library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Tx_tb is
end Tx_tb;

architecture Behavioral of Tx_tb is

component Tx is port (
      clk: in std_logic;
      BaudRateGen: in std_logic;
      data_tx: in std_logic_vector(7 downto 0);
      start_tx: in std_logic;
      serial_tx: out std_logic  
    );
end component;

signal clk_tb: std_logic := '0';
constant clk_period: time := 5 ns;

signal BRG_tb: std_logic;
signal data_tx_tb: std_logic_vector(7 downto 0);
signal start_tx_tb: std_logic;
signal serial_tx_tb: std_logic; 

begin

uut: Tx  port map(
    clk => clk_tb,
    BaudRateGen => BRG_tb,
    data_tx => data_tx_tb,
    start_tx => start_tx_tb,
    serial_tx => serial_tx_tb
);


clock: process
    begin
        while true loop
            clk_tb <= '1';
            wait for clk_period;
            clk_tb <= '0';
            wait for clk_period;
        end loop;
end process;

Transmit: process
    begin
        data_tx_tb <= "01010101";
        wait for 10 ns;
        wait;
end process;

end Behavioral;