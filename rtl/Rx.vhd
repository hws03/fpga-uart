library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Rx is
    generic(
        data_bits: integer := 8;
        stop_bit: integer := 1
      );
    port (
        clk: in std_logic;
        BaudRateGen: in std_logic;
        serial_rx: in std_logic;
        reset_rx: in std_logic;
        
        valid_rx: out std_logic;
        data_rx: out std_logic_vector((data_bits - 1) downto 0) := (others => '0')
       );
end Rx;



architecture RTL of Rx is

signal bit_index: integer := 0;
signal sample_counter: integer := 0; --signal sample_counter: integer range 0 to 15 := 0;
constant bit_limit: integer := data_bits - 1;
signal data_buffer_rx: std_logic_vector((data_bits - 1) downto 0) := (others => '0');

--2FF synchroniser signals
signal serial_rx_FF1: std_logic := '1';
signal serial_rx_FF2: std_logic := '1';

signal stop_count: integer := 0;
constant stop_limit: integer := stop_bit - 1;

--FSM signal 
type state_type is (idle, start, data, stop);
signal state_rx: state_type := idle;



begin


--2FF synchroniser process
process(clk)
begin
    if rising_edge(clk) then
        serial_rx_FF1 <= serial_rx;
        serial_rx_FF2 <= serial_rx_FF1;
    end if;
end process;


--Rx
process(clk)
begin

if rising_edge(clk) then
    valid_rx <= '0';

    ---RESET functionality---
    if reset_rx = '1' then
        bit_index <= 0;
        sample_counter <= 0;
        stop_count <= 0;
        data_buffer_rx <= (others => '0');
        data_rx <= (others => '0');
        valid_rx <= '0';

        state_rx <= idle;
    -----------------------

    else

        if BaudRateGen = '1' then

            case state_rx is


            --------IDLE state---------
                when idle =>
                    sample_counter <= 0; 
                    bit_index <= 0;

                    if serial_rx_FF2 = '0' then
                        state_rx <= start;
                    else
                        state_rx <= idle; -- stay in idle if serial isn't 0
                    end if;
            ---------------------------


            --------START state---------
                when start =>
                    if sample_counter = 7 then -- sample at the midpoint of the start bit (8/16) 
                        sample_counter <= 0; -- restart sample counter
                        
                        if serial_rx_FF2 = '0' then -- check if start bit is present again, if so move to data state
                            state_rx <= data;
                        
                        else
                            state_rx <= idle; -- otherwise go back to idle state
                        end if;
                    
                    else
                        sample_counter <= sample_counter + 1; --count up to 8 (0 to 7)
                    end if;
            ---------------------------


            --------DATA state---------
                when data =>
                    if sample_counter = 15 then -- sample at centre of data bit (16 baud ticks per bit)
                        sample_counter <= 0; -- restart sample counter
                        data_buffer_rx(bit_index) <= serial_rx_FF2;  -- receive data bit by bit and store in data_rx
                    
                        if bit_index = bit_limit then -- check if all 8 bits received (bit indices 0 to 7)
                            bit_index <= 0;
                            stop_count <= 0;
                            state_rx <= stop;
                    
                        else
                            bit_index <= bit_index + 1; -- count up to 8 bits
                        end if;
                    
                    else
                        sample_counter <= sample_counter + 1; -- count up 16 runs 
                    end if;
            ---------------------------


            --------STOP state---------
                when stop =>
                    if sample_counter = 15 then
                        sample_counter <= 0;
                        
                        if serial_rx_FF2 = '1' then -- check if stop bit is present 

                            if stop_count = stop_limit then    
                                data_rx <= data_buffer_rx; --update data_rx port to hold buffer
                                valid_rx <= '1'; -- if so, set valid bit to 1 
                                state_rx <= idle;

                            else
                                stop_count <= stop_count + 1;
                            end if;
    
                        else
                            state_rx <= idle;
                        end if;
    
                    else 
                        sample_counter <= sample_counter + 1; --count up 16 runs
                    end if;
            ---------------------------
            end case;
        
        end if;
    end if;
end if;

end process;

end RTL;