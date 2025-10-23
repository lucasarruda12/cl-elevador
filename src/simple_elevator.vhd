library IEEE;
use IEEE.std_logic_1164.all;

entity simple_elevator is
  generic (w : natural := 5);
  port (
    clk : in  std_logic;
    op  : in  std_logic;
    cl  : in  std_logic;
    up  : in  std_logic;
    dn  : in  std_logic;
    dr  : out std_logic;
    fr  : out std_logic_vector(w-1 downto 0)
  );
end simple_elevator;

architecture arch of simple_elevator is
  component door
    port (
      clk : in  std_logic;
      op  : in  std_logic;
      cl  : in  std_logic;
      q   : out std_logic
    );
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
          q => fr
      );
end arch;
