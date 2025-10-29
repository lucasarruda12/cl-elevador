library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity tb_call_dispatcher is
end tb_call_dispatcher;

architecture sim of tb_call_dispatcher is
  constant w : natural := 3; -- 3 bits = 8 floors
  constant num_floors : integer := 2**w;

  -- Input signals
  signal going_up_caught   : call_vector(num_floors-1 downto 0);
  signal going_down_caught : call_vector(num_floors-1 downto 0);

  -- Output signals
  signal el1_going_up, el1_going_down : std_logic_vector(num_floors-1 downto 0);
  signal el2_going_up, el2_going_down : std_logic_vector(num_floors-1 downto 0);
  signal el3_going_up, el3_going_down : std_logic_vector(num_floors-1 downto 0);
  signal rej_going_up, rej_going_down : call_vector(num_floors-1 downto 0);

begin
  dut : entity work.call_dispatcher
    generic map (w => w)
    port map (
      going_up_caught   => going_up_caught,
      going_down_caught => going_down_caught,
      el1_going_up      => el1_going_up,
      el1_going_down    => el1_going_down,
      el2_going_up      => el2_going_up,
      el2_going_down    => el2_going_down,
      el3_going_up      => el3_going_up,
      el3_going_down    => el3_going_down,
      rej_going_up      => rej_going_up,
      rej_going_down    => rej_going_down
    );

  stim_proc : process
  begin
    for i in 0 to num_floors-1 loop
      going_up_caught(i)   <= (active => '0', score => (others => '0'), respondent => "00");
      going_down_caught(i) <= (active => '0', score => (others => '0'), respondent => "00");
    end loop;

    wait for 20 ns;

    going_up_caught(3).active <= '1';
    going_up_caught(3).respondent <= "01";

    wait;
  end process;

end sim;
