library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_STD.all;

entity floor_seg_display is
    generic (w : natural := 5);
    port (
        number_input : in std_logic_vector(w-1 downto 0);  -- Número de 0 a 31
        digit0_out   : out std_logic_vector(6 downto 0); -- Unidades
        digit1_out   : out std_logic_vector(6 downto 0)  -- Dezenas
    );
end floor_seg_display;

architecture arch of floor_seg_display is
    
    function int_to_segments(number : integer) return std_logic_vector is
    begin
        case number is
            when 0 => return "0111111"; -- 0
            when 1 => return "0000110"; -- 1
            when 2 => return "1011011"; -- 2
            when 3 => return "1001111"; -- 3
            when 4 => return "1100110"; -- 4
            when 5 => return "1101101"; -- 5
            when 6 => return "1111101"; -- 6
            when 7 => return "0000111"; -- 7
            when 8 => return "1111111"; -- 8
            when 9 => return "1101111"; -- 9
            when others => return "0000000"; -- Apagado
        end case;
    end function;
    
begin
    process(number_input)
        variable unit    : integer;
        variable tens    : integer;
        variable num_int : integer range 0 to 31;
    begin

        num_int := TO_INTEGER(UNSIGNED(number_input));

        -- Extrair dezenas e unidades
        unit := num_int / 10;
        tens := num_int mod 10;
        
        -- Converter para segmentos
        digit0_out <= int_to_segments(unit);
        digit1_out <= int_to_segments(tens);
    end process;
end arch;