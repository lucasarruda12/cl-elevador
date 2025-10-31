library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity call_analyzer is
  port ( 
    move_up_request   : in std_logic_vector (31 downto 0);
    move_dn_request   : in std_logic_vector (31 downto 0);
    call_dir          : out std_logic_vector(1 downto 0)  := (others => '0')
  );
end call_analyzer;

architecture arch of call_analyzer is
  signal zeros : std_logic_vector(31 downto 0) := (others => '0');
  begin

  call_dir <= "11" when move_up_request /= zeros and move_dn_request /= zeros else   
              "10" when move_up_request /= zeros else
              "01" when move_dn_request /= zeros else
              "00";

end arch;