library IEEE;
use IEEE.std_logic_1164.all;

entity score_calc is
  generic (
    w : natural := 5;
    TARGET_FLOOR : std_logic_vector(w-1 downto 0);
    TARGET_INTENTION : std_logic);
  port (
    current_floor       : in std_logic_vector(w-1 downto 0);
    current_direction   : in std_logic_vector(1 downto 0);
    current_intention   : in std_logic;
    score               : out std_logic_vector(w downto 0)); -- Mais um bit!
end score_calc;

architecture arch of score_calc is
-- Falta implementar
end arch;

