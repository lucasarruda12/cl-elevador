library IEEE;
use IEEE.std_logic_1164.all;

entity simple_elevator is
  generic (w : natural := 5);
  port (
    clk   : in  std_logic;
    reset : in  std_logic := '0';
    op    : in  std_logic; -- open door
    cl    : in  std_logic; -- close door
    up    : in  std_logic; -- move up
    dn    : in  std_logic; -- move down
    dr    : out std_logic; -- door status (1=open, 0=closed)
    current_floor  : out integer range 0 to 31
  );
end simple_elevator;

architecture arch of simple_elevator is
  component move_counter
    generic (w : natural := 5);
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      up    : in  std_logic;
      dn    : in  std_logic;
      q     : out integer range 0 to 31
    );
  end component;

  component door is
    port (
      clk   : std_logic;
      reset : std_logic;
      op    : std_logic;
      cl    : std_logic;
      q     : out std_logic);
  end component;

  signal dr_int : std_logic;
  signal up_int : std_logic;
  signal dn_int : std_logic;

begin
  door_inst : door
    port map (
      clk   => clk,
      reset => reset,
      op    => op,
      cl    => cl,
      q     => dr_int);

    up_int <= up and not dr_int;
    dn_int <= dn and not dr_int;
    dr <= dr_int;

  move_counter_inst : move_counter
    generic map (w => w)
    port map (
        clk   => clk,
        reset => reset,
        up    => up_int,
        dn  => dn_int, --mudei de dn para dn_int
        q   => current_floor
    );

end arch;
