library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux is
    generic(
        count: integer := 4
    );
    port (
        enable: in std_logic;
        write_index: in integer range 0 to (count-1);
        output: out std_logic_vector(count-1 downto 0)
    );
end entity;

architecture behaviour of demux is
begin
    proc_name: process(enable, write_index)
    begin
        output <= (others => '0');
        output(write_index) <= enable;
    end process proc_name;

end behaviour;