library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity next_floor_calculator is
    generic (w : natural := 5);
    port (
        up             : in std_logic;
        dn             : in std_logic;
        current_floor  : in std_logic_vector(w-1 downto 0);
        next_floor     : out integer
    );
end next_floor_calculator;

architecture arch of next_floor_calculator is
    signal current_floor_reg : integer := 0;
begin
    current_floor_reg <= to_integer(unsigned(current_floor));

    next_floor <= current_floor_reg + 1 when (up = '1') else
                  current_floor_reg - 1 when (dn = '1') else
                  current_floor_reg;          

end arch;
