library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity ArithmaticLogicUnit is
generic(
    BITWIDTH: integer := 16
);
port(
    -- xcxc do I want an enable bit here or wrap it?
    -- clk: in std_logic;
    A: in std_logic_vector(BITWIDTH-1 downto 0);
    B: in std_logic_vector(BITWIDTH-1 downto 0);
    OPCODE: in integer range 0 to 7;
    RESULT: out std_logic_vector(BITWIDTH - 1 downto 0);
    overflow: out std_logic;
    underflow: out std_logic
    -- OpCode 
    -- ------
    -- 0 - AND
    -- 1 - OR
    -- 2 - XOR
    -- 3 - ADD
    -- 4 - ADD (unsigned)
    -- 5 - Shift Left
    -- 6 - Shift Right
    -- 7 - SubtractU
    -- xcxc signals
);
end ArithmaticLogicUnit;

architecture behaviour of ArithmaticLogicUnit is
    signal A_signed: signed(BITWIDTH downto 0);
    signal B_signed: signed(BITWIDTH downto 0);
    signal A_unsigned: unsigned(BITWIDTH downto 0);
    signal B_unsigned: unsigned(BITWIDTH downto 0);
    signal AB_signed: signed(BITWIDTH downto 0);
    signal AB_unsigned: unsigned(BITWIDTH downto 0);
    signal A_sub_B_unsigned: unsigned(BITWIDTH downto 0);

    signal shift_out: std_logic_vector(BITWIDTH - 1 downto 0);
    signal is_right: std_logic;
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
begin
    A_signed <= resize(signed(A), A_signed'length);
    B_signed <= resize(signed(B), B_signed'length);
    A_unsigned <= '0' & unsigned(A);
    B_unsigned <= '0' & unsigned(B);
    AB_signed <= A_signed + B_signed;
    AB_unsigned <= A_unsigned + B_unsigned;
    A_sub_B_unsigned <= A_unsigned - B_unsigned;

    SHIFTER: BitShifter
        port map(A, B, is_right, shift_out);

    proc_result: process(A, B, OPCODE, AB_signed, AB_unsigned, A_sub_B_unsigned)
    begin
        is_right <= '0';
        overflow <= '0';
        underflow <= '0';
        case OPCODE is
            when 0 => 
                RESULT <= A and B;
            when 1 =>
                RESULT <= A or B;
            when 2 => 
                RESULT <= A xor B;
            when 3 => 
                RESULT <= std_logic_vector(AB_signed(BITWIDTH - 1 downto 0));
                overflow <= (not A_signed(BITWIDTH)) and  (not B_signed(BITWIDTH)) and AB_signed(BITWIDTH);
                underflow <= A_signed(BITWIDTH) and B_signed(BITWIDTH) and (not AB_signed(BITWIDTH));
            when 4 =>
                RESULT <= std_logic_vector(AB_unsigned(BITWIDTH-1 downto 0));
                overflow <= AB_unsigned(BITWIDTH);
            when 5 => 
                RESULT <= shift_out;
            when 6 => 
                is_right <= '1';
                RESULT <= shift_out;            
            when 7 => 
                RESULT <= std_logic_vector(A_sub_B_unsigned(BITWIDTH-1 downto 0));
                underflow <= A_sub_B_unsigned(BITWIDTH);
            when others =>
                RESULT <= (others => 'X');
        end case;
    end process proc_result;

end behaviour;
