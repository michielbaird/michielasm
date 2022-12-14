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
--        generic(
--            INPUT_CLOCK_SPEED_HZ: integer := 100_000_000;
--            UART_CLOCK_SPEED_HZ: integer := 9600
--        );
        port(
            rst: in std_logic;
            clk: in std_logic;
            uart_tx: out std_logic;
            uart_rx: in std_logic;
            ins: out std_logic_vector(15 downto 0)
        );
        
    end component;
    signal rst: std_logic;
    signal clk: std_logic;
    signal uart_tx: std_logic;
    signal ins: std_logic_vector(15 downto 0);
    constant INPUT_CLOCK_SPEED_HZ: integer := 100_000_000;
    constant UART_CLOCK_SPEED_HZ: integer := 9600;
begin
    CPU_TEST: cpu port map(rst, clk, uart_tx, uart_tx, ins);

    stimulus: process
    begin
        rst <= '0';
        clk <= '0';
        for i in 0 to 250_00 loop
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
            clk <= '0';
        end loop;
        rst <= '0';
        for i in 0 to 250_00 loop
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
            clk <= '0';
        end loop;
        rst <= '0';
        for i in 0 to 250_00 loop
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
            clk <= '0';
        end loop;
        wait;
    end process stimulus;

end test;