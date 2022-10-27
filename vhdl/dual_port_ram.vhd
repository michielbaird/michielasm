library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity dual_port_ram is
    generic(
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
end entity;

architecture behaviour of dual_port_ram is
    type t_data_vector is array (SIZE-1 downto 0) of std_logic_vector(7 downto 0);
    impure function InitRamFromFile (RamFileName : in string) return t_data_vector is
        FILE RamFile : text open read_mode is RamFileName;
        variable RamFileLine : line;
        variable temp_bv : bit_vector(7 downto 0);
        variable RAM : t_data_vector := (others => (others=> '0'));
    begin
        for I in 0 to 699 loop
            readline (RamFile, RamFileLine);
            read(RamFileLine, temp_bv);
            RAM(I) := to_stdlogicvector(temp_bv);
        end loop;
        return RAM;
    end function;
    shared variable internal_ram: t_data_vector :=  InitRamFromFile("C:/Users/Michiel Baird/VHDL/michielasm/michielasm.srcs/ram_out4.data"); -- init_ram_hex; --(others => (others => '0'));--
    signal ram_data_a: std_logic_vector(7 downto 0) := (others => '0');
    signal ram_data_b: std_logic_vector(7 downto 0) := (others => '0');

begin
    douta <= ram_data_a;
    doutb <= ram_data_b;
    port_a_proc: process(clka, addra, dina)
    begin
        if(rising_edge(clka)) then
            if(ena = '1') then
                ram_data_a <= internal_ram(to_integer(unsigned(addra)));

                if (wea = '1') then
                    internal_ram(to_integer(unsigned(addra))) := dina;
                end if;
            end if;
        end if;
    end process port_a_proc;
    
    port_b_proc: process(clkb, addrb, dinb)
    begin
        if(rising_edge(clkb)) then
            if(enb = '1') then
                ram_data_b <= internal_ram(to_integer(unsigned(addrb)));

                if (web = '1') then
                    internal_ram(to_integer(unsigned(addrb))) := dinb;
                end if;
            end if;
        end if;
    end process port_b_proc;

end behaviour;

							
							