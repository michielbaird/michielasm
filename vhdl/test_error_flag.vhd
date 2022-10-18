library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

use std.textio.all ;
use ieee.std_logic_textio.all;

entity test_error_flag is
end entity;

architecture test of test_error_flag is
    component error_flag is
        generic(
            on_rising_edge: bit := '1'
        );
        port(
            clk: in std_logic;
            value: out std_logic;
            set: in std_logic;
            reset: in std_logic
        );
    end component;
    signal clk: std_logic;
    signal value: std_logic;
    signal set: std_logic;
    signal reset: std_logic;
begin
    REG: error_flag
        port map(clk, value, set, reset);
    
    stimulus: process
        variable ErrCnt : integer := 0 ;
        variable WriteBuf : line ;
    begin
        wait for 10 ns;
        if value /= '0' then
            write(WriteBuf, string'("Initial failed =  "));
            write(WriteBuf, std_logic(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= '0' then
            write(WriteBuf, string'("Stay 1 failed =  "));
            write(WriteBuf, std_logic(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        set <= '1';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= '1' then
            write(WriteBuf, string'("set failed =  "));
            write(WriteBuf, std_logic(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        set <= '0';
        reset <= '1';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= '0' then
            write(WriteBuf, string'("reset failed =  "));
            write(WriteBuf, std_logic(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        set <= '1';
        reset <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= '1' then
            write(WriteBuf, string'("set 2 failed =  "));
            write(WriteBuf, std_logic(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        set <= '1';
        reset <= '1';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        if value /= '0' then
            write(WriteBuf, string'("reset 2 failed =  "));
            write(WriteBuf, std_logic(value));
            writeline(Output, WriteBuf);
            ErrCnt := ErrCnt+1;
        end if;
        
        if (ErrCnt = 0) then 
            report "SUCCESS!!! test_error_flag Test Completed";
        else
            report "The test_error_flag device is broken" severity warning;
        end if;
        wait;
    end process stimulus;
end test;
