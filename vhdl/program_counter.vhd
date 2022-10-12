library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
    generic(
        DATAWIDTH: positive:= 16;
        INCREMENT: positive:= 2
    );
    port(
        rst: in std_logic;
        clk: in std_logic;
        write_flag: in std_logic;
        value: out std_logic_vector(DATAWIDTH-1 downto 0);
        override: in std_logic;
        override_value: in std_logic_vector(DATAWIDTH-1 downto 0)
    );
end program_counter;

architecture behaviour of program_counter is
    component io_register is
        generic(
            DATAWIDTH: positive := DATAWIDTH
        );
        port(
            rst: in std_logic;
            clk: in std_logic;
            data_in: in std_logic_vector(DATAWIDTH-1 downto 0);
            data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
            write_flag: in std_logic
        );
    end component;
    signal reg_data_out: std_logic_vector(DATAWIDTH-1 downto 0);
    signal reg_write_flag: std_logic;
    signal reg_data_in: std_logic_vector(DATAWIDTH-1 downto 0);
begin
    value <= reg_data_out;
    reg: io_register
        port map(
            rst,
            clk,
            reg_data_in,
            reg_data_out,
            write_flag
        );
   data_select: process(override, override_value, reg_data_out)
   begin
        if override = '1' then
            reg_data_in <= override_value;
        else 
            reg_data_in <= std_logic_vector(unsigned(reg_data_out) + INCREMENT);
        end if;
   end process data_select;
end behaviour;