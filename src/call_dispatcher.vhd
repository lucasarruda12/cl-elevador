library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity call_dispatcher is
  generic (w : natural := 5);
  port (
    current_floor     : in  std_logic_vector(w-1 downto 0);
    current_direction : in  std_logic_vector(1 downto 0);
    current_intention : in  std_logic;
    my_resp_id        : in  std_logic_vector(2 downto 0);

    going_up          : in  call_vector(0 to (2**w)-1);
    going_down        : in  call_vector(0 to (2**w)-1);

    going_up_caught   : out call_vector(0 to (2**w)-1);
    going_down_caught : out call_vector(0 to (2**w)-1)
  );
end call_dispatcher;

architecture structural of call_dispatcher is

begin
  -- Gera 64(!!!) call_catcher'ers
  gen_up : for i in 0 to (2**w)-1 generate
    constant target_floor_const : std_logic_vector(w-1 downto 0) 
      := std_logic_vector(to_unsigned(i, w));

    up_inst : entity work.call_catcher
      generic map (w => w)
      port map (
        current_floor     => current_floor,
        current_direction => current_direction,
        current_intention => current_intention,
        target_floor      => target_floor_const,
        target_intention  => '1',
        my_resp_id        => my_resp_id,
        call_in           => going_up(i),
        call_out          => going_up_caught(i)
      );

    down_inst : entity work.call_catcher
      generic map (w => w)
      port map (
        current_floor     => current_floor,
        current_direction => current_direction,
        current_intention => current_intention,
        target_floor      => target_floor_const,
        target_intention  => '0',
        my_resp_id        => my_resp_id,
        call_in           => going_down(i),
        call_out          => going_down_caught(i)
      );
  end generate;

end structural;
