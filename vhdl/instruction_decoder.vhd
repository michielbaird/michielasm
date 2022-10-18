library ieee;
use IEEE.std_logic_1164.all;

entity instruction_decoder is
    port(
        instruction: in std_logic_vector(15 downto 0);
        instruction_type: out integer range 0 to 14
    );
    constant double_immediate: integer := 0;
    constant immediate_load: integer := 1;
    constant immediate_store: integer := 2;
    constant binary_op: integer := 3;
    constant relative_load: integer := 4;
    constant relative_store: integer := 5;
    constant less_than: integer := 6;
    constant jump_equal_zero: integer := 7;
    constant not_op: integer := 8;
    constant special_register_read: integer := 9;
    constant special_register_write: integer := 10;
    constant consume_load_address: integer := 11;
    constant consume_store: integer := 12;
    constant consume_load_word: integer := 13;
    constant invalid: integer := 14;
end entity;

architecture behaviour of instruction_decoder is
    signal di_mask: std_logic_vector(15 downto 0) := "0000000000000001";
    signal di_val: std_logic_vector(15 downto 0)  := "0000000000000001";

    signal si_mask: std_logic_vector(15 downto 0) := "0000000000000011";
    signal si_val: std_logic_vector(15 downto 0)  := "0000000000000010";

    signal bo_mask: std_logic_vector(15 downto 0) := "0000000000011111";
    signal bo_val: std_logic_vector(15 downto 0)  := "0000000000000000";

    signal tp_mask: std_logic_vector(15 downto 0) := "0000000000001111";
    signal tp_val: std_logic_vector(15 downto 0)  := "0000000000001000";

    signal dbl_mask: std_logic_vector(15 downto 0) := "0000000011111111";
    signal dbl_val: std_logic_vector(15 downto 0)  := "0000000000000100";

    signal sc_mask: std_logic_vector(15 downto 0) := "0000011111111111";
    signal sc_val: std_logic_vector(15 downto 0)  := "0000000010000100";
begin
    selector: process(instruction)
    begin
        if (instruction and di_mask) = di_val then
            instruction_type <= double_immediate;
        elsif (instruction and si_mask) = si_val then
            if instruction(2) = '0' then
                instruction_type <= immediate_load;
            else
                instruction_type <= immediate_store;
            end if;
        elsif (instruction and bo_mask) = bo_val then
            instruction_type <= binary_op;
        elsif (instruction and tp_mask) = tp_val then
            case instruction(6 downto 4) is
                when "000" | "010" =>
                    instruction_type <= relative_load;
                when "001" | "011" =>
                    instruction_type <= relative_store;
                when "100" =>
                    instruction_type <= less_than;
                when others =>
                    instruction_type <= invalid;
            end case;
        elsif (instruction and dbl_mask) = dbl_val then
            case instruction(9 downto 8) is
                when "00" =>
                    instruction_type <= jump_equal_zero;
                when "01" =>
                    instruction_type <= not_op;
                when "10" =>
                    instruction_type <= special_register_read;
                when "11" =>
                    instruction_type <= special_register_write;
                when others =>
                    instruction_type <= invalid;
            end case;
        elsif (instruction and sc_mask) = sc_val then
            case instruction(12 downto 11) is
                when "00" =>
                    instruction_type <= consume_load_address;
                when "10" =>
                    instruction_type <= consume_load_word;
                when "01" | "11" =>
                    instruction_type <= consume_store;
                when others =>
                    instruction_type <= invalid;
            end case;
        else
            instruction_type <= invalid;
        end if;
    end process selector;

end behaviour;