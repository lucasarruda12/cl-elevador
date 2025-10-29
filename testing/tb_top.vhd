library IEEE;
use IEEE.std_logic_1164.all;
use work.custom_types.all;

entity tb_top is
end tb_top;

architecture tb of tb_top is
  constant w : natural := 5;
  signal clk  : std_logic := '0';

  signal out_kb_up   : std_logic_vector((2**w)-1 downto 0) := (others => '0');
  signal out_kb_down : std_logic_vector((2**w)-1 downto 0) := (others => '0');

  signal el1_kb     : std_logic_vector((2**w)-1 downto 0) := (others => '0');
  signal el1_dr     : std_logic;
  signal el1_floor  : std_logic_vector(w-1 downto 0);
  signal el1_status : std_logic_vector(1 downto 0);

  signal el2_kb     : std_logic_vector((2**w)-1 downto 0) := (others => '0');
  signal el2_dr     : std_logic;
  signal el2_floor  : std_logic_vector(w-1 downto 0);
  signal el2_status : std_logic_vector(1 downto 0);

  signal el3_kb     : std_logic_vector((2**w)-1 downto 0) := (others => '0');
  signal el3_dr     : std_logic;
  signal el3_floor  : std_logic_vector(w-1 downto 0);
  signal el3_status : std_logic_vector(1 downto 0);

  component top is
    generic (w : natural := 5);
    port (
      clk : in std_logic;

      out_kb_up    : in std_logic_vector((2**w)-1 downto 0);
      out_kb_down  : in std_logic_vector((2**w)-1 downto 0);

      el1_kb          : in std_logic_vector((2**w)-1 downto 0);
      el1_dr          : out std_logic;
      el1_floor       : out std_logic_vector(w-1 downto 0);
      el1_status      : out std_logic_vector(1 downto 0);

      el2_kb          : in std_logic_vector((2**w)-1 downto 0);
      el2_dr          : out std_logic;
      el2_floor       : out std_logic_vector(w-1 downto 0);
      el2_status      : out std_logic_vector(1 downto 0);

      el3_kb          : in std_logic_vector((2**w)-1 downto 0);
      el3_dr          : out std_logic;
      el3_floor       : out std_logic_vector(w-1 downto 0);
      el3_status      : out std_logic_vector(1 downto 0));
  end component;
begin
  DUT : top
    generic map (w => 5)
    port map (
      clk => clk,

      out_kb_up    => out_kb_up,
      out_kb_down  => out_kb_down,

      el1_kb          => el1_kb,
      el1_dr          => el1_dr,
      el1_floor       => el1_floor,
      el1_status      => el1_status,

      el2_kb          => el2_kb,
      el2_dr          => el2_dr,
      el2_floor       => el2_floor,
      el2_status      => el2_status,

      el3_kb          => el3_kb,
      el3_dr          => el3_dr,
      el3_floor       => el3_floor,
      el3_status      => el3_status
    );

  -- Simula um clk. Roda pra sempre
  process
  begin
    clk <= '0';
    wait for 10 ps;
    clk <= '1';
    wait for 10 ps;
  end process;

  -- Quero que a simulação pare em algum momento
  process
  begin
    wait for 1000 ps; -- muda aqui o tempo da simulação
    assert false report "Parei aqui!" severity failure;
  end process;

  -- Simula uma única chamada
  process
  begin
    out_kb_down(22) <= '1';
    wait for 20 ps;
    out_kb_down(22) <= '0';
    wait for 440 ps; 
    el1_kb(0) <= '1';
    wait for 20 ps;
    el1_kb(0) <= '0';
    wait;
  end process;

  -- Quero ver se o elevador 1 vai pegar esse cara
  process
  begin
    wait for 500 ps; 
    out_kb_down(16) <= '1';
    wait for 20 ps;
    out_kb_down(16) <= '0';
    wait;
  end process;

  -- Simula uma única chamada
  process
  begin
    wait for 120 ps;
    out_kb_down(10) <= '1';
    wait for 20 ps;
    out_kb_down(10) <= '0';
    wait for 200 ps; 
    el2_kb(0) <= '1';
    wait for 20 ps;
    el2_kb(0) <= '0';
    wait;
  end process;
end tb;
