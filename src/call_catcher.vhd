library IEEE;
use IEEE.std_logic_1164.all;
use work.custom_types.call;

entity call_catcher is
  generic (w : natural := 5);
  port (
    current_floor     : in std_logic_vector(w-1 downto 0);
    current_direction : in std_logic_vector(1 downto 0);
    current_intention : in std_logic;
    target_floor      : in std_logic_vector(w-1 downto 0);
    target_intention  : in std_logic;
    my_resp_id        : in std_logic_vector(1 downto 0);
    call_in           : in call;
    call_out          : out call);
end call_catcher;

architecture arch of call_catcher is
  component score_calc
    generic (w : natural := 5);
  port (
    current_floor       : in std_logic_vector(w-1 downto 0);
    current_direction   : in std_logic_vector(1 downto 0);
    current_intention   : in std_logic;
    target_floor        : in std_logic_vector(w-1 downto 0);
    target_intention    : in std_logic;
    score               : out std_logic_vector(w downto 0));
  end component;

  signal my_score : std_logic_vector(w downto 0);
begin
  score_calc_inst : score_calc
      generic map (w => w)
      port map (
          current_floor => current_floor,
          current_direction => current_direction,
          current_intention => current_intention,
          target_floor => target_floor,
          target_intention => target_intention,
          score => my_score
      );

  call_out.active <= call_in.active; 
  call_out.score  <= my_score when my_score > call_in.score
                     else call_in.score;

  call_out.respondent <= my_resp_id when my_score > call_in.score
                         else call_in.respondent;
end arch;
