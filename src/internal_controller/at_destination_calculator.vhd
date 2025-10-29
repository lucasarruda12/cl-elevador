library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity at_destination_calculator is
  generic (w : natural := 5);
  port (
    move_up_request : in std_logic_vector (31 downto 0);
    move_dn_request : in std_logic_vector (31 downto 0);
    next_floor      : in integer range 0 to 31 := 0;
    status          : in std_logic_vector(1 downto 0);
    intention       : in std_logic_vector(1 downto 0);
    no_calls_left   : out boolean;
    at_destination  : out boolean
  );
end at_destination_calculator;

architecture arch of at_destination_calculator is
  signal floor_index : integer range 0 to 31;
  signal move_up_var : std_logic_vector(31 downto 0);
  signal move_dn_var : std_logic_vector(31 downto 0);
  signal left_floors : std_logic_vector(31 downto 0);
  signal zeros       : std_logic_vector(31 downto 0) := (others => '0');

begin
  -- Calculando floor_index com limite entre 0 e 31
  floor_index <= next_floor when next_floor >= 0 and next_floor <= 31 else
                 0 when next_floor < 0 else
                 31;

  -- Zera a chamada do andar atual
  gen_move_up: for i in 0 to 31 generate
    move_up_var(i) <= '0' when i = floor_index else move_up_request(i);
  end generate;

  gen_move_dn: for i in 0 to 31 generate
    move_dn_var(i) <= '0' when i = floor_index else move_dn_request(i);
  end generate;

  -- Calculando left_floors dependendo da intenção
  gen_left_floors: for i in 0 to 31 generate
    left_floors(i) <= move_up_var(i) when (intention = "10" and i <= floor_index) else
                       move_dn_var(i) when (intention = "01" and i >= floor_index) else
                       '0';
  end generate;

  no_calls_left <= left_floors = zeros;

  -- Determinando se estamos no destino
  at_destination <= 
       ((intention = "10" and move_up_request(floor_index) = '1') and
        (status = "10" or left_floors = zeros)) or
       ((intention = "01" and move_dn_request(floor_index) = '1') and
        (status = "01" or left_floors = zeros)) or
       ((intention = "00") and 
        (move_dn_request(floor_index) = '1' or move_up_request(floor_index) = '1'));

end arch;
