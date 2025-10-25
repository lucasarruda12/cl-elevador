library IEEE;
use IEEE.std_logic_1164.all;
use work.custom_types.all;

entity call_catcher is
  generic (w : natural := 5);
  port (
    el1_floor     : in std_logic_vector(w-1 downto 0);
    el1_direction : in std_logic_vector(1 downto 0);
    el1_intention : in std_logic;

    el2_floor     : in std_logic_vector(w-1 downto 0);
    el2_direction : in std_logic_vector(1 downto 0);
    el2_intention : in std_logic;

    el3_floor     : in std_logic_vector(w-1 downto 0);
    el3_direction : in std_logic_vector(1 downto 0);
    el3_intention : in std_logic;

    going_up          : in  call_vector(0 to (2**w)-1);
    going_down        : in  call_vector(0 to (2**w)-1);
end call_catcher;

architecture arch of scheduler is
begin
  -- Falta implementar
end arch;
