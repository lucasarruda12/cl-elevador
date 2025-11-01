library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity tb_call_catcher is
end tb_call_catcher;

architecture sim of tb_call_catcher is
  constant w : natural := 5;

  signal current_floor     : std_logic_vector(w-1 downto 0);
  signal current_status    : std_logic_vector(1 downto 0);
  signal current_intention : std_logic_vector(1 downto 0);
  signal my_resp_id        : std_logic_vector(1 downto 0);

  signal going_up, going_up_caught     : call_vector((2**w)-1 downto 0);
  signal going_down, going_down_caught : call_vector((2**w)-1 downto 0);
begin
  dut : entity work.call_catcher
    generic map (w => w)
    port map (
      current_floor     => current_floor,
      current_status    => current_status,
      current_intention => current_intention,
      my_resp_id        => my_resp_id,
      going_up          => going_up,
      going_down        => going_down,
      going_up_caught   => going_up_caught,
      going_down_caught => going_down_caught
    );

  stim_proc : process
  begin
    current_floor     <= (others => '0');
    current_status    <= "00";
    current_intention <= "00";
    my_resp_id        <= "01";

    for i in 0 to (2**w)-1 loop
      going_up(i).active      <= '0';
      going_up(i).respondent  <= "00";
      going_up(i).score  <= (others => '0');

      going_down(i).active      <= '0';
      going_down(i).respondent  <= "00";
      going_down(i).score  <= (others => '0');
    end loop;

    wait for 50 ns;

    report "Activating UP call at floor 3";
    going_up(3).active <= '1';
    wait for 40 ns;

    wait;
  end process;

end sim;
