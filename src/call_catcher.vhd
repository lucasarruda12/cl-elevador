library IEEE;
use IEEE.std_logic_1164.all;

type call is record
  active : std_logic;
  score  : std_logic_vector(5 downto 0);
  respondent : std_logic_vector(2 downto 0);
end record;

type call_vector is array (natural range <>) of call;

entity call_catcher is
  generic (
    f : natural := 32;  -- Floors in the building
    r : natural;        -- My respondent id
  port (
    going_up          : in  call_vector(f-1 downto 0);
    going_down        : in  call_vector(f-1 downto 0);
    going_up_caught   : out call_vector(f-1 downto 0);
    going_down_caught : out call_vector(f-1 downto 0));
end call_catcher;

architecture arch of call_catcher is
-- Falta implementar
end arch;

