library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_top_tb2 is
end uart_top_tb2;

architecture Behavioral of uart_top_tb2 is

component uart_top is 
port(
    clk: in std_logic;
    final_o: out std_logic_vector(7 downto 0);
    data_in: in std_logic_vector(7 downto 0);
    start_tx: in std_logic;
    tl_reset: in std_logic;
    valid_rx: out std_logic;
    tl_tx_serial: out std_logic;
    tl_rx_serial: in std_logic;   
    tl_busy_tx: out std_logic
);
end component;

signal clk_tb: std_logic := '0';

constant clk_period: time := 10 ns;

signal final_o_tb: std_logic_vector(7 downto 0);
signal data_in_tb: std_logic_vector(7 downto 0) := (others => '0');
signal start_tb: std_logic := '0';
signal valid_tb: std_logic;
signal reset_tb: std_logic := '0';
signal tb_tx_serial: std_logic;
signal tb_rx_serial: std_logic := '1';
signal tb_busy_tx: std_logic;

begin

uut: uart_top 
port map(
    clk => clk_tb,
    final_o => final_o_tb,
    data_in => data_in_tb,
    start_tx => start_tb,
    valid_rx => valid_tb,
    tl_reset => reset_tb,
    tl_tx_serial => tb_tx_serial,
    tl_rx_serial => tb_rx_serial,
    tl_busy_tx => tb_busy_tx
);

--connect Tx output back into Rx input
tb_rx_serial <= tb_tx_serial;

clock: process
begin
    while true loop
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end loop;
end process;

Transmit: process
begin
    --initial values
    start_tb   <= '0';
    data_in_tb <= "11001011";

    --reset pulse
    reset_tb <= '1';
    wait for 100 us;
    reset_tb <= '0';

    wait for 100 us;

    --start transmission
    start_tb <= '1';
    wait for 200 us;
    
    reset_tb <= '1';
    wait for 100 us;
    reset_tb <= '0';
    
    --hold start long enough for Tx to catch baud tick
    wait until tb_busy_tx = '1';

    start_tb <= '0';

    --wait for RX to receive byte
    wait until valid_tb = '1';

    assert final_o_tb = "11001011"
        report "UART loopback failed"
        severity error;

    wait for 1 ms;

    wait;
end process;

end Behavioral;