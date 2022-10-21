library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library std;
use STD.textio.all;


--use std.textio.all;

entity mem_unit2 is
    generic(
        SIZE: integer := 256 -- 2**16
    );
    port(
        data: inout std_logic_vector(15 downto 0);
        -- read_data(0) - read_byte
        -- read_data(1) - read_short 
        -- etc
        read_data: in std_logic_vector(1 downto 0);
        -- write_data(0) - write_byte
        -- write_data(1) - write_short 
        -- etc
        write_short: in std_logic;
        write_enable: in std_logic;
        clk: in std_logic;
        address: in std_logic_vector(15 downto 0)
    );
    -- read over writes
end mem_unit2;

architecture behaviour of mem_unit2 is

    type t_data_vector is array (0 to SIZE-1) of std_logic_vector(7 downto 0);
    
    impure function init_ram_hex return t_data_vector is
        --file text_file : text open read_mode is "ram_content.bin";
        variable ram_content : t_data_vector := (others => (others =>'0'));
        variable offset: integer := 0;
        TYPE t_char_file IS FILE OF character;
        FILE file_in : t_char_file OPEN read_mode IS "ram_content.bin";  -- open the frame file for reading
        VARIABLE char_buffer : character;
      begin
        while not endfile(file_in) loop
            read(file_in, char_buffer);
            ram_content(offset) := std_logic_vector(to_unsigned(character'POS(char_buffer), 8));
            offset := offset + 1;
        end loop;
        return ram_content;
      end function;

    signal internal_ram: t_data_vector := init_ram_hex; --(others => (others => '0'));--
    signal address_int: integer := 0;
    signal in_range: std_logic;
    signal low_byte: std_logic_vector(7 downto 0);
    signal high_byte: std_logic_vector(7 downto 0);
    signal enable: std_logic;
    signal data_in_low: std_logic_vector(7 downto 0);
    signal data_in_high: std_logic_vector(7 downto 0);
begin
    add_proc: process(address_int)
    begin
        if address_int >= SIZE then
            in_range <= '0';
        else
            in_range <= '1';
        end if;
    end process add_proc;
    enable <= '1' when (read_data /= "00" or write_enable = '1') and in_range = '1' else '0';
    data_in_low <= data(7 downto 0);-- when write_enable = '1' else (others => '0');
    data_in_high <= data(15 downto 8);-- when write_enable = '1' else (others => '0');
    

    address_int <= to_integer(unsigned(address));
    
    data_proc: process(high_byte, low_byte, read_data, in_range)
    begin
        if in_range = '0' and read_data /= "00" then
            data <= (others => '1');
        else
            case read_data is
                when "01" => 
                    data <= (15 downto 8 => '0') & low_byte;
                when "10" | "11" =>
                    data <= high_byte & low_byte;
                when others =>
                    data <= (others => 'Z');
            end case;
        end if;
    end process data_proc;
    
    mem_proc: process(clk, enable, write_enable, write_short)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if write_enable = '1' and write_short = '1' then
                    internal_ram(address_int+1) <= data_in_high;-- data(15 downto 8);
                else
                    high_byte <= internal_ram(address_int + 1);
                end if;
            end if;
        end if;
        if rising_edge(clk) then
            if enable = '1' then
                if write_enable = '1' then
                    internal_ram(address_int) <= data_in_low;-- data(7 downto 0);
                else
                    low_byte <= internal_ram(address_int);
                end if;
            end if;
        end if; 
    end process mem_proc;


end behaviour;