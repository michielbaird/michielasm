library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

use std.textio.all ;
use ieee.std_logic_textio.all;

entity test_memory_unit is
end entity;

architecture test of test_memory_unit is
    component Memory_Unit is
        generic(
            SIZE: integer := 256
        );
        port(
           data: inout std_logic_vector(15 downto 0);
           read_data: in std_logic_vector(1 downto 0);
           write_short: in std_logic;
           write_clk: in std_logic;
           address: in std_logic_vector(15 downto 0)
        );
    end component;
    signal data_bus: std_logic_vector(15 downto 0);
    signal read_data: std_logic_vector(1 downto 0);
    signal write_short: std_logic;
    signal write_clk: std_logic;
    signal address_line: std_logic_vector(15 downto 0);
begin
    MEM: Memory_Unit
        port map(data_bus, read_data, write_short, write_clk, address_line);
    
    stimulus: process
        variable ErrCnt : integer := 0 ;
        variable WriteBuf : line ;
    begin
        read_data <= "00";
        write_short <= '1';
        write_clk <= '0';
        data_bus <= "1100110010101010";
        address_line <= (others => '0');
        wait for 10 ns;
        write_clk <= '1';
        wait for 10 ns;
        write_clk <= '0';
        data_bus <= (others => 'Z');
        write_short <= '0';
        wait for 10 ns;
        read_data <= "01";
        wait for 10 ns;
        if data_bus /= "0000000010101010" then
            write(WriteBuf, string'("ERROR: Read failed: data =  "));
            write(WriteBuf, std_logic_vector(data_bus));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        read_data <= "11";
        wait for 10 ns;
        if data_bus /= "1100110010101010" then
            write(WriteBuf, string'("ERROR: Read failed: data =  "));
            write(WriteBuf, std_logic_vector(data_bus));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        read_data <= "01";
        address_line <= "0000000000000001";
        wait for 10 ns;
        if data_bus /= "0000000011001100" then
            write(WriteBuf, string'("ERROR: Read failed: data =  "));
            write(WriteBuf, std_logic_vector(data_bus));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        
        if (ErrCnt = 0) then 
            report "SUCCESS!!! test_Memory_Unit Test Completed";
        else
            report "The test_Memory_Unit device is broken" severity warning;
        end if;
        wait;
    end process stimulus;
end test;
