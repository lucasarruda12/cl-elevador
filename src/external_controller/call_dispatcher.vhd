library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity call_dispatcher is
  generic (w : natural := 5);
  port (
    going_up_caught   : in call_vector((2**w)-1 downto 0);
    going_down_caught : in call_vector((2**w)-1 downto 0);

    el1_going_up      : out std_logic_vector((2**w)-1 downto 0);
    el1_going_down    : out std_logic_vector((2**w)-1 downto 0);

    el2_going_up      : out std_logic_vector((2**w)-1 downto 0);
    el2_going_down    : out std_logic_vector((2**w)-1 downto 0);

    el3_going_up      : out std_logic_vector((2**w)-1 downto 0);
    el3_going_down    : out std_logic_vector((2**w)-1 downto 0);

    rej_going_up      : out call_vector((2**w)-1 downto 0);
    rej_going_down    : out call_vector((2**w)-1 downto 0));
end call_dispatcher;

architecture arch of call_dispatcher is
begin
  gen : for i in 0 to (2**w)-1 generate
  begin
    rej_going_up(i) <= going_up_caught(i) when
                       going_up_caught(i).respondent = "00"
                       else ('0', "000000", "00");
      
    el1_going_up(i) <= going_up_caught(i).active when
                       going_up_caught(i).respondent = "01"
                       else '0';

    el2_going_up(i) <= going_up_caught(i).active when
                       going_up_caught(i).respondent = "10"
                       else '0';

    el3_going_up(i) <= going_up_caught(i).active when
                       going_up_caught(i).respondent = "11"
                       else '0';

    rej_going_down(i) <= going_down_caught(i) when
                         going_down_caught(i).respondent = "00"
                         else ('0', "000000", "00");
      
    el1_going_down(i) <= going_down_caught(i).active when
                         going_down_caught(i).respondent = "01"
                         else '0';

    el2_going_down(i) <= going_down_caught(i).active when
                         going_down_caught(i).respondent = "10"
                         else '0';

    el3_going_down(i) <= going_down_caught(i).active when
                         going_down_caught(i).respondent = "11"
                         else '0';
  end generate;
end arch;

