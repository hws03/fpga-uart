library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity uart_top is
  generic(
    clk_freq: integer := 100000000;
    baudrate: integer := 9600
    );
    port ( 
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
end uart_top;

architecture Behavioral of uart_top is



component baud_rate is 
generic(
    clk_freq: integer := 100000000;
    baudrate: integer := 9600
);
port(
    clk: in std_logic;
    BaudRateGen: out std_logic
);
end component;


--component baud_rate_16x is 
--generic(
--    clk_freq: integer := 100000000;
--    baudrate: integer := 153600
--);
--port(
--    clk: in std_logic;
--    BaudRateGen_16x: out std_logic
--);
--end component;

component Tx is 
generic(
    data_bits: integer := 8;
    stop_bit: integer := 1
);
port (
    clk: in std_logic;
    BaudRateGen: in std_logic;
    data_tx: in std_logic_vector(7 downto 0);
    start_tx: in std_logic;
    reset_tx: in std_logic; 
    busy_tx: out std_logic;
    serial_tx: out std_logic
);
end component; 


component Rx is 
generic(
    data_bits: integer := 8;
    stop_bit: integer := 1
);
port(
    clk: in std_logic;
    BaudRateGen: in std_logic;
    serial_rx: in std_logic;
    reset_rx: in std_logic; 
    
    valid_rx: out std_logic;
    data_rx: out std_logic_vector(7 downto 0)
);
end component; 


signal tl_baudrate: std_logic;
signal tl_baudrate_16x: std_logic;

signal tl_data: std_logic_vector(7 downto 0);
signal tl_start_tx: std_logic;
signal tl_serial: std_logic;


signal tl_valid_rx: std_logic;
signal tl_final_o: std_logic_vector(7 downto 0);

signal tl_reset_tx: std_logic;
signal tl_reset_rx: std_logic;

--signal tl_busy_tx: std_logic;

begin


baud_rate_instance: baud_rate 
generic map(
    clk_freq => clk_freq,
    baudrate => baudrate
)
port map(
    clk => clk,
    BaudRateGen => tl_baudrate
);


baud_rate_16x_instance: baud_rate
generic map(
    clk_freq => clk_freq,
    baudrate => baudrate * 16
)
port map(
    clk => clk,
    BaudRateGen => tl_baudrate_16x
);


Tx_instance: Tx 
generic map(
    data_bits => 8,
    stop_bit => 1
)
port map(
    clk => clk,
    BaudRateGen => tl_baudrate,
    data_tx => tl_data,
    start_tx => tl_start_tx,
    busy_tx => tl_busy_tx,
    serial_tx => tl_serial, --
    reset_tx => tl_reset_tx
);


Rx_instance: Rx 
generic map(
    data_bits => 8,
    stop_bit => 1
)
port map (
    clk => clk,
    BaudRateGen => tl_baudrate_16x,
    serial_rx => tl_rx_serial, -- tl_serial
    reset_rx => tl_reset_rx,
    valid_rx => tl_valid_rx,
    data_rx => tl_final_o -- final 8 bit std_logic_vector output 
);



--------------------------
tl_tx_serial <= tl_serial;

final_o <= tl_final_o;

tl_data <= data_in;

tl_start_tx <= start_tx;

valid_rx <= tl_valid_rx;

tl_reset_tx <= tl_reset;
tl_reset_rx <= tl_reset;
--------------------------


end Behavioral;