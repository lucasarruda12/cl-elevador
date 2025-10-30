library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity next_floor_calculator is
    generic (w : natural := 5);
    port (
        up             : in std_logic;
        dn             : in std_logic;
        current_floor  : integer range 0 to 31;
        next_floor     : out integer range 0 to 31
    );
end next_floor_calculator;

architecture arch of next_floor_calculator is
    signal reg_next : integer;
begin

    -- Calculando floor_index com limite entre 0 e 31
    reg_next <= current_floor + 1 when (up = '1') else
                current_floor - 1 when (dn = '1') else
                current_floor;       


    next_floor <= reg_next when reg_next >= 0 and reg_next <= 31 else
                  0 when reg_next < 0 else 31;        

end arch;
