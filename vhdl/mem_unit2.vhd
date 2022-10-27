library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;


--use std.textio.all;

entity mem_unit2 is
    generic(
        SIZE: integer := 2**16
    );
    port(
        data: inout std_logic_vector(15 downto 0);
        read_data: in std_logic_vector(1 downto 0);
        write_short: in std_logic;
        write_enable: in std_logic;
        clk: in std_logic;
        address: in std_logic_vector(15 downto 0)
    );
end mem_unit2;

architecture behaviour of mem_unit2 is
    component dual_port_ram is
        generic(
            SIZE: integer := SIZE
        );
        port(
             addra : in std_logic_vector(15 downto 0);                          -- Port A Address bus, width determined from RAM_DEPTH
             addrb : in std_logic_vector(15 downto 0);                          -- Port B Address bus, width determined from RAM_DEPTH
             dina  : in std_logic_vector(7 downto 0);                         -- Port A RAM input data
             dinb  : in std_logic_vector(7 downto 0);                         -- Port B RAM input data
             clka  : in std_logic;                                                                 -- Port A Clock
             clkb  : in std_logic;                                                                 -- Port B Clock
             wea   : in std_logic;                                     -- Port A Write enable
             web   : in std_logic;                                     -- Port B Write enable
             ena   : in std_logic;                                                                 -- Port A RAM Enable, for additional power savings, disable port when not in use
             enb   : in std_logic;                                                                 -- Port B RAM Enable, for additional power savings, disable port when not in use
             douta : out std_logic_vector(7 downto 0);
             doutb : out std_logic_vector(7 downto 0)   
        );
    end component;

    --signal address_int: integer := 0;
    signal address2: std_logic_vector(15 downto 0);

    signal low_byte: std_logic_vector(7 downto 0);
    signal high_byte: std_logic_vector(7 downto 0);
    
    signal enable_low: std_logic;
    signal enable_high: std_logic;
    
    signal write_high: std_logic;

    alias data_in_low: std_logic_vector(7 downto 0) is data(7 downto 0);
    alias data_in_high: std_logic_vector(7 downto 0) is data(15 downto 8);
begin
    add_proc: process(address)
        variable address_int: integer;
    begin
        address_int := to_integer(unsigned(address));
        if address_int = SIZE - 1 then
            address2 <= (others => '0');
        else
            address2 <= std_logic_vector(to_unsigned(address_int + 1, address2'length));
        end if;
    end process add_proc;
    
    enable_high <= '1' when (read_data = "10" or read_data = "11" or (write_enable = '1' and write_short = '1')) else '0';
    enable_low <= '1' when (read_data /= "00" or write_enable = '1') else '0';
    write_high <= write_enable and write_short;

    internal_ram: dual_port_ram port map(
        addra => address, 
        addrb => address2, 
        dina => data_in_low, 
        dinb => data_in_high, 
        clka => clk, 
        clkb => clk,
        wea => write_enable, 
        web => write_high, 
        ena => enable_low, 
        enb => enable_high,  
        douta => low_byte, 
        doutb => high_byte);
    
    data_proc: process(read_data, low_byte, high_byte, write_enable, write_short)
    begin
        if write_enable = '1' or write_short = '1' then
            data <= (others => 'Z');
        else
            case read_data is
                when "10" | "11" =>
                    data_in_low <= low_byte;
                    data_in_high <= high_byte;
                when "00" =>
                    data_in_low <= (others => 'Z');
                    data_in_high <= (others => 'Z');
                when "01" =>
                    data_in_low <= low_byte;
                    data_in_high <= (others => '0');
                when others =>
                    data_in_low <= (others => 'X');
                    data_in_high <= (others => 'X');
            end case;
        end if;
    end process data_proc;
   


end behaviour;