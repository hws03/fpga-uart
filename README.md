# UART - VHDL

Simple configurable UART transceiver, written in VHDL for Xilinx Vivado.

- **Modules:** `baud_rate` (Tx clock divider), `baud_rate_16x` (Rx clock divider), `Tx`, `Rx`, `uart_top` (top-level)

- **Default baudrate:** 9600 (generic, derived from `clk_freq / baudrate`).

- **Tx:** FSM (`idle -> start -> data -> stop`), transmits LSB first, 1x baud-rate clock enable.

- **Rx:** FSM (`idle -> start -> data -> stop`), 16x oversampled for mid-bit sampling, includes 2-flip-flop input synchroniser on the serial line.

- **Generics** `data_bits` = 8, `stop_bit` = 1