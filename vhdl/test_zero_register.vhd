library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

use std.textio.all ;
use ieee.std_logic_textio.all;

entity test_zero_register is
end entity;

architecture test of test_zero_register is
    component zero_register is
        generic(
            DATAWIDTH: integer := 16
        );
        port(
            data_in: in std_logic_vector(DATAWIDTH-1 downto 0);
            data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
            error: out std_logic
        );
    end component;
    signal data_in: std_logic_vector(15 downto 0):= (others => '0');
    signal data_out: std_logic_vector(15 downto 0);
    signal error: std_logic;

begin
    REG: zero_register
        port map( data_in, data_out, error);
    
    stimulus: process
        variable ErrCnt : integer := 0 ;
        variable WriteBuf : line ;
    begin
        data_in <= (others=> '1');
        wait for 10 ns;
        if data_out /= "0000000000000000" then
            write(WriteBuf, string'("zero failed =  "));
            write(WriteBuf, std_logic_vector(data_out));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        if error /= '1' then
            write(WriteBuf, string'("zero failed =  "));
            write(WriteBuf, std_logic_vector(data_out));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        data_in <= (others=> '0');
        wait for 10 ns;
        if data_out /= "0000000000000000" then
            write(WriteBuf, string'("zero2 failed =  "));
            write(WriteBuf, std_logic_vector(data_out));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        if error /= '0' then
            write(WriteBuf, string'("zero 3 failed =  "));
            write(WriteBuf, std_logic_vector(data_out));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        
        if (ErrCnt = 0) then 
            report "SUCCESS!!! test_zero_register Test Completed";
        else
            report "The test_zero_register device is broken" severity warning;
        end if;
        wait;
    end process stimulus;
end test;
