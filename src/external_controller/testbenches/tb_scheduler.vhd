library IEEE;
use IEEE.std_logic_1164.all;
use work.custom_types.all;  -- make sure your call_vector type is visible

entity tb_scheduler is
-- testbench has no ports
end tb_scheduler;

architecture tb of tb_scheduler is

  constant w : natural := 5;

  -- DUT signals
  signal clk          : std_logic := '0';

  signal going_up     : std_logic_vector((2**w)-1 downto 0) := (others => '0');
  signal going_down   : std_logic_vector((2**w)-1 downto 0) := (others => '0');

  signal el1_floor     : std_logic_vector(w-1 downto 0) := (others => '0');
  signal el1_status    : std_logic_vector(1 downto 0) := (others => '0');
  signal el1_intention : std_logic_vector(1 downto 0) := (others => '0');
  signal el1_going_up  : std_logic_vector((2**w)-1 downto 0);
  signal el1_going_down: std_logic_vector((2**w)-1 downto 0);

  signal el2_floor     : std_logic_vector(w-1 downto 0) := (others => '0');
  signal el2_status    : std_logic_vector(1 downto 0) := (others => '0');
  signal el2_intention : std_logic_vector(1 downto 0) := (others => '0');
  signal el2_going_up  : std_logic_vector((2**w)-1 downto 0);
  signal el2_going_down: std_logic_vector((2**w)-1 downto 0);

  signal el3_floor     : std_logic_vector(w-1 downto 0) := (others => '0');
  signal el3_status    : std_logic_vector(1 downto 0) := (others => '0');
  signal el3_intention : std_logic_vector(1 downto 0) := (others => '0');
  signal el3_going_up  : std_logic_vector((2**w)-1 downto 0);
  signal el3_going_down: std_logic_vector((2**w)-1 downto 0);

begin

  -- Instantiate DUT
  DUT: entity work.scheduler
    generic map (w => w)
    port map (
      clk            => clk,
      going_up       => going_up,
      going_down     => going_down,

      el1_floor      => el1_floor,
      el1_status     => el1_status,
      el1_intention  => el1_intention,
      el1_going_up   => el1_going_up,
      el1_going_down => el1_going_down,

      el2_floor      => el2_floor,
      el2_status     => el2_status,
      el2_intention  => el2_intention,
      el2_going_up   => el2_going_up,
      el2_going_down => el2_going_down,

      el3_floor      => el3_floor,
      el3_status     => el3_status,
      el3_intention  => el3_intention,
      el3_going_up   => el3_going_up,
      el3_going_down => el3_going_down
    );

  -- Clock generation
  clk_process: process
  begin
    while true loop
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
    end loop;
  end process;

end tb;
