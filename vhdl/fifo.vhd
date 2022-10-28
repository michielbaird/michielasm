library ieee;

use IEEE.std_logic_1164.all;

entity fifo is
    generic(
        SIZE: positive := 16;
        DATAWIDTH: positive := 16
    );
    port(
        rst: in std_logic;
        read_clk: in std_logic;
        write_clk: in std_logic;
        read_en: in std_logic;
        write_en: in std_logic;
        data_in: in std_logic_vector(DATAWIDTH-1 downto 0);
        data_out: out std_logic_vector(DATAWIDTH-1 downto 0);
        is_empty: out std_logic;
        is_full: out std_logic
    );
end entity;

architecture behaviour of fifo is
    --signal a_and_b: std_logic;
    signal internal_is_full: std_logic;
    --signal internal_is_empty: std_logic;

begin
    
    fifo_proc: process(rst, write_clk, read_clk, read_en, write_en, data_in)
        type memory_t is array (0 to SIZE-1) of std_logic_vector(DATAWIDTH-1 downto 0);
        variable memory: memory_t := (others => (others => '0'));
        variable head_p: integer := 0;
        variable tail_p: integer := 0;
        variable inverted_r: std_logic := '0';
        variable inverted_w: std_logic := '0';
        variable inverted: std_logic := '0';
        --variable inverted: std_logic := '0';
    begin


        if rising_edge(read_clk) then
            if rst = '1' then
                head_p := 0;
                inverted_r := '0';
            elsif read_en = '1' then
                if inverted = '1' or head_p /= tail_p then
                    data_out <= memory(head_p);
                    if head_p = SIZE -1 then
                        inverted_r := not inverted_r;
                        head_p := 0;
                    else
                        head_p := head_p + 1;
                    end if;
                end if;
            else
                data_out <= memory(head_p); 
            end if;
        end if;

        if rising_edge(write_clk) then
            if rst = '1' then
                tail_p := 0;
                inverted_w := '0';
            elsif write_en = '1' then
                if inverted = '0' or head_p /= tail_p then
                    memory(tail_p) := data_in;
                    if tail_p = SIZE - 1 then
                        tail_p := 0;
                        inverted_w := not inverted_w;    
                    else
                        tail_p := tail_p + 1;
                    end if;
                end if;
            end if;
        end if;
        inverted := inverted_r xor inverted_w;
        
        if head_p = tail_p then
            if inverted = '1' then
                is_full <= '1';
                is_empty <= '0';
            else
                is_empty <= '1';
                is_full <= '0';
            end if;
        else
            is_full <= '0';
            is_empty <= '0';
        end if;
    end process fifo_proc;

end behaviour;

