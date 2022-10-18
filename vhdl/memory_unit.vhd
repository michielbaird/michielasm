library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library std;
use STD.textio.all;


--use std.textio.all;

entity Memory_Unit is
    generic(
        SIZE: integer :=  256--2**16;
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
        write_clk: in std_logic;
        address: in std_logic_vector(15 downto 0)
    );
    -- read over writes
end Memory_Unit;

architecture behaviour of Memory_Unit is

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

    signal internal_ram: t_data_vector := init_ram_hex;
    signal address_int: integer := 0;
    signal low_byte: std_logic_vector(7 downto 0);
    signal high_byte: std_logic_vector(7 downto 0);

begin
    address_int <= to_integer(unsigned(address));
    low_byte <= internal_ram(address_int);
    high_byte <= internal_ram(address_int + 1);
    read_proc: process(read_data, address_int, low_byte, high_byte)
    begin            
        if address_int >= SIZE then
            data <= (others => '0');
        else
            case read_data is
                when "00" =>
                    data <= (others => 'Z');
                when "10" | "11" =>
                    data <= high_byte & low_byte;
                when "01" =>
                    data <= (7 downto 0 => '0') & low_byte;
                when others => 
                    data <= (others => 'X'); 
            end case;
        
        end if;
    end process read_proc;
    write_proc: process(read_data, write_short, write_clk, address_int)
    begin
        if read_data = "00" then
            if rising_edge(write_clk) then
                internal_ram(address_int) <= data(7 downto 0);
                if write_short = '1' then
                    internal_ram(address_int+1) <= data(15 downto 8);
                end if;
            end if;
        end if;    
    end process write_proc;

end behaviour;