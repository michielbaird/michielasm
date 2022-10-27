library IEEE;
use IEEE.std_logic_1164.all;

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
        write_flag: in std_logic;
        is_full: out std_logic
    );
end uart_register;

architecture behaviour of uart_register is
    component fifo is
        generic(
            SIZE: positive := 16;
            DATAWIDTH: positive := 8 -- only and 8 bit register
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

    -- UART SIDE
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
    data_out <= (others => '0');

    out_clk: clock_generator port map(clk, uart_clk);

    fifo_mem: fifo port map(rst, uart_clk, clk, read_en, write_flag,
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


end behaviour;