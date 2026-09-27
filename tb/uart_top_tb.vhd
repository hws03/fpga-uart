library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity uart_top_tb is
end uart_top_tb;

architecture Behavioral of uart_top_tb is

component uart_top is port(
        clk: in std_logic;
        final_o: out std_logic_vector(7 downto 0);
        data_in: in std_logic_vector(7 downto 0);
        start_tx: in std_logic;
        tl_reset: in std_logic;
        valid_rx: out std_logic;
        tl_uart_tx: out std_logic;
        tl_uart_rx: in std_logic;   
        tl_busy_tx: out std_logic
);
end component;


signal clk_tb: std_logic := '0';
constant clk_period: time := 5 ns;


signal final_o_tb: std_logic_vector(7 downto 0);
signal data_in_tb: std_logic_vector(7 downto 0);
signal start_tb: std_logic := '0';
signal valid_tb: std_logic;
signal reset_tb: std_logic;
signal tb_uart_tx: std_logic;
signal tb_uart_rx: std_logic;
signal tb_busy_rx: std_logic;

begin

uut: uart_top port map(
    clk => clk_tb,
    final_o => final_o_tb,
    data_in => data_in_tb,
    start_tx => start_tb,
    valid_rx => valid_tb,
    tl_reset => reset_tb,
    tl_uart_tx => tb_uart_tx,
    tl_uart_rx => tb_uart_rx,
    tl_busy_tx => tb_busy_rx
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
    start_tb <= '0';
    data_in_tb <= "11001011";

    wait for 20 ns;

    start_tb <= '1';
    wait for 150 us;   

    start_tb <= '0';

    wait for 5 ms; 
    wait;
end process;


end Behavioral;
