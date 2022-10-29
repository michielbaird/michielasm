library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;

entity cpu is
    generic(
        MEMORY_FILE: string := "ram_out.data";
        INPUT_CLOCK_SPEED_HZ: integer :=  100_000_000;
        UART_CLOCK_SPEED_HZ: integer := 115200
    );
    port(
        rst: in std_logic;
        clk: in std_logic;
        uart_tx: out std_logic;
        uart_rx: in std_logic;
        ins: out std_logic_vector(15 downto 0)
    );
    
end entity;

architecture behaviour of cpu is
    component flag_register is
        generic(
            DATAWIDTH: integer range 4 to 128 := 16;
            on_rising_edge: bit := '1'
        );
        port(
            rst: in std_logic;
            clk: in std_logic;
            data_in: in std_logic_vector(2 downto 0);
            data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
            write_flag: in std_logic;
            error_in: in std_logic;
            overflow_in: in std_logic;
            underflow_in: in std_logic;
            output_full_flag: in std_logic;
            input_available_flag: in std_logic
        );
    end component;
    component program_counter is
        generic(
            DATAWIDTH: positive:= 16;
            INCREMENT: positive:= 2
        );
        port(
            rst: in std_logic;
            clk: in std_logic;
            write_flag: in std_logic;
            value: out std_logic_vector(DATAWIDTH-1 downto 0);
            override: in std_logic;
            override_value: in std_logic_vector(DATAWIDTH-1 downto 0)
        );
    end component;
    component io_register is
        generic(
            DATAWIDTH: positive := 16;
            on_rising_edge: bit := '1'
        );
        port(
            rst: in std_logic;
            clk: in std_logic;
            data_in: in std_logic_vector(DATAWIDTH-1 downto 0);
            data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
            write_flag: in std_logic
        );
    end component;
    component dual_port_ram is
        generic(
            MEMORY_FILE: string := MEMORY_FILE;
            SIZE: integer := 2**16
        );
        port(
             addra : in std_logic_vector(15 downto 0);                          -- Port A Address bus, width determined from RAM_DEPTH
             addrb : in std_logic_vector(15 downto 0);                          -- Port B Address bus, width determined from RAM_DEPTH
             dina  : in std_logic_vector(7 downto 0);                         -- Port A RAM input data
             dinb  : in std_logic_vector(7 downto 0);                         -- Port B RAM input data
             clka  : in std_logic;                                                                 -- Port A Clock
             clkb  : in std_logic;                                                                 -- Port B Clock
             wea   : in std_logic;                                     -- Port A Write enable
             web   : in std_logic;                                     -- Port B Write enable
             ena   : in std_logic;                                                                 -- Port A RAM Enable, for additional power savings, disable port when not in use
             enb   : in std_logic;                                                                 -- Port B RAM Enable, for additional power savings, disable port when not in use
             douta : out std_logic_vector(7 downto 0);
             doutb : out std_logic_vector(7 downto 0)   
        );
    end component;
    
    component ArithmaticLogicUnit is
        generic(
            BITWIDTH: integer := 16
        );
        port(
            A: in std_logic_vector(BITWIDTH-1 downto 0);
            B: in std_logic_vector(BITWIDTH-1 downto 0);
            OPCODE: in integer range 0 to 9;
            RESULT: out std_logic_vector(BITWIDTH - 1 downto 0);
            overflow: out std_logic;
            underflow: out std_logic
        );
    end component;
    component zero_register is
        generic(
            DATAWIDTH: positive := 16;
            on_rising_edge: bit := '1'
        );
        port(
            data_in: in std_logic_vector(DATAWIDTH-1 downto 0);
            data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
            error: out std_logic
        );
    end component;

    component demux is
        generic(
            count: integer := 19
        );
        port (
            enable: in std_logic;
            write_index: in integer range 0 to (count-1);
            output: out std_logic_vector(count-1 downto 0)
        );
    end component;

    component state_machine is
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
    end component;

    component uart_register is
        generic(
            INPUT_CLOCK_SPEED_HZ: integer :=  INPUT_CLOCK_SPEED_HZ;
            UART_CLOCK_SPEED_HZ: integer := UART_CLOCK_SPEED_HZ
        );
        port(
            rst: in std_logic;
            clk: in std_logic;
            data_in: in std_logic_vector(7 downto 0);
            data_out: out std_logic_vector(15 downto 0);
            uart_tx: out std_logic;
            uart_rx: in std_logic;
            uart_rx_read: in std_logic;
            write_flag: in std_logic;
            is_full: out std_logic;
            has_data: out std_logic
        );
    end component;
    
     -- Generic Registers -- 
    type t_register_data is array(20 downto 0) of std_logic_vector(15 downto 0);
    signal register_out: t_register_data;
    signal register_write_data: std_logic_vector(18 downto 0);
    signal write_index: integer range register_write_data'range;
    signal write_flag: std_logic;
    signal consume_input: std_logic; -- xcxc

    -- Memory Unit Control --
    signal mem_read_data: std_logic_vector(1 downto 0);
    signal mem_write_short: std_logic;
    signal mem_address_line: std_logic_vector(15 downto 0);
    signal mem_address_line2: std_logic_vector(15 downto 0);
    signal mem_enable: std_logic;
    signal write_enable_high: std_logic;
    alias write_enable_low: std_logic is register_write_data(18);
    signal use_address_reg: std_logic;
    signal mem_out_low: std_logic_vector(7 downto 0);
    signal mem_out_high: std_logic_vector(7 downto 0);


    -- Zero Register Control --
    signal zero_error: std_logic; 

    -- PROGRAM COUNTER CONTROL --
    signal pc_write_flag: std_logic;

    -- FLAG REGISTER CONTROL --
    signal fr_error_in: std_logic;
    signal fr_overflow_in: std_logic;
    signal fr_underflow_in: std_logic;
    signal output_full_flag: std_logic;
    signal input_has_data: std_logic;

    -- A BUS -- 
    signal A_data_bus: std_logic_vector(15 downto 0);
    signal A_bus_selector: integer range 0 to 20; -- xcxc

    -- B BUS -- 
    signal B_data_bus: std_logic_vector(15 downto 0);
    signal B_bus_selector: integer range 0 to 20; -- xcxc

    -- RESULT BUS -- 
    signal result_data_bus: std_logic_vector(15 downto 0);
    signal is_a_bus_zero: std_logic;

    -- ALU Control --
    signal alu_opcode: integer range 0 to 9;
    signal alu_result: std_logic_vector(15 downto 0);
    signal alu_overflow_out: std_logic;
    signal alu_underflow_out: std_logic;

    -- Instruction alias --
    alias di_value: std_logic_vector(6 downto 0) is register_out(17)(9 downto 3);
    alias si_value: std_logic_vector(8 downto 0) is register_out(17)(12 downto 4);
    
    signal test_f: std_logic;

begin
    --uart_tx <= not test_f;
    MEM_UNIT: dual_port_ram
        port map(
             addra => mem_address_line,                         -- Port A Address bus, width determined from RAM_DEPTH
             addrb => mem_address_line2,                         -- Port B Address bus, width determined from RAM_DEPTH
             dina => result_data_bus(7 downto 0),                         -- Port A RAM input data
             dinb => result_data_bus(15 downto 8),                         -- Port B RAM input data
             clka => clk,                                                                 -- Port A Clock
             clkb => clk,                                                           -- Port B Clock
             wea => write_enable_low,                                    -- Port A Write enable
             web => write_enable_high,                                   -- Port B Write enable
             ena => mem_enable,                                                                 -- Port A RAM Enable, for additional power savings, disable port when not in use
             enb => mem_enable,                                                                 -- Port B RAM Enable, for additional power savings, disable port when not in use
             douta => mem_out_low,
             doutb => mem_out_high
        );
    write_enable_high <= write_enable_low and mem_write_short;
    mem_enable <= '1' when (mem_read_data /= "00" or write_enable_low = '1') else '0';

    --mem_write_clk <= clk and register_write_data(18);
    
    ZERO_REG: zero_register
        port map(result_data_bus, register_out(0), zero_error);
    
    IO_REG_1: io_register port map(rst, clk, result_data_bus, register_out(1), register_write_data(1));
    IO_REG_2: io_register port map(rst, clk, result_data_bus, register_out(2), register_write_data(2));
    IO_REG_3: io_register port map(rst, clk, result_data_bus, register_out(3), register_write_data(3));
    IO_REG_4: io_register port map(rst, clk, result_data_bus, register_out(4), register_write_data(4));
    IO_REG_5: io_register port map(rst, clk, result_data_bus, register_out(5), register_write_data(5));
    IO_REG_6: io_register port map(rst, clk, result_data_bus, register_out(6), register_write_data(6));
    IO_REG_7: io_register port map(rst, clk, result_data_bus, register_out(7), register_write_data(7));
    
    PC: program_counter port map(rst, clk, pc_write_flag, register_out(8), register_write_data(8), result_data_bus);

    FLAG_REG: flag_register port map(rst, clk, result_data_bus(2 downto 0), register_out(9), register_write_data(9), fr_error_in, fr_overflow_in, fr_underflow_in, output_full_flag, input_has_data);

    SP_REG_2: uart_register port map(
        rst => rst, 
        clk => clk, 
        data_in => result_data_bus(7 downto 0), 
        data_out => register_out(10), 
        uart_tx => uart_tx,
        uart_rx => uart_rx,
        uart_rx_read => consume_input,  
        write_flag => register_write_data(10), 
        is_full => output_full_flag,
        has_data => input_has_data
    );
    consume_input <= '1' when write_flag = '1' and (a_bus_selector = 10 or b_bus_selector = 10) else '0';

    SP_REG_3: io_register port map(rst, clk, result_data_bus, register_out(11), register_write_data(11));
    SP_REG_4: io_register port map(rst, clk, result_data_bus, register_out(12), register_write_data(12));
    SP_REG_5: io_register port map(rst, clk, result_data_bus, register_out(13), register_write_data(13));
    SP_REG_6: io_register port map(rst, clk, result_data_bus, register_out(14), register_write_data(14));
    SP_REG_7: io_register port map(rst, clk, result_data_bus, register_out(15), register_write_data(15));

    ADD_REG: io_register port map(rst, clk, result_data_bus, register_out(16), register_write_data(16));
    
    mem_address_line <= register_out(16) when use_address_reg = '1' else register_out(8);
    add_proc: process(mem_address_line)
        variable address_int: integer;
    begin
        address_int := to_integer(unsigned(mem_address_line));
        if address_int = (2**16) - 1 then
            mem_address_line2 <= (others => '0');
        else
            mem_address_line2 <= std_logic_vector(to_unsigned(address_int + 1, mem_address_line2'length));
        end if;
    end process add_proc;
    
    INS_REG: io_register port map(rst, clk, result_data_bus, register_out(17), register_write_data(17));
    ins <= register_out(17);
    
    register_out(18) <= (15 downto 7 => '0') & di_value(6 downto 0);
    register_out(19) <= (15 downto 9 => '0') & si_value(8 downto 0);
    register_out(20) <= (15 downto 8 => '0') & si_value(7 downto 0);


    WRITE_DEMUX: demux port map(write_flag, write_index, register_write_data);

    SM: state_machine 
        port map (
            register_out(17),
            clk,
            rst,
            is_a_bus_zero,
            pc_write_flag,
            mem_read_data,
            mem_write_short,
            a_bus_selector,
            b_bus_selector,
            alu_opcode,
            write_flag,
            write_index,
            use_address_reg
        );

    a_mux: process(register_out, A_bus_selector)
    begin
        case A_bus_selector is
            when 0 => 
                A_data_bus <= register_out(0);
            when 1 =>
                A_data_bus <= register_out(1);
            when 2 =>
                A_data_bus <= register_out(2);
            when 3 =>
                A_data_bus <= register_out(3);
            when 4 =>
                A_data_bus <= register_out(4);
            when 5 =>
                A_data_bus <= register_out(5);
            when 6 => 
                A_data_bus <= register_out(6);
            when 7 =>
                A_data_bus <= register_out(7);
            when 8 =>
                A_data_bus <= register_out(8);
            when 9 =>
                A_data_bus <= register_out(9);
            when 10 =>
                A_data_bus <= register_out(10);
            when 11 =>
                A_data_bus <= register_out(11);
            when 12 =>
                A_data_bus <= register_out(12);
            when 13 =>
                A_data_bus <= register_out(13);
            when 14 =>
                A_data_bus <= register_out(14);
            when 15 =>
                A_data_bus <= register_out(15);
            when 16 =>
                A_data_bus <= register_out(16);
            when 18 =>
                A_data_bus <= register_out(18);
            when 19 =>
                A_data_bus <= register_out(19);
            when 20 =>
                A_data_bus <= register_out(20);
            when others =>
                A_data_bus <= (others => '0');
        end case;

    end process a_mux;

    b_mux: process(register_out, B_bus_selector)
    begin
        case B_bus_selector is
            when 0 => 
                B_data_bus <= register_out(0);
            when 1 =>
                B_data_bus <= register_out(1);
            when 2 =>
                B_data_bus <= register_out(2);
            when 3 =>
                B_data_bus <= register_out(3);
            when 4 =>
                B_data_bus <= register_out(4);
            when 5 =>
                B_data_bus <= register_out(5);
            when 6 => 
                B_data_bus <= register_out(6);
            when 7 =>
                B_data_bus <= register_out(7);
            when 8 =>
                B_data_bus <= register_out(8);
            when 9 =>
                B_data_bus <= register_out(9);
            when 10 =>
                B_data_bus <= register_out(10);
            when 11 =>
                B_data_bus <= register_out(11);
            when 12 =>
                B_data_bus <= register_out(12);
            when 13 =>
                B_data_bus <= register_out(13);
            when 14 =>
                B_data_bus <= register_out(14);
            when 15 =>
                B_data_bus <= register_out(15);
            when 16 =>
                B_data_bus <= register_out(16);
            when 18 =>
                B_data_bus <= register_out(18);
            when 19 =>
                B_data_bus <= register_out(19);
            when others =>
                B_data_bus <= (others => '0');
        end case;
    end process b_mux;
    
    ALU: ArithmaticLogicUnit port map(A_data_bus, B_data_bus, alu_opcode, alu_result, alu_overflow_out, alu_underflow_out);
    
    result_bus_proc: process(alu_result, mem_read_data, mem_out_high, mem_out_low)
    begin
        case mem_read_data is
            when "00" =>
                result_data_bus <= alu_result;
            when "01" =>
                result_data_bus <= (15 downto 8 => '0') & mem_out_low;
            when "10"|"11" =>
                result_data_bus <= mem_out_high & mem_out_low;
            when others =>
                result_data_bus <= (others => 'X');
        end case;
    end process result_bus_proc; 


    alu_errors: process(mem_read_data, write_flag, alu_overflow_out, alu_underflow_out)
    begin
        if mem_read_data = "00" and write_flag = '1' then
            fr_underflow_in <= alu_underflow_out;
            fr_overflow_in <= alu_overflow_out;
        else 
            fr_underflow_in <= '0';
            fr_overflow_in <= '0';
        end if;
    end process alu_errors;

    fr_error_in <= register_write_data(0) and zero_error;
    is_a_bus_zero <= '1' when A_data_bus = (A_data_bus'range => '0') else '0';

end behaviour;