library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.conv_std_logic_vector;


use std.textio.all ;
use ieee.std_logic_textio.all ;

entity test_ALU is
    generic(
        BITWIDTH: integer := 16
    );
end;

architecture test of test_ALU is
    component ArithmaticLogicUnit 
        generic(
            BITWIDTH: integer := BITWIDTH
        );
        port( 
            A: in std_logic_vector(BITWIDTH-1 downto 0);
            B: in std_logic_vector(BITWIDTH-1 downto 0);
            OPCODE: in integer range 0 to 7;
            RESULT: out std_logic_vector(BITWIDTH - 1 downto 0)
        );
    end component;
    signal A_in: std_logic_vector(BITWIDTH-1 downto 0);
    signal B_in: std_logic_vector(BITWIDTH-1 downto 0);
    signal opcode_in: integer range 0 to 7;
    signal result_out: std_logic_vector(BITWIDTH-1 downto 0);
    signal expected_result: std_logic_vector(BITWIDTH-1 downto 0);
    type t_ALU_RECORD is record
        A: std_logic_vector(BITWIDTH-1 downto 0);
        B: std_logic_vector(BITWIDTH-1 downto 0);
        opcode: integer range 0 to 7;
        result: std_logic_vector(BITWIDTH-1 downto 0);
    end record t_ALU_RECORD;
    type t_alu_vector is array (natural range <>) of t_ALU_RECORD;
    constant and_op: integer := 0;
    constant or_op: integer := 1;
    constant xor_op: integer := 2;
    constant add_op: integer := 3;
    constant addu_op: integer := 4;
    constant shl_op: integer := 5;
    constant shr_op: integer := 6;
    constant sub_op: integer := 7;
    constant test_vectors: t_alu_vector := (
        ((others => '0'),  (others => '1'), and_op, (others => '0')),
        ((others => '0'),  (others => '1'), and_op, (others => '0')),
        ((others => '0'),  (others => '1'), or_op, (others => '1')),
        (conv_std_logic_vector(43690, BITWIDTH), conv_std_logic_vector(0, BITWIDTH), xor_op, conv_std_logic_vector(43690, BITWIDTH)),
        (conv_std_logic_vector(43690, BITWIDTH), conv_std_logic_vector(21845, BITWIDTH), xor_op, conv_std_logic_vector(65535, BITWIDTH)),
        ((others => '1'), conv_std_logic_vector(1, BITWIDTH), add_op, conv_std_logic_vector(0, BITWIDTH)),
        ((others => '1'), (others => '1'), add_op, conv_std_logic_vector(-2, BITWIDTH)),
        (conv_std_logic_vector(1, BITWIDTH), conv_std_logic_vector(255, BITWIDTH), add_op, conv_std_logic_vector(256, BITWIDTH)),
        (conv_std_logic_vector(22337, BITWIDTH), conv_std_logic_vector(32614, BITWIDTH), add_op, conv_std_logic_vector(54951, BITWIDTH)),
        (conv_std_logic_vector(16825, BITWIDTH), conv_std_logic_vector(3844, BITWIDTH), add_op, conv_std_logic_vector(20669, BITWIDTH))
    );

begin
    test_ALU_unit: ArithmaticLogicUnit
        port map(
            A_in, B_in, opcode_in, result_out
        );


    stimulus : process

    -- Variables for testbench
    variable ErrCnt : integer := 0 ;
    variable WriteBuf : line ;
    
    begin
        for i in test_vectors'range loop
            A_in <= test_vectors(i).A;
            B_in <= test_vectors(i).B;
            opcode_in <= test_vectors(i).opcode;
            expected_result <= test_vectors(i).result;
    
            wait for 10 ns;
            
            if(result_out /= expected_result) then
                write(WriteBuf, string'("ERROR:  ALU  failed: "));
                write(WriteBuf, std_logic_vector(A_in));
                write(WriteBuf, string'(" "));
                write(WriteBuf, opcode_in);
                write(WriteBuf, string'(" "));
                write(WriteBuf, std_logic_vector(B_in));
                write(WriteBuf, string'(": "));
                write(WriteBuf, std_logic_vector(result_out));
                write(WriteBuf, string'(" /= "));
                write(WriteBuf, std_logic_vector(expected_result));
                writeline(Output, WriteBuf);
                ErrCnt := ErrCnt+1;
            end if;
        end loop;
        
        if (ErrCnt = 0) then 
            report "SUCCESS!!!  test_ALU Test Completed";
        else
                report "The test_ALU device is broken" severity warning;
        end if;
        wait;

    end process stimulus;

end test;