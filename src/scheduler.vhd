library IEEE;
use IEEE.std_logic_1164.all;
use work.custom_types.all;

entity scheduler is
  generic (w : natural := 5);
  port (
    clk : in std_logic;

    going_up    : in std_logic_vector(w-1 downto 0);
    going_down  : in std_logic_vector(w-1 downto 0);

    rej_going_up    : in call_vector(0 to (2**w)-1);
    rej_going_down  : in call_vector(0 to (2**w)-1);

    el1_floor       : in std_logic_vector(w-1 downto 0);
    el1_status      : in std_logic_vector(1 downto 0);
    el1_intention   : in std_logic;
    el1_going_up    : out call_vector(0 to (2**w)-1);
    el1_going_down  : out call_vector(0 to (2**w)-1);

    el2_floor       : in std_logic_vector(w-1 downto 0);
    el2_status      : in std_logic_vector(1 downto 0);
    el2_intention   : in std_logic;
    el2_going_up    : out call_vector(0 to (2**w)-1);
    el2_going_down  : out call_vector(0 to (2**w)-1);

    el3_floor       : in std_logic_vector(w-1 downto 0);
    el3_status      : in std_logic_vector(1 downto 0);
    el3_intention   : in std_logic;
    el3_going_up    : out call_vector(0 to (2**w)-1);
    el3_going_down  : out call_vector(0 to (2**w)-1);
end scheduler;

architecture arch of scheduler is
  signal rej_going_up_int : call_vector(0 to (2**w)-1);
  signal rej_going_down_int : call_vector(0 to (2**w)-1);
  signal el1_going_up_int : call_vector(0 to (2**w)-1);
  signal el1_going_down_int : call_vector(0 to (2**w)-1);
  signal el2_going_up_int : call_vector(0 to (2**w)-1);
  signal el2_going_down_int : call_vector(0 to (2**w)-1);
  signal el3_going_up_int : call_vector(0 to (2**w)-1);
  signal el3_going_down_int : call_vector(0 to (2**w)-1);

  component call_catcher is
    generic (w : natural := 5);
    port (
      current_floor     : in  std_logic_vector(w-1 downto 0);
      current_status    : in  std_logic_vector(1 downto 0);
      current_intention : in  std_logic;
      my_resp_id        : in  std_logic_vector(1 downto 0);

      going_up          : in  call_vector(0 to (2**w)-1);
      going_down        : in  call_vector(0 to (2**w)-1);

      going_up_caught   : out call_vector(0 to (2**w)-1);
      going_down_caught : out call_vector(0 to (2**w)-1)
    );
  end component;

  component call_dispatcher is
    generic (w : natural := 5);
    port (
      going_up_caught   : in call_vector(0 to (2**w)-1);
      going_down_caught : in call_vector(0 to (2**w)-1);

      el1_going_up      : out std_logic_vector((2**w)-1 downto 0);
      el1_going_down    : out std_logic_vector((2**w)-1 downto 0);

      el2_going_up      : out std_logic_vector((2**w)-1 downto 0);
      el2_going_down    : out std_logic_vector((2**w)-1 downto 0);

      el3_going_up      : out std_logic_vector((2**w)-1 downto 0);
      el3_going_down    : out std_logic_vector((2**w)-1 downto 0);

      rej_going_up      : out std_logic_vector((2**w)-1 downto 0);
      rej_going_down    : out std_logic_vector((2**w)-1 downto 0)
    );
  end component;
begin
    -- Primeiro trabalho é transformar o vetor do teclado
    -- em um vetor de chamadas
    gen_calls : for i in 0 to (2**w)-1 generate
    begin
        rej_going_up_int(i).active     <= going_up(i);
        rej_going_up_int(i).score      <= "000000";
        rej_going_up_int(i).respondent <= "00";

        rej_going_down_int(i).active     <= going_down(i);
        rej_going_down_int(i).score      <= "000000";
        rej_going_down_int(i).respondent <= "00";
    end generate; 

    -- Segundo trabalho é recolocar os rejeitados do clock passado
    gen_calls : for i in 0 to (2**w)-1 generate
    begin
        rej_going_up_int(i).active     
        <= '1'
           when rej_going_up(i).active='1' 
           else rej_going_up_int(i).active;

        rej_going_down_int(i).active
        <= '1'
           when rej_going_down(i).active='1' 
           else rej_going_down_int(i).active;
    end generate; 

    -- Agora já dá pra ir passando isso pra frente
    el1 : call_catcher
      generic map (w => w)
      port map (
      current_floor     => el1_floor,
      current_status    => el1_status,
      current_intention => el1_intention,
      my_resp_id        => "01",

      going_up          => rej_going_up_int,
      going_down        => rej_going_down_int,

      going_up_caught   => el1_going_up_int,
      going_down_caught => el1_going_down_int
      );

    -- Agora já dá pra ir passando isso pra frente
    el2 : call_catcher
      generic map (w => w)
      port map (
      current_floor     => el2_floor,
      current_status    => el2_status,
      current_intention => el2_intention,
      my_resp_id        => "10",

      going_up          => el1_going_up_int,
      going_down        => el1_going_down_int,

      going_up_caught   => el2_going_up_int,
      going_down_caught => el2_going_down_int
      );

    el3 : call_catcher
      generic map (w => w)
      port map (
      current_floor     => el3_floor,
      current_status    => el3_status,
      current_intention => el3_intention,
      my_resp_id        => "11",

      going_up          => el2_going_up_int,
      going_down        => el2_going_down_int,

      going_up_caught   => el3_going_up_int,
      going_down_caught => el3_going_down_int
      );

    dispatcher : call_dispatcher
      generic map (w => w)
      port map (
        going_up_caught   => el3_going_up_int,
        going_down_caught => el3_going_down_int,

        el1_going_up      => el1_going_up,
        el1_going_down    => el1_going_down,

        el2_going_up      => el2_going_up,
        el2_going_down    => el2_going_down,

        el3_going_up      => el3_going_up,
        el3_going_down    => el3_going_down,

        rej_going_up      => rej_going_up_int,
        rej_going_down    => rej_going_down_int
      );

  
  process(clk)
  begin
    if (clk'event and clk='1') then
      rej_going_up    <= rej_going_up_int;
      rej_going_down  <= rej_going_down_int;
    end if;
  end process;
end arch;
