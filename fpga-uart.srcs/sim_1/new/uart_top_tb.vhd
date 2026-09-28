library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_top_tb is
end uart_top_tb;

architecture Behavioral of uart_top_tb is

component uart_top is
generic(
    clk_freq: integer := 100000000;
    baudrate: integer := 9600
); 
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

constant clk_freq: integer:= 100000000;
constant baudrate: integer:= 9600;

signal clk_tb: std_logic := '0';
constant clk_period: time := 10 ns;

signal final_o_tb: std_logic_vector(7 downto 0);
signal data_in_tb: std_logic_vector(7 downto 0) := (others => '0');
signal start_tb: std_logic := '0';
signal valid_tb: std_logic;
signal reset_tb: std_logic := '0';
signal tx_serial_tb: std_logic;
signal rx_serial_tb: std_logic := '1';
signal busy_tx_tb: std_logic;

begin

uut: uart_top
generic map(
    clk_freq => clk_freq,
    baudrate => baudrate
)  
port map(
    clk => clk_tb,
    final_o => final_o_tb,
    data_in => data_in_tb,
    start_tx => start_tb,
    valid_rx => valid_tb,
    tl_reset => reset_tb,
    tl_tx_serial => tx_serial_tb,
    tl_rx_serial => rx_serial_tb,
    tl_busy_tx => busy_tx_tb
);




clock: process
begin
    while true loop
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end loop;
end process;


--connect Tx output back into Rx input
rx_serial_tb <= tx_serial_tb;


----------------------------------
STIMULUS: process

procedure test(constant value: in std_logic_vector(7 downto 0)) is
begin
    wait until rising_edge(clk_tb);
    data_in_tb <= value;
    start_tb <= '1';
    
    wait until rising_edge(clk_tb) and busy_tx_tb = '1';
    start_tb <= '0';
    
    wait until rising_edge(clk_tb) and valid_tb = '1' for 1.5 ms;
    
    assert valid_tb = '1'
        report "ERROR: no valid_rx"
        severity error;
    
    assert final_o_tb = value
        report "ERROR 1: UART output does not match tb values"
        severity error;
    
    if (valid_tb = '1' and final_o_tb = value) then    
        report "PASSED 1: UART output matches tb values";
    end if;
    
    wait for 50 us;
end procedure;



begin

    --reset functionality
    reset_tb <= '1';
    wait for 100 ns;
    reset_tb <= '0';
    wait for 100 ns;


    test("10101010");
    test("11011011");
    test("01010101");
    test("10101010");
    test("00000000");
    test("11111111");
    
    report "PASSED FULLY"
    severity note;
    
    wait;
    
end process;

end Behavioral;



--constant expected: std_logic_vector(7 downto 0):= "11001011";

--    --provide data in
--    data_in_tb <= expected;
    
--    --start transmission
--    start_tb <= '1';
    
--    --hold start_tb until accepted
--    wait until busy_tx_tb = '1';
--    start_tb <= '0';
    
--    --wait for Rx to pulse valid high
--    wait until valid_tb = '1' for 2 ms;
    
--    assert valid_tb = '1'
--        report "valid_rx was never asserted"
--        severity error;
    
--    assert final_o_tb = expected
--        report "UART loopback test failed"
--        severity error;
        
--    report "UART loopback test PASSED"
--    severity note;