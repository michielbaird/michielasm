library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_register is
    generic(
        INPUT_CLOCK_SPEED_HZ: integer :=  100_000_000;
        UART_CLOCK_SPEED_HZ: integer := 9600;
        on_rising_edge: bit := '1'
    );
    port(
        rst: in std_logic;
        clk: in std_logic;
        data_in: in std_logic_vector(7 downto 0);
        data_out: out std_logic_vector(15 downto 0);
        uart_tx: out std_logic;
        uart_rx: in std_logic;
        uart_rx_read: in std_logic;
        write_flag: in std_logic;
        is_full: out std_logic;
        has_data: out std_logic
    );
end uart_register;

architecture behaviour of uart_register is
    component fifo is
        generic(
            SIZE: positive := 16;
            DATAWIDTH: positive := 8; -- only and 8 bit register
            latch_output: boolean := false
        );
        port(
            rst: in std_logic;
            read_clk: in std_logic;
            write_clk: in std_logic;
            read_en: in std_logic;
            write_en: in std_logic;
            data_in: in std_logic_vector(7 downto 0);
            data_out: out std_logic_vector(7 downto 0);
            is_empty: out std_logic;
            is_full: out std_logic
        );
    end component;
    component clock_generator is
        generic(
            input_clock_rate: integer := INPUT_CLOCK_SPEED_HZ;
            output_clock_rate: integer := UART_CLOCK_SPEED_HZ
        );
        port(
            input_clk: in std_logic;
            output_clk: out std_logic
        );
    end component;
    constant uart_rx_tick_count: integer := (INPUT_CLOCK_SPEED_HZ) / (UART_CLOCK_SPEED_HZ);
    constant uart_rx_half_tick: integer := uart_rx_tick_count/2;

    type t_uart_rx_state is (
        rx_idle,
        rx_start,
        rx_data,
        rx_stop
    );
    -- UART RX
    signal uart_rx_state: t_uart_rx_state := rx_idle;
    signal uart_input: std_logic_vector(7 downto 0) := (others => '0');
    signal uart_rx_index: integer range 0 to 7 := 0;
    signal uart_rx_ticks: integer range 0 to uart_rx_tick_count := 0;
    signal uart_rx_out: std_logic_vector(7 downto 0);
    signal uart_rx_write: std_logic := '0';
    signal uart_rx_fifo_empty: std_logic;
    signal uart_rx_fifo_full: std_logic;

    -- UART TX SIDE
    signal is_empty: std_logic;
    signal read_en: std_logic := '0';
    signal uart_clk: std_logic;
    signal uart_output: std_logic_vector(7 downto 0);
    signal uart_tx_index: integer range 0 to 7;
    
    type t_uart_tx_state is (
        tx_idle,
        tx_start,
        tx_data,
        tx_stop
    );
    signal uart_tx_state: t_uart_tx_state := tx_idle;
    
begin
    data_out <= (others => '0') when uart_rx_fifo_empty = '1' else (15 downto 8 => '0') & uart_rx_out;
    has_data <= not uart_rx_fifo_empty;

    out_clk: clock_generator port map(clk, uart_clk);

    fifo_mem: fifo generic map(latch_output => true) port map(rst, uart_clk, clk, read_en, write_flag,
         data_in, uart_output, is_empty, is_full); 

    
    tx_output: process(uart_tx_state, uart_output, uart_tx_index)
    begin
        case uart_tx_state is
            when tx_idle =>
                uart_tx <= '1';
            when tx_start =>
                uart_tx <= '0';
            when tx_data =>
                uart_tx <= uart_output(uart_tx_index);
            when tx_stop =>
                uart_tx <= '1';
            when others => 
                uart_tx <= '1';
        end case;
    end process tx_output;

    tx_state_proc: process(rst, uart_clk, is_empty)
    begin
        if rising_edge(uart_clk) then
            if rst = '1' or uart_tx_state = tx_stop or (uart_tx_state = tx_idle and is_empty = '1') then
                uart_tx_state <= tx_idle;
                read_en <= '0';
                uart_tx_index <= 0;
            elsif uart_tx_state = tx_idle and is_empty = '0' then
                uart_tx_state <= tx_start;
                read_en <= '1';
                uart_tx_index <= 0;
            elsif uart_tx_state = tx_start then
                uart_tx_state <= tx_data;
                read_en <= '0';
                uart_tx_index <= 0;
            elsif uart_tx_state = tx_data then
                if uart_tx_index = 7 then
                    uart_tx_state <= tx_stop;
                    read_en <= '0';
                    uart_tx_index <= 0;
                else 
                    uart_tx_index <= uart_tx_index + 1;
                end if;
            end if;
        end if;
    end process tx_state_proc;

    fifo_rx: fifo  port map(
        rst => rst,
        read_clk => clk,
        write_clk => clk, 
        read_en => uart_rx_read,
        write_en => uart_rx_write,
        data_in => uart_input,
        data_out => uart_rx_out,
        is_empty => uart_rx_fifo_empty,
        is_full => uart_rx_fifo_full);

    rx_state_proc: process(clk, uart_rx_state, uart_rx_fifo_full, uart_rx, uart_rx_ticks)
    begin
        if rising_edge(clk) then
            case uart_rx_state is
                when rx_idle =>
                    uart_rx_write <= '0';
                    if uart_rx = '0' then
                        uart_rx_ticks <= uart_rx_half_tick;
                        uart_rx_state <= rx_start;
                    else
                        uart_rx_ticks <= 0;
                    end if;
                when rx_start =>
                    if uart_rx_ticks = 0 then
                        if uart_rx = '0' then
                            uart_rx_state <= rx_data;
                            uart_rx_index <= 0;
                            uart_rx_ticks <= uart_rx_tick_count;
                        else
                            uart_rx_state <= rx_idle;
                            uart_rx_ticks <= 0;
                        end if;
                    else
                        uart_rx_ticks <= uart_rx_ticks - 1;
                    end if;
                when rx_data =>
                    if uart_rx_ticks = 0 then
                        uart_input(uart_rx_index) <= uart_rx;
                        uart_rx_ticks <= uart_rx_tick_count;
                        if uart_rx_index = 7 then
                            uart_rx_state <= rx_stop;
                        else
                            uart_rx_index <= uart_rx_index + 1;
                        end if;
                    else
                        uart_rx_ticks <= uart_rx_ticks - 1;
                    end if;
                when rx_stop =>
                    if uart_rx_ticks = 0 then
                        if uart_rx = '1' and uart_rx_fifo_full = '0' then
                            uart_rx_write <= '1';
                        end if;
                        -- latch if high else discard
                        uart_rx_state <= rx_idle;
                    else
                        uart_rx_ticks <= uart_rx_ticks - 1;
                    end if;
            end case;
        end if;
        
    end process rx_state_proc;


end behaviour;