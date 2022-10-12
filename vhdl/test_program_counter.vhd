library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

use std.textio.all ;
use ieee.std_logic_textio.all;

entity test_program_counter is
end entity;

architecture test of test_program_counter is
    component program_counter is
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
    end component;
    signal rst: std_logic;
    signal clk: std_logic;
    signal write_flag: std_logic := '0';
    signal value: std_logic_vector(15 downto 0);
    signal override: std_logic := '0';
    signal override_value: std_logic_vector(15 downto 0):= (others => '0');


begin
    PC: program_counter
        port map(rst, clk, write_flag, value, override, override_value);
    
    stimulus: process
        variable ErrCnt : integer := 0 ;
        variable WriteBuf : line ;
    begin
        write_flag <= '0';
        rst <= '1';
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= "0000000000000000" then
            write(WriteBuf, string'("Reset failed =  "));
            write(WriteBuf, std_logic_vector(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        rst <= '0';
        write_flag <= '1';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= "0000000000000010" then
            write(WriteBuf, string'("count failed =  "));
            write(WriteBuf, std_logic_vector(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= "0000000000000100" then
            write(WriteBuf, string'("count 2 failed =  "));
            write(WriteBuf, std_logic_vector(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        write_flag <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= "0000000000000100" then
            write(WriteBuf, string'("noop failed =  "));
            write(WriteBuf, std_logic_vector(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        override_value <= (others => '1');
        write_flag <= '1';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= "0000000000000110" then
            write(WriteBuf, string'("noop failed =  "));
            write(WriteBuf, std_logic_vector(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        override <= '1';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= "1111111111111111" then
            write(WriteBuf, string'("noop failed =  "));
            write(WriteBuf, std_logic_vector(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        if (ErrCnt = 0) then 
            report "SUCCESS!!! test_program_counter Test Completed";
        else
            report "The test_program_counter device is broken" severity warning;
        end if;
        wait;
    end process stimulus;
end test;
