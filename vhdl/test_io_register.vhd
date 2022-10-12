library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

use std.textio.all ;
use ieee.std_logic_textio.all;

entity test_io_register is
end entity;

architecture test of test_io_register is
    component io_register is
        generic(
            DATAWIDTH: integer := 16
        );
        port(
            rst: in std_logic;
            clk: in std_logic;
            data_in: in std_logic_vector(DATAWIDTH-1 downto 0);
            data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
            write_flag: in std_logic
        );
    end component;
    signal data_in: std_logic_vector(15 downto 0):= (others => '0');
    signal data_out: std_logic_vector(15 downto 0);
    signal rst: std_logic;
    signal clk: std_logic;
    signal write_flag: std_logic;

begin
    REG: io_register
        port map(rst, clk, data_in, data_out, write_flag);
    
    stimulus: process
        variable ErrCnt : integer := 0 ;
        variable WriteBuf : line ;
    begin
        data_in <= (others=> '1');
        write_flag <= '0';
        rst <= '1';
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if data_out /= "0000000000000000" then
            write(WriteBuf, string'("Reset failed =  "));
            write(WriteBuf, std_logic_vector(data_out));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        write_flag <= '1';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if data_out /= "0000000000000000" then
            write(WriteBuf, string'("Reset 2 failed =  "));
            write(WriteBuf, std_logic_vector(data_out));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        rst <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if data_out /= "1111111111111111" then
            write(WriteBuf, string'("write failed =  "));
            write(WriteBuf, std_logic_vector(data_out));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        data_in <= "1010010001000010";
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if data_out /= "1010010001000010" then
            write(WriteBuf, string'("write 2 failed =  "));
            write(WriteBuf, std_logic_vector(data_out));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        write_flag <= '0';
        data_in <= "1111111000000000";
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if data_out /= "1010010001000010" then
            write(WriteBuf, string'("noop failed =  "));
            write(WriteBuf, std_logic_vector(data_out));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        
        if (ErrCnt = 0) then 
            report "SUCCESS!!! test_io_register Test Completed";
        else
            report "The test_io_register device is broken" severity warning;
        end if;
        wait;
    end process stimulus;
end test;
