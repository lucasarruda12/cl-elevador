library IEEE;
use IEEE.std_logic_1164.all;

entity simple_elevator is
  generic (w : natural := 5);
  port (
    clk : in  std_logic;
    op  : in  std_logic; -- open door
    cl  : in  std_logic; -- close door
    up  : in  std_logic; -- move up
    dn  : in  std_logic; -- move down
    dr  : out std_logic; -- door status (1=open, 0=closed)
    current_floor  : out std_logic_vector(w-1 downto 0)
  );
end simple_elevator;

architecture arch of simple_elevator is
  component single_call_catcher is
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
  end component;

  component move_counter
    generic (w : natural := 5);
    port (
      clk : in  std_logic;
      up  : in  std_logic;
      dn  : in  std_logic;
      q   : out std_logic_vector(w-1 downto 0)
    );
  end component;

  signal dr_int : std_logic;
  signal up_int : std_logic;
  signal dn_int : std_logic;

begin
  door_inst : door
    port map (clk, op, cl, dr_int);

  up_int <= up and not dr_int;
  dn_int <= dn and not dr_int;
  dr <= dr_int;

  move_counter_inst : move_counter
      generic map (w => w)
      port map (
          clk => clk,
          up => up_int,
          dn => dn_int, --mudei de dn para dn_int
          q => current_floor
      );
end arch;
