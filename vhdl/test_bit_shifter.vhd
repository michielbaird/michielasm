library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

use std.textio.all ;
use ieee.std_logic_textio.all ;

entity test_BitShifter is
    generic(
        BITWIDTH: integer := 16
    );
end test_BitShifter;

architecture test of test_BitShifter is
    signal expected_result: std_logic_vector(BITWIDTH - 1 downto 0);
    signal in_a: std_logic_vector(BITWIDTH-1 downto 0);
    signal in_shift: std_logic_vector(BITWIDTH-1 downto 0);
    signal in_is_right: std_logic;
    signal out_result: std_logic_vector(BITWIDTH-1 downto 0);
    component BitShifter
        generic(
            BITWIDTH: integer := BITWIDTH
        );
        port(
            A: in std_logic_vector(BITWIDTH - 1 downto 0);
            SHIFT: in std_logic_vector(BITWIDTH - 1 downto 0);
            IS_RIGHT: in std_logic;
            RESULT: out std_logic_vector(BITWIDTH - 1 downto 0)
        );
    end component;

    type test_vector_array is array (natural range <>) of std_logic_vector(BITWIDTH-1 downto 0);
    constant test_vectors : test_vector_array := (
        conv_std_logic_vector(1, BITWIDTH),
        conv_std_logic_vector(2, BITWIDTH), 
        conv_std_logic_vector(3, BITWIDTH),
        conv_std_logic_vector(4, BITWIDTH), 
        conv_std_logic_vector(5, BITWIDTH), 
        conv_std_logic_vector(6, BITWIDTH), 
        conv_std_logic_vector(42, BITWIDTH),
        conv_std_logic_vector(8, BITWIDTH),
        conv_std_logic_vector(16, BITWIDTH),
        conv_std_logic_vector(32, BITWIDTH),
        conv_std_logic_vector(64, BITWIDTH),     
        conv_std_logic_vector(128, BITWIDTH),
        conv_std_logic_vector(256, BITWIDTH),
        conv_std_logic_vector(512, BITWIDTH),
        conv_std_logic_vector(1024, BITWIDTH),
        conv_std_logic_vector(2048, BITWIDTH),
        conv_std_logic_vector(4096, BITWIDTH),
        conv_std_logic_vector(8192, BITWIDTH),
        conv_std_logic_vector(21915, BITWIDTH),
        conv_std_logic_vector(64446, BITWIDTH),     
        conv_std_logic_vector(17782, BITWIDTH),
        conv_std_logic_vector(14260, BITWIDTH),
        conv_std_logic_vector(19284, BITWIDTH),
        conv_std_logic_vector(14490, BITWIDTH),
        conv_std_logic_vector(54874, BITWIDTH),
        conv_std_logic_vector(21258, BITWIDTH),
        conv_std_logic_vector(35181, BITWIDTH),
        conv_std_logic_vector(57662, BITWIDTH)
    );
begin
    SHIFTER: BitShifter
        port map(in_a, in_shift, in_is_right, out_result);
        
    expected_shifter_proc : process(in_is_right, in_shift, in_a)
    begin
        case in_is_right is
            when '1' =>
                expected_result <= std_logic_vector(shift_right(
                    unsigned(in_a), to_integer(unsigned(in_shift))
                ));
            when '0' =>
                expected_result <= std_logic_vector(shift_left(
                    unsigned(in_a), to_integer(unsigned(in_shift))
                ));
            when others =>
                expected_result <= (others => 'X');
        end case;
    end process expected_shifter_proc;      

    stimulus : process

        -- Variables for testbench
        variable ErrCnt : integer := 0 ;
        variable WriteBuf : line ;
    
    begin
        for j in 0 to 1 loop
            if j = 0 then
                in_is_right <= '0';
            else
                in_is_right <= '1';
            end if;
            for k in 0 to BITWIDTH + 1 loop
                in_shift <= conv_std_logic_vector(k, BITWIDTH);
                for i in test_vectors'range loop
                    in_a <= test_vectors(i);
                    
                    wait for 10 ns;
                    
                    if(out_result /= expected_result) then
                        write(WriteBuf, string'("ERROR: Shift failed: A =  "));
                        write(WriteBuf, std_logic_vector(in_a));
                        if in_is_right = '0' then
                            write(WriteBuf, string'(" << "));
                        else
                            write(WriteBuf, string'(" >> "));
                        end if;
                        write(WriteBuf, std_logic_vector(in_shift));
                        write(WriteBuf, string'("  "));
                        write(WriteBuf, std_logic_vector(out_result));
                        write(WriteBuf, string'(" /= "));
                        write(WriteBuf, std_logic_vector(expected_result));


                        
                        writeline(Output, WriteBuf);
                        ErrCnt := ErrCnt+1;
                    end if;
                end loop;
            end loop;
        end loop;
        
        if (ErrCnt = 0) then 
            report "SUCCESS!!! test_BitShifter Test Completed";
        else
                report "The test_BitShifter device is broken" severity warning;
        end if;
        wait;


    end process stimulus;

end test;