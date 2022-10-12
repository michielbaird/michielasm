library IEEE;
use IEEE.std_logic_1164.all;

entity io_register is
    generic(
        DATAWIDTH: positive := 16;
        on_rising_edge: bit := '1'
    );
    port(
        rst: in std_logic;
        clk: in std_logic;
        data_in: in std_logic_vector(DATAWIDTH-1 downto 0);
        data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
        write_flag: in std_logic
    );
end io_register;


architecture behaviour of io_register is
    signal internal_buffer: std_logic_vector(DATAWIDTH-1 downto 0) := (others => '0');
begin
    data_out <= internal_buffer;
    write_proc: process(clk, rst, data_in, write_flag)
    begin
        if on_rising_edge = '1' then
            if rising_edge(clk) then
                if rst = '1' then
                    internal_buffer <= (others => '0');
                elsif write_flag = '1' then
                    internal_buffer <= data_in;
                end if;
            end if;
        else
            if falling_edge(clk) then
                if rst = '1' then
                    internal_buffer <= (others => '0');
                elsif write_flag = '1' then
                    internal_buffer <= data_in;
                end if;
            end if;
        end if;
    end process write_proc;

end behaviour;

