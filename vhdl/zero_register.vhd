library IEEE;
use IEEE.std_logic_1164.all;

entity zero_register is
    generic(
        DATAWIDTH: positive := 16;
        on_rising_edge: bit := '1'
    );
    port(
        data_in: in std_logic_vector(DATAWIDTH-1 downto 0);
        data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
        error: out std_logic
    );
end zero_register;

architecture behaviour of zero_register is
    signal zero_val: std_logic_vector(DATAWIDTH-1 downto 0) := (others => '0');
begin
    data_out <= zero_val;
    error <=  '1' when data_in /= zero_val else '0' ;
end behaviour;