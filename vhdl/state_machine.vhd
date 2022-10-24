library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity state_machine is
    port(
        instruction: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        rst: in std_logic;
        is_a_bus_zero: in std_logic;
        pc_write_flag: out std_logic;
        mem_read_data: out std_logic_vector(1 downto 0);
        mem_write_short: out std_logic;
        a_bus_selector: out integer range 0 to 20;
        b_bus_selector: out integer range 0 to 20;
        alu_opcode: out integer range 0 to 9;
        write_flag: out std_logic;
        write_index: out integer range 18 downto 0;
        use_address_reg: out std_logic
    );
end entity;

architecture behaviour of state_machine is
    type tState is 
    (
        fetch,
        execute_phase_0,
        noop_state,
        jump_state,
        imm_store_state,
        rel_load_state,
        rel_store_state,
        cons_load_state,
        cons_store_state
    );
    signal state: tState;
    signal next_state: tState;

    component instruction_decoder is
        port(
            instruction: in std_logic_vector(15 downto 0);
            instruction_type: out integer range 0 to 14
        );
    end component;
    signal instruction_type: integer range 0 to 14;
    signal mem_phase: std_logic := '0';
    signal internal_mem_read_data: std_logic_vector(1 downto 0) := "00";
    
    alias reg_p0: std_logic_vector(2 downto 0) is instruction(15 downto 13);
    alias reg_p1: std_logic_vector(2 downto 0) is instruction(12 downto 10);
    alias reg_p2: std_logic_vector(2 downto 0) is instruction(9 downto 7);
    alias reg_p4: std_logic_vector(2 downto 0) is instruction(6 downto 4);


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
begin
    id: instruction_decoder port map(instruction, instruction_type);

    mem_read_data <= internal_mem_read_data;

    state_output: process(state, instruction, instruction_type, clk, rst, mem_phase)
    begin
        pc_write_flag <= '0';
        internal_mem_read_data <= "00";
        mem_write_short <= '0';
        a_bus_selector <= 0;
        b_bus_selector <= 0;
        alu_opcode <= 0;
        write_flag <= '0';
        write_index <= 0;
        use_address_reg <= '0';
        if rst = '0' then
            case state is
                when fetch => 
                    internal_mem_read_data <= "11";
                    write_index <= 17;
                    write_flag <= mem_phase;
                    pc_write_flag <= mem_phase;
                when execute_phase_0 => 
                    case instruction_type is
                        when double_immediate =>
                            A_bus_selector <= to_integer(unsigned(reg_p1));
                            B_bus_selector <= 18;
                            write_index <= to_integer(unsigned(reg_p0));
                            write_flag <= '1';
                            if instruction(2 downto 1) = "00" then
                                alu_opcode <= 4;
                            elsif instruction(2 downto 1) = "01" then
                                alu_opcode <= 7;
                            end if;
                        when immediate_load =>
                            alu_opcode <= 1;
                            b_bus_selector <= 0;
                            if instruction(3) = '0' then
                                a_bus_selector <= 19;
                            else 
                                a_bus_selector <= 20;
                            end if;
                            write_index <= to_integer(unsigned(reg_p0));
                            write_flag <= '1';
                        when immediate_store => -- Needs phase 2
                            alu_opcode <= 1;
                            a_bus_selector <= to_integer(unsigned(reg_p0));
                            b_bus_selector <= 0;
                            write_flag <= '1';
                            write_index <= 16;
                        when binary_op =>
                            a_bus_selector <= to_integer(unsigned(reg_p1));
                            b_bus_selector <= to_integer(unsigned(reg_p2));
                            alu_opcode <= to_integer(unsigned(reg_p4));
                            write_index <= to_integer(unsigned(reg_p0));
                            write_flag <= '1';
                        when relative_load | relative_store => -- needs phase 2
                            a_bus_selector <= to_integer(unsigned(reg_p0));
                            b_bus_selector <= to_integer(unsigned(reg_p2));
                            alu_opcode <= 4;
                            write_index <= 16;
                            write_flag <= '1';
                        when less_than =>
                            a_bus_selector <= to_integer(unsigned(reg_p1));
                            b_bus_selector <= to_integer(unsigned(reg_p2));
                            alu_opcode <= 8;
                            write_index <= to_integer(unsigned(reg_p0));
                            write_flag <= '1';
                        when jump_equal_zero => -- needs phase 2
                            a_bus_selector <= to_integer(unsigned(reg_p0));
                        when not_op => 
                            a_bus_selector <= to_integer(unsigned(reg_p1));
                            alu_opcode <= 9;
                            write_index <= to_integer(unsigned(reg_p0));
                            write_flag <= '1';
                        when special_register_read =>
                            a_bus_selector <= to_integer(unsigned(reg_p1)) + 8;
                            b_bus_selector <= 0;
                            alu_opcode <= 1;
                            write_index <= to_integer(unsigned(reg_p0));
                            write_flag <= '1';
                        when special_register_write =>
                            a_bus_selector <= to_integer(unsigned(reg_p0));
                            b_bus_selector <= 0;
                            alu_opcode <= 1;
                            write_index <= to_integer(unsigned(reg_p1)) + 8;
                            write_flag <= '1';
                        when consume_load_word =>
                            write_index <= to_integer(unsigned(reg_p0));
                            internal_mem_read_data <= "11";
                            write_flag <= mem_phase;
                            pc_write_flag <= mem_phase;
                        when consume_load_address | consume_store => -- needs phase 2
                            write_index <= 16;
                            internal_mem_read_data <= "11";
                            write_flag <= mem_phase;
                            pc_write_flag <= mem_phase;
                        when invalid => -- ERROR CASE
                            a_bus_selector <= 0;
                            b_bus_selector <= 0;
                            alu_opcode <= 9;
                            write_index <= 0;
                            write_flag <= '1';
                    end case;
                when noop_state =>
                    write_flag <= '0';
                    a_bus_selector <= 0;
                    b_bus_selector <= 0;
                    alu_opcode <= 0;
                when jump_state =>
                    a_bus_selector <= to_integer(unsigned(reg_p1));
                    b_bus_selector <= 0;
                    alu_opcode <= 1;
                    write_index <= 8;
                    write_flag <= '1';
                    pc_write_flag <= '1';
                when imm_store_state =>
                    write_index <= 18;
                    use_address_reg <= '1';
                    mem_write_short <= not instruction(3);
                    a_bus_selector <= 19;
                    b_bus_selector <= 0;
                    alu_opcode <= 1;
                    write_flag <= '1';
                when rel_load_state =>
                    write_index <= to_integer(unsigned(reg_p1));
                    write_flag <= mem_phase;
                    if instruction(5) = '0' then
                        internal_mem_read_data <= "11";
                    else
                        internal_mem_read_data <= "01";
                    end if;
                    use_address_reg <= '1';
                when rel_store_state =>
                    write_index <= 18;
                    use_address_reg <= '1';
                    write_flag <= '1';
                    if instruction(5) = '0' then
                        mem_write_short <= '1';
                    else
                        mem_write_short <= '0';
                    end if;
                    a_bus_selector <= to_integer(unsigned(reg_p1));
                    b_bus_selector <= 0;
                    alu_opcode <= 1;
                when cons_load_state =>
                    write_index <= to_integer(unsigned(reg_p0));
                    internal_mem_read_data <= "11";
                    write_flag <= mem_phase;
                    use_address_reg <= '1';
                when cons_store_state =>
                    write_index <= 18;
                    use_address_reg <= '1';
                    if instruction(12) = '0' then
                        mem_write_short <= '1';
                    else
                        mem_write_short <= '0';
                    end if;
                    a_bus_selector <= to_integer(unsigned(reg_p0));
                    b_bus_selector <= 0;
                    alu_opcode <= 1;
                    write_flag <= '1';
                when others => 
                    a_bus_selector <= 0;
                    b_bus_selector <= 0;
                    alu_opcode <= 9;
                    write_index <= 0;
                    write_flag <= '1';
            end case;
        end if;
    end process state_output;

    next_state_calc: process(state, instruction_type, is_a_bus_zero)
    begin
        case state is
            when fetch =>
                next_state <= execute_phase_0;
            when execute_phase_0 =>
                case instruction_type is
                    when immediate_store =>
                        next_state <= imm_store_state;
                    when relative_load =>
                        next_state <= rel_load_state;
                    when relative_store =>
                        next_state <= rel_store_state;
                    when jump_equal_zero =>
                        if is_a_bus_zero = '1' then -- No other conditionals here.
                            next_state <= jump_state;
                        else
                            next_state <= noop_state;
                        end if;
                    when consume_load_address =>
                        next_state <= cons_load_state;
                    when consume_store =>
                        next_state <= cons_store_state;
                    when others =>
                        next_state <= fetch;
                end case;
            when others =>
                next_state <= fetch;
        end case;
    end process next_state_calc;

    state_transition: process(clk, next_state, mem_phase, internal_mem_read_data)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                mem_phase <= '0';
                state <= fetch;
            elsif mem_phase = '0' and internal_mem_read_data /= "00" then
                mem_phase <= '1';
            else 
                mem_phase <= '0';
                state <= next_state;
            end if;
        end if;
    end process state_transition;
end behaviour;