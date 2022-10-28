library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

use std.textio.all ;
use ieee.std_logic_textio.all;

entity test_cpu_echo is
end entity;

architecture test of test_cpu_echo is
    component cpu is
        generic(
            MEMORY_FILE: string := "echo.data"
        );
        port(
            rst: in std_logic;
            clk: in std_logic;
            uart_tx: out std_logic;
            uart_rx: in std_logic;
            ins: out std_logic_vector(15 downto 0)
        );
    end component;
    constant clk_period : time := 10 ns;

    signal rst: std_logic;
    signal clk: std_logic;
    signal uart_tx: std_logic;
    signal uart_rx: std_logic := '1';

    signal ins: std_logic_vector(15 downto 0);
    constant INPUT_CLOCK_SPEED_HZ: integer := 100_000_000;
    constant UART_CLOCK_SPEED_HZ: integer := 115200;
    constant UART_TICKS: integer := INPUT_CLOCK_SPEED_HZ/UART_CLOCK_SPEED_HZ;
begin
    clock_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clock_process;
    
    CPU_TEST: cpu port map(rst, clk, uart_tx, uart_rx, ins);

    uart_process: process
        constant word: string := "Hello World";
        variable index: integer := 1;
        variable bit_index: integer := 0;
        variable current_b: std_logic_vector(7 downto 0);        --variable ticks: integer := 0; 
    begin
        wait for UART_TICKS*10 ns;
        if bit_index = 0 then
            uart_rx <= '0';
            bit_index := bit_index + 1;
            current_b := std_logic_vector(to_unsigned(character'pos(word(index)), 8));
        elsif bit_index = 9 then
            uart_rx <= '1';
            if index = 11 then
                index := 1;
            else
                index := index + 1;
            end if;
            bit_index := 0;
        else
            uart_rx <= current_b(bit_index - 1);
            bit_index := bit_index + 1;
        end if;
        
    end process uart_process;

    stimulus: process
    begin
        rst <= '0';
        wait for 250 us;
        rst <= '0';
        wait for 250 us;
        rst <= '0';
        wait for 250 us;
        wait;
    end process stimulus;

end test;