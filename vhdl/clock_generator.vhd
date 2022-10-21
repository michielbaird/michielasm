library ieee;
use ieee.std_logic_1164.all;

entity clock_generator is
    generic(
        input_clock_rate: integer := 100_000_000;
        output_clock_rate: integer := 9_600
    );
    port(
        rst: in std_logic;
        input_clk: in std_logic;
        output_clk: out std_logic
    );
end entity;

architecture behaviour of clock_generator is
    constant count_max: integer := (input_clock_rate) / (2*output_clock_rate);
    signal counter: integer := 0;
    signal clock_sig: std_logic := '0';
begin
    output_clk <= clock_sig;
    counter_proc: process (input_clk, rst)
    begin
        if rising_edge(input_clk) then
            if rst = '1' then
                counter <= 0;
                clock_sig <= '0';
            elsif counter = count_max -1 then
                counter <= 0;
                clock_sig <= not clock_sig;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process counter_proc;
end behaviour;