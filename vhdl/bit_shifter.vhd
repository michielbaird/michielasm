library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use IEEE.numeric_std.all;




entity BitShifter is
generic(
    BITWIDTH: integer := 16
);
port(
    A: in std_logic_vector(BITWIDTH - 1 downto 0);
    SHIFT: in std_logic_vector(BITWIDTH - 1 downto 0);
    IS_RIGHT: in std_logic;
    RESULT: out std_logic_vector(BITWIDTH - 1 downto 0);
    OVERFLOW: out std_logic
);
end BitShifter;



architecture behaviour of BitShifter is
    constant pipeline_size: integer := integer(floor(log2(real(BITWIDTH)))) + 1;
    signal in_buffer: std_logic_vector(BITWIDTH-1 downto 0);
    signal out_buffer: std_logic_vector(BITWIDTH-1 downto 0);
    signal int_shift: integer;
    signal pipeline_overflow: std_logic_vector(pipeline_size downto 0) := (others => '0');
    type pipeline_t is array(0 to pipeline_size) of std_logic_vector(BITWIDTH - 1 downto 0);
    signal pipeline: pipeline_t;


    function reverse_any_vector (buff: in std_logic_vector)
    return std_logic_vector is
      variable result_a: std_logic_vector(buff'RANGE);
      alias aa: std_logic_vector(buff'REVERSE_RANGE) is buff;
    begin
      for i in aa'RANGE loop
        result_a(i) := aa(i);
      end loop;
      return result_a;
    end; -- function reverse_any_vector
begin
    int_shift <= to_integer(unsigned(SHIFT));
    OVERFLOW <= '0' when pipeline_overflow = (pipeline_size downto 0 => '0') else '1';
        
    setup_buffer: process(is_right, A, out_buffer)
    begin
        case is_right is
            when '0' =>
                in_buffer <= A;
                RESULT <= out_buffer;
            when '1' =>
                in_buffer <= reverse_any_vector(A);
                RESULT <= reverse_any_vector(out_buffer);
            when others => 
                in_buffer <= (others => 'X');
                RESULT <= (others => 'X');
        end case;
    end process setup_buffer;

    shift_out: process(SHIFT, in_buffer, pipeline, int_shift)
        variable step: integer;
    begin
        pipeline(0) <= in_buffer;
        step := 1;
        for i in 1 to (pipeline'length - 1) loop
            if SHIFT(i-1) = '1' then
                pipeline(i) <= pipeline(i-1)(BITWIDTH - 1 - step downto 0) & (step - 1 downto 0 => '0');
                if pipeline(i-1)(BITWIDTH - 1 downto BITWIDTH - step) /= (step - 1 downto 0 => '0') then
                    pipeline_overflow(i) <= '1';
                else
                    pipeline_overflow(i) <= '0';
                end if;
            else
                pipeline(i) <= pipeline(i - 1);
                pipeline_overflow(i) <= '0';
            end if;

            step := step * 2; 
        end loop;
        if int_shift < BITWIDTH then
            out_buffer <= pipeline(pipeline'length - 1);
            pipeline_overflow(0) <= '0';
        else
            out_buffer <= (others => '0');
            if pipeline(0) /= (BITWIDTH - 1 downto 0 => '0') then
                pipeline_overflow(0) <= '1';
            else
                pipeline_overflow(0) <= '0';
            end if;
        end if;
    end process shift_out;

end behaviour;