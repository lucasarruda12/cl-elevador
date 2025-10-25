library IEEE;
use IEEE.std_logic_1164.all;

package custom_types is

  type call is record
    active     : std_logic;
    score      : std_logic_vector(5 downto 0);
    respondent : std_logic_vector(1 downto 0);
  end record;

  type call_vector is array (natural range <>) of call;

end package;
