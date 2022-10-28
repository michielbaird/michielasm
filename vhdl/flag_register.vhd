library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flag_register is
    generic(
        DATAWIDTH: integer range 4 to 128 := 16;
        on_rising_edge: bit := '1'
    );
    port(
        rst: in std_logic;
        clk: in std_logic;
        data_in: in std_logic_vector(2 downto 0);
        data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
        write_flag: in std_logic;
        error_in: in std_logic;
        overflow_in: in std_logic;
        underflow_in: in std_logic;
        output_full_flag: in std_logic;
        input_available_flag: in std_logic
    );
end entity;

architecture behaviour of flag_register is
    component error_flag is
        generic(
            on_rising_edge: bit := '1'
        );
        port(
            clk: in std_logic;
            value: out std_logic;
            set: in std_logic;
            reset: in std_logic
        );
    end component;
    signal err_val_out: std_logic;
    signal overflow_out: std_logic;
    signal underflow_out: std_logic;

    signal err_flag_reset: std_logic;
    signal overflow_reset: std_logic;
    signal underflow_reset: std_logic;

    signal err_flag_set: std_logic;
    signal overflow_set: std_logic;
    signal underflow_set: std_logic;
begin
    ERR_FLAG: error_flag generic map(on_rising_edge)
        port map(clk, err_val_out, err_flag_set, err_flag_reset);
    OVERFLOW_FLAG: error_flag generic map(on_rising_edge)
        port map(clk, overflow_out, overflow_set, overflow_reset);
    UNDERFLOW_FLAG: error_flag generic map(on_rising_edge)
        port map(clk, underflow_out, underflow_set, underflow_reset);
    data_out <= (DATAWIDTH-1 downto 5 => '0') & input_available_flag & output_full_flag & underflow_out & overflow_out & err_val_out;
    
    err_flag_reset <= rst or (write_flag and (not data_in(0)));
    overflow_reset <= rst or (write_flag and (not data_in(1)));
    underflow_reset <= rst or (write_flag and (not data_in(2)));

    err_flag_set <= error_in or (write_flag and data_in(0)); 
    overflow_set <= overflow_in or (write_flag and data_in(1));
    underflow_set <= underflow_in or (write_flag and data_in(2));
end behaviour;