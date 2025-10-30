library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity action_manager is
  generic (w : natural := 5);
  port (
    move_up_request : in std_logic_vector (31 downto 0);
    move_dn_request : in std_logic_vector (31 downto 0);
    next_floor      : in integer range 0 to 31 := 0;
    status          : in std_logic_vector(1 downto 0);
    intention       : in std_logic_vector(1 downto 0);
    at_destination  : out boolean
  );
end action_manager;

architecture arch of action_manager is

begin

end arch;