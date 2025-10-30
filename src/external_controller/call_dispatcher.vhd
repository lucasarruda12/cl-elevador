library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity call_dispatcher is
  generic (w : natural := 5);
  port (
    clk               : in std_logic;

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
  signal current_direction : std_logic := '0';
  signal next_direction : std_logic := '1';
begin
  gen : for i in 0 to (2**w)-1 generate
  begin
    rej_going_up(i) <= (going_up_caught(i).active, (others => '0'), "00") when
                       (going_up_caught(i).respondent = "00"
                       or current_direction='0') -- estou checando as descidas
                       else ('0', (others => '0'), "00");
      
    el1_going_up(i) <= going_up_caught(i).active when
                       (going_up_caught(i).respondent = "01"
                       and current_direction='1') -- Só se eh estou checando as subidas
                       else '0';

    el2_going_up(i) <= going_up_caught(i).active when
                       (going_up_caught(i).respondent = "10" 
                       and current_direction='1') -- Só se checando as subidas
                       else '0';

    el3_going_up(i) <= going_up_caught(i).active when
                       (going_up_caught(i).respondent = "11"
                       and current_direction='1')
                       else '0';

    rej_going_down(i) <= (going_down_caught(i).active, (others => '0'), "00") when
                       (going_down_caught(i).respondent = "00"
                       or current_direction='1') -- estou checando as subidas
                       else ('0', (others => '0'), "00");
      
    el1_going_down(i) <= going_down_caught(i).active when
                       (going_down_caught(i).respondent = "01"
                       and current_direction='0') -- Só se eh estou checando as descidas
                       else '0';

    el2_going_down(i) <= going_down_caught(i).active when
                       (going_down_caught(i).respondent = "10" 
                       and current_direction='0') -- Só se checando as descidas
                       else '0';

    el3_going_down(i) <= going_down_caught(i).active when
                       (going_down_caught(i).respondent = "11"
                       and current_direction='0')
                       else '0';
  end generate;

  next_direction <= not current_direction;

  process(clk)
  begin
    if (clk'event and clk='1') then
      current_direction <= next_direction;
    end if;
  end process;
end arch;

