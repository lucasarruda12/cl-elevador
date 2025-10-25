library IEEE;
use IEEE.std_logic_1164.all;

entity score_calc is
  generic (w : natural := 5);
  port (
    current_floor       : in std_logic_vector(w-1 downto 0);
    current_direction   : in std_logic_vector(1 downto 0);
    current_intention   : in std_logic;
    target_floor        : std_logic_vector(w-1 downto 0);
    target_intention    : std_logic;
    score               : out std_logic_vector(w downto 0)
  );
end score_calc;

architecture arch of score_calc is
begin
-- Falta implementar
end arch;

