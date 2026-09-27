library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 


entity Tx is
    generic (
        data_bits: integer := 8;
        stop_bit: integer := 1
    );
    port ( 
        clk: in std_logic;
        BaudRateGen: in std_logic;
        data_tx: in std_logic_vector((data_bits - 1) downto 0);
        start_tx: in std_logic;
        reset_tx: in std_logic;
        
        busy_tx: out  std_logic;
        serial_tx: out std_logic := '1'
    );
end Tx;



architecture RTL of Tx is

signal bit_index: integer := 0;
constant bit_limit: integer := data_bits - 1;
signal data_buffer_tx: std_logic_vector((data_bits - 1) downto 0) := (others => '0');

signal stop_count: integer := 0;
constant stop_limit: integer := stop_bit - 1;

--FSM signal (enumerated type)
type state_type is (idle, start, data, stop);
signal state_tx: state_type := idle;


begin

process(clk)
begin

if rising_edge(clk) then
    
    ---RESET functionality---
    if reset_tx = '1' then
        serial_tx <= '1';
        data_buffer_tx <= (others => '0');
        bit_index <= 0;
        stop_count <= 0;
        busy_tx <= '0';
        
        state_tx <= idle;
    -----------------------
    
    
    else
        if BaudRateGen = '1' then
    
            case state_tx is
                
            --------IDLE state---------
                when idle =>
                    serial_tx <= '1';
                    busy_tx <= '0';
                    
                    if start_tx = '1' then
                        state_tx <= start;
                    else
                        state_tx <= idle;
                    end if;
            ---------------------------
                       
            
            --------START state--------
                when start =>
                    busy_tx <= '1';
                    serial_tx <= '0';
                    data_buffer_tx <= data_tx;
                    bit_index <= 0;
                    
                    state_tx <= data;
            --------------------------

        
            --------DATA state--------
                when data =>
                    busy_tx <= '1';
                    serial_tx <= data_buffer_tx(bit_index);
                    bit_index <= bit_index + 1;

                    if bit_index = bit_limit then
                        bit_index <= 0;
                        stop_count <= 0;

                        state_tx <= stop;
                    end if;
            --------------------------


            --------STOP state--------
                when stop => 
                    busy_tx <= '1';
                    serial_tx <= '1';
                    
                    if stop_count = stop_limit then
                        stop_count <= 0;
                        state_tx <= idle;
                    else
                        stop_count <= stop_count + 1;
                    end if;
            --------------------------

                
            ----OTHERS (CHECK THIS)----
                when others =>
                    busy_tx <= '0';
                    serial_tx <= '1';
                    data_buffer_tx <= (others => '0');
                    
                    state_tx <= idle;
            --------------------------
        
            end case;
        end if;
    end if;
end if;

end process;

end RTL;