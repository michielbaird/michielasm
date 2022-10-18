library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

use std.textio.all ;
use ieee.std_logic_textio.all;

entity test_cpu is
end entity;

architecture test of test_cpu is
    component cpu is
        port(
            rst: in std_logic;
            clk: in std_logic
        );
        
    end component;
    signal rst: std_logic;
    signal clk: std_logic;
begin
    CPU_TEST: cpu port map(rst, clk);

    stimulus: process
    begin
        rst <= '0';
        clk <= '0';
        for i in 0 to 800 loop
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
            clk <= '0';
        end loop;
        wait;
    end process stimulus;

end test;