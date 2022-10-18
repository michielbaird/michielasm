library IEEE;
use IEEE.std_logic_1164.all;

entity error_flag is
    generic(
        on_rising_edge: bit := '1'
    );
    port(
        clk: in std_logic;
        value: out std_logic;
        set: in std_logic;
        reset: in std_logic
    );
end error_flag;
    
architecture behaviour of error_flag is
    signal internal: std_logic := '0';
begin
    value <= internal;
    internal_setter: process(clk, set, reset)
    begin
        if on_rising_edge = '1' then
            if rising_edge(clk) then
                if reset = '1' then
                    internal <= '0';
                elsif set = '1' then
                    internal <= '1'; 
                end if;
            end if;
        else
            if falling_edge(clk) then
                if reset = '1' then
                    internal <= '0';
                elsif set = '1' then
                    internal <= '1'; 
                end if;
            end if; 
        end if;  
    end process internal_setter;
end behaviour;

