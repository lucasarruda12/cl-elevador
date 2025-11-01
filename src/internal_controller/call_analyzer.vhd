library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity call_analyzer is
    port ( 
        move_up_request : in std_logic_vector(31 downto 0);
        move_dn_request : in std_logic_vector(31 downto 0);
        call_dir        : out std_logic_vector(1 downto 0)
    );
end call_analyzer;

architecture arch of call_analyzer is
    constant zeros : std_logic_vector(31 downto 0) := (others => '0');
begin
    call_dir(1) <= '1' when move_up_request /= zeros else '0'; -- Chamadas para cima
    call_dir(0) <= '1' when move_dn_request /= zeros else '0'; -- Chamadas para baixo
end arch;