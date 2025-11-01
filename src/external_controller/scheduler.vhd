library IEEE;
use IEEE.std_logic_1164.all;
use work.custom_types.all;

entity scheduler is
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
    el3_going_down  : out std_logic_vector((2**w)-1 downto 0));
end scheduler;

architecture arch of scheduler is
  signal going_up_int    : call_vector((2**w)-1 downto 0);
  signal going_down_int  : call_vector((2**w)-1 downto 0);

  signal rej_going_up    : call_vector((2**w)-1 downto 0);
  signal rej_going_down  : call_vector((2**w)-1 downto 0);

  signal rej_going_up_int : call_vector((2**w)-1 downto 0);
  signal rej_going_down_int : call_vector((2**w)-1 downto 0);

  signal el1_going_up_int : call_vector((2**w)-1 downto 0);
  signal el1_going_down_int : call_vector((2**w)-1 downto 0);
  signal el2_going_up_int : call_vector((2**w)-1 downto 0);
  signal el2_going_down_int : call_vector((2**w)-1 downto 0);
  signal el3_going_up_int : call_vector((2**w)-1 downto 0);
  signal el3_going_down_int : call_vector((2**w)-1 downto 0);

  signal state : std_logic := '0'; -- Checando subidas ('1') ou descidas ('0')
  signal next_state : std_logic := '1'; 

  component call_catcher is
    generic (w : natural := 5);
    port (
      current_floor     : in  std_logic_vector(w-1 downto 0);
      current_status    : in  std_logic_vector(1 downto 0);
      current_intention : in  std_logic_vector(1 downto 0);
      my_resp_id        : in  std_logic_vector(1 downto 0);

      going_up          : in  call_vector((2**w)-1 downto 0);
      going_down        : in  call_vector((2**w)-1 downto 0);

      going_up_caught   : out call_vector((2**w)-1 downto 0);
      going_down_caught : out call_vector((2**w)-1 downto 0)
    );
  end component;

  component call_dispatcher is
    generic (w : natural := 5);
    port (
      clk               : std_logic;
      going_up_caught   : in call_vector((2**w)-1 downto 0);
      going_down_caught : in call_vector((2**w)-1 downto 0);

      el1_going_up      : out std_logic_vector((2**w)-1 downto 0);
      el1_going_down    : out std_logic_vector((2**w)-1 downto 0);

      el2_going_up      : out std_logic_vector((2**w)-1 downto 0);
      el2_going_down    : out std_logic_vector((2**w)-1 downto 0);

      el3_going_up      : out std_logic_vector((2**w)-1 downto 0);
      el3_going_down    : out std_logic_vector((2**w)-1 downto 0);

      rej_going_up      : out call_vector((2**w)-1 downto 0);
      rej_going_down    : out call_vector((2**w)-1 downto 0)
    );
  end component;
begin
    next_state <= not state;

    -- Primeiro trabalho é transformar o vetor do teclado
    -- em um vetor de chamadas
    gen_new_calls : for i in 0 to ((2**w)-1) generate
    begin
        going_up_int(i).score      <= (others => '0');
        going_up_int(i).respondent <= "00";
        going_up_int(i).active     <= '1'
          when going_up(i)='1' or rej_going_up(i).active='1'
          else '0';


        going_down_int(i).score      <= (others => '0');
        going_down_int(i).respondent <= "00";
        going_down_int(i).active <= '1'
          when going_down(i)='1' or rej_going_down(i).active='1'
          else '0';
    end generate; 

    -- Agora já dá pra ir passando isso pra frente
    el1 : call_catcher
      generic map (w => w)
      port map (
      current_floor     => el1_floor,
      current_status    => el1_status,
      current_intention => el1_intention,
      my_resp_id        => "01",

      going_up          => going_up_int,
      going_down        => going_down_int,

      going_up_caught   => el1_going_up_int,
      going_down_caught => el1_going_down_int
      );

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
        clk               => clk,
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
