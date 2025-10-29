library IEEE;
use IEEE.std_logic_1164.all;

entity top is
  generic (w : natural := 5);
  port (
    clk : in std_logic;

    out_kb_up    : in std_logic_vector((2**w)-1 downto 0);
    out_kb_down  : in std_logic_vector((2**w)-1 downto 0);

    el1_kb          : in std_logic_vector((2**w)-1 downto 0);
    el1_floor       : out std_logic_vector(w-1 downto 0);
    el1_status      : out std_logic_vector(1 downto 0);

    el2_kb          : in std_logic_vector((2**w)-1 downto 0);
    el2_floor       : out std_logic_vector(w-1 downto 0);
    el2_status      : out std_logic_vector(1 downto 0);

    el3_kb          : in std_logic_vector((2**w)-1 downto 0);
    el3_floor       : out std_logic_vector(w-1 downto 0);
    el3_status      : out std_logic_vector(1 downto 0)
  );
end top;

architecture arch of top is
  signal out_kb_up_int    : std_logic_vector((2**w)-1 downto 0);
  signal out_kb_down_int  : std_logic_vector((2**w)-1 downto 0);

  signal el1_floor_int       : std_logic_vector(w-1 downto 0);
  signal el1_status_int      : std_logic_vector(1 downto 0);
  signal el1_intention_int   : std_logic_vector(1 downto 0);
  signal el1_going_up_int    : std_logic_vector((2**w)-1 downto 0);
  signal el1_going_down_int  : std_logic_vector((2**w)-1 downto 0);

  signal el2_floor_int       : std_logic_vector(w-1 downto 0);
  signal el2_status_int      : std_logic_vector(1 downto 0);
  signal el2_intention_int   : std_logic_vector(1 downto 0);
  signal el2_going_up_int    : std_logic_vector((2**w)-1 downto 0);
  signal el2_going_down_int  : std_logic_vector((2**w)-1 downto 0);

  signal el3_floor_int       : std_logic_vector(w-1 downto 0);
  signal el3_status_int      : std_logic_vector(1 downto 0);
  signal el3_intention_int   : std_logic_vector(1 downto 0);
  signal el3_going_up_int    : std_logic_vector((2**w)-1 downto 0);
  signal el3_going_down_int  : std_logic_vector((2**w)-1 downto 0);

  component in_controller is
    generic (w : natural := 5);
    port (
      clk               : in std_logic;
      int_floor_request : in std_logic_vector(31 downto 0);
      move_up_request   : in std_logic_vector (31 downto 0);
      move_dn_request   : in std_logic_vector (31 downto 0);
      current_floor     : out std_logic_vector(w-1 downto 0);
      status            : out std_logic_vector(1 downto 0);
      intention         : out std_logic_vector(1 downto 0)
    );
  end component;

  component scheduler is
    generic (w : natural := 5);
    port (
      clk : in std_logic;

      going_up    : in std_logic_vector((2**w)-1 downto 0);
      going_down  : in std_logic_vector((2**w)-1 downto 0);

      el1_floor       : in std_logic_vector(w-1 downto 0);
      el1_status      : in std_logic_vector(1 downto 0);
      el1_intention   : in std_logic_vector(1 downto 0);
      el1_going_up    : out std_logic_vector((2**w)-1 downto 0);
      el1_going_down  : out std_logic_vector((2**w)-1 downto 0);

      el2_floor       : in std_logic_vector(w-1 downto 0);
      el2_status      : in std_logic_vector(1 downto 0);
      el2_intention   : in std_logic_vector(1 downto 0);
      el2_going_up    : out std_logic_vector((2**w)-1 downto 0);
      el2_going_down  : out std_logic_vector((2**w)-1 downto 0);

      el3_floor       : in std_logic_vector(w-1 downto 0);
      el3_status      : in std_logic_vector(1 downto 0);
      el3_intention   : in std_logic_vector(1 downto 0);
      el3_going_up    : out std_logic_vector((2**w)-1 downto 0);
      el3_going_down  : out std_logic_vector((2**w)-1 downto 0)
    );
  end component;

begin
  out_kb_up_int   <= out_kb_up; 
  out_kb_down_int <= out_kb_down; 

  el1 : in_controller
  generic map (w => w)
  port map(
    clk               => clk,
    int_floor_request => el1_kb,
    move_up_request   => el1_going_up_int,
    move_dn_request   => el1_going_down_int,
    current_floor     => el1_floor_int,
    status            => el1_status_int,
    intention         => el1_intention_int
  );

  el2 : in_controller
  generic map (w => w)
  port map(
    clk               => clk,
    int_floor_request => el2_kb,
    move_up_request   => el2_going_up_int,
    move_dn_request   => el2_going_down_int,
    current_floor     => el2_floor_int,
    status            => el2_status_int,
    intention         => el2_intention_int
  );

  el3 : in_controller
  generic map (w => w)
  port map(
    clk               => clk,
    int_floor_request => el3_kb,
    move_up_request   => el3_going_up_int,
    move_dn_request   => el3_going_down_int,
    current_floor     => el3_floor_int,
    status            => el3_status_int,
    intention         => el3_intention_int
  );

  sch : scheduler
  generic map (w => w)
  port map(
    clk             => clk,
    going_up        => out_kb_up_int,
    going_down      => out_kb_down_int,

    el1_floor       => el1_floor_int,
    el1_status      => el1_status_int,
    el1_intention   => el1_intention_int,
    el1_going_up    => el1_going_up_int,
    el1_going_down  => el1_going_down_int,

    el2_floor       => el2_floor_int,
    el2_status      => el2_status_int,
    el2_intention   => el2_intention_int,
    el2_going_up    => el2_going_up_int,
    el2_going_down  => el2_going_down_int,

    el3_floor       => el3_floor_int,
    el3_status      => el3_status_int,
    el3_intention   => el3_intention_int,
    el3_going_up    => el3_going_up_int,
    el3_going_down  => el3_going_down_int
  );

  el1_floor  <= el1_floor_int;
  el1_status <= el1_status_int;

  el2_floor  <= el2_floor_int;
  el2_status <= el2_status_int;

  el3_floor  <= el3_floor_int;
  el3_status <= el3_status_int;
end arch;
